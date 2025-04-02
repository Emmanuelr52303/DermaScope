#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"
#include "hardware/i2c.h"
#include "hardware/dma.h"
#include "hardware/pio.h"
#include "hardware/interp.h"
#include "blink.pio.h" // Include your PIO blink program

#define LED_PIN 10  // Define a GPIO pin for an LED
#define I2C_PORT i2c0    // Use i2c0 or i2c1
#define I2C_SDA 4        // GPIO Pin for SDA
#define I2C_SCL 5        // GPIO Pin for SCL

void blink_pin_forever(PIO pio, uint sm, uint offset, uint pin, uint freq);

int main() {
    stdio_init_all();

    // Initialize GPIO for LED control
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);

    // I2C Initialization
    i2c_init(I2C_PORT, 400*1000);
    gpio_set_function(I2C_SDA, GPIO_FUNC_I2C);
    gpio_set_function(I2C_SCL, GPIO_FUNC_I2C);
    gpio_pull_up(I2C_SDA);
    gpio_pull_up(I2C_SCL);

    // DMA Initialization
    uint8_t src[10] = {1,2,3,4,5,6,7,8,9,10};
    uint8_t dst[10] = {0};

    int chan = dma_claim_unused_channel(true);
    dma_channel_config c = dma_channel_get_default_config(chan);
    channel_config_set_transfer_data_size(&c, DMA_SIZE_8);
    channel_config_set_read_increment(&c, true);
    channel_config_set_write_increment(&c, true);
    dma_channel_configure(chan, &c, dst, src, sizeof(src), true);
    dma_channel_wait_for_finish_blocking(chan);

    // Print DMA result
    for (int i = 0; i < sizeof(dst); i++) {
        printf("%02X ", dst[i]);  // Print each byte in hex
    }
    printf("\n");

    // PIO Blinking example
    PIO pio = pio0;
    uint offset = pio_add_program(pio, &blink_program);
    printf("Loaded program at %d\n", offset);
    
    #ifdef PICO_DEFAULT_LED_PIN
    blink_pin_forever(pio, 0, offset, PICO_DEFAULT_LED_PIN, 3);
    #else
    blink_pin_forever(pio, 0, offset, 6, 3);
    #endif

    // Interpolator example
    interp_config cfg = interp_default_config();
    interp_set_config(interp0_hw, 0, &cfg);

    // Main loop: Blink GPIO LED every second
    while (true) {
        printf("Hello, world!\n");

        // Toggle GPIO LED
        gpio_put(LED_PIN, 1); // Turn LED on
        sleep_ms(500);
        gpio_put(LED_PIN, 0); // Turn LED off
        sleep_ms(500);
    }
}

