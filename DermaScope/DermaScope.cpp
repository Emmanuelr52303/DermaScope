#include <stdio.h>
#include <string.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "hardware/i2c.h"
#include "pico/cyw43_arch.h"
#include "lwip/tcp.h"
#include "lwip/init.h"


// ==== Pin definitions ====
#define I2C_PORT i2c0
#define I2C_SDA 4
#define I2C_SCL 5

#define SPI_PORT spi0
#define SPI_MISO 16
#define SPI_CS   17
#define SPI_SCK  18
#define SPI_MOSI 19

#define CAM_CS SPI_CS
#define ARDUCHIP_TEST1 0x00
#define ARDUCHIP_TRIG  0x41
#define FIFO_CLEAR_MASK 0x01
#define FIFO_START_MASK 0x02
#define CAP_DONE_MASK   0x08
#define BURST_FIFO_READ 0x3C

#define PIN_RESET 6
#define PIN_PWDN  7
#define BUTTON_PIN 2  

#define MAX_IMAGE_SIZE 1024 * 50 // 50 KB max (adjust as needed)
static uint8_t image_buffer[MAX_IMAGE_SIZE];
static size_t image_size = 0;

// ==== Camera Functions ====
void cam_write_reg(uint8_t addr, uint8_t data) {
    uint8_t buf[2] = {addr | 0x80, data};
    gpio_put(CAM_CS, 0);
    spi_write_blocking(SPI_PORT, buf, 2);
    gpio_put(CAM_CS, 1);
}

uint8_t cam_read_reg(uint8_t addr) {
    uint8_t tx[2] = {addr & 0x7F, 0x00};
    uint8_t rx[2];
    gpio_put(CAM_CS, 0);
    spi_write_read_blocking(SPI_PORT, tx, rx, 2);
    gpio_put(CAM_CS, 1);
    return rx[1];
}

void cam_start_capture() {
    cam_write_reg(ARDUCHIP_TRIG, FIFO_START_MASK);
}

bool cam_capture_done() {
    return cam_read_reg(ARDUCHIP_TRIG) & CAP_DONE_MASK;
}

void cam_clear_fifo() {
    cam_write_reg(ARDUCHIP_TRIG, FIFO_CLEAR_MASK);
}

void init_spi() {
    spi_init(spi0, 4 * 1000 * 1000);
    gpio_set_function(SPI_MISO, GPIO_FUNC_SPI);
    gpio_set_function(SPI_MOSI, GPIO_FUNC_SPI);
    gpio_set_function(SPI_SCK, GPIO_FUNC_SPI);
    gpio_init(SPI_CS);
    gpio_set_dir(SPI_CS, GPIO_OUT);
    gpio_put(SPI_CS, 1);
}

void init_i2c() {
    i2c_init(i2c0, 100 * 1000);
    gpio_set_function(I2C_SDA, GPIO_FUNC_I2C);
    gpio_set_function(I2C_SCL, GPIO_FUNC_I2C);
    gpio_pull_up(I2C_SDA);
    gpio_pull_up(I2C_SCL);
}

size_t read_image_data() {
    size_t count = 0;
    uint8_t byte;
    gpio_put(CAM_CS, 0);
    spi_write_blocking(SPI_PORT, (uint8_t[]){BURST_FIFO_READ}, 1);
    while (count < MAX_IMAGE_SIZE) {
        spi_read_blocking(SPI_PORT, 0x00, &byte, 1);
        image_buffer[count++] = byte;
    }
    gpio_put(CAM_CS, 1);
    return count;
}

static err_t accept_callback(void *arg, struct tcp_pcb *newpcb, err_t err);
static err_t recv_callback(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err);

void tcp_server_init() {
    struct tcp_pcb *pcb = tcp_new();
    tcp_bind(pcb, IP_ADDR_ANY, 4242); // Choose a port
    pcb = tcp_listen(pcb);
    tcp_accept(pcb, accept_callback);
}

static err_t accept_callback(void *arg, struct tcp_pcb *newpcb, err_t err) {
    tcp_recv(newpcb, recv_callback);
    return ERR_OK;
}

static err_t recv_callback(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err) {
    if (!p) {
        tcp_close(tpcb);
        return ERR_OK;
    }

    // Send image when the client connects and sends a request
    tcp_write(tpcb, image_buffer, image_size, TCP_WRITE_FLAG_COPY);
    tcp_output(tpcb);
    pbuf_free(p);
    return ERR_OK;
}

void setup_button() {
    gpio_init(BUTTON_PIN);
    gpio_set_dir(BUTTON_PIN, GPIO_IN);
    gpio_pull_up(BUTTON_PIN);  // Enable internal pull-up resistor
}

// ==== Main Entry Point ====
int main() {
    stdio_init_all();

    if (cyw43_arch_init()) {
        printf("Wi-Fi init failed\n");
        return -1;
    }

    cyw43_arch_enable_ap_mode("DermaScope", "password123", CYW43_AUTH_WPA2_AES_PSK);
    printf("Access Point started. Connect to 'DermaScope'.\n");

    init_i2c();
    init_spi();

    cam_write_reg(ARDUCHIP_TEST1, 0x55);
    if (cam_read_reg(ARDUCHIP_TEST1) != 0x55) {
        printf("Camera SPI failed\n");
        return -1;
    }

    setup_button();  // Initialize the button

    // Main loop
    while (1) {
        // Check if button is pressed
        if (gpio_get(BUTTON_PIN) == 0) {  // Button pressed (low level)
            printf("Button pressed! Capturing image...\n");

            cam_clear_fifo();
            cam_start_capture();
            while (!cam_capture_done()) {
                sleep_ms(10);
            }

            // Wait for image capture to complete
            image_size = read_image_data();
            printf("Capture complete. Image ready!\n");
        }

        cyw43_arch_poll();
        sleep_ms(10);
    }

    return 0;
}