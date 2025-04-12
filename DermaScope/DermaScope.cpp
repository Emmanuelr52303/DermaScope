#include <stdio.h>
#include "pico/stdlib.h"
#include "btstack.h"

static uint16_t my_service_handle;
static uint16_t my_char_handle;
static uint8_t my_char_value[20] = {0}; // Sample data for a characteristic

// Callback function to handle GATT events (e.g., reading or writing characteristics)
static void packet_handler(uint8_t packet_type, uint16_t channel, uint8_t *packet, uint16_t size) {
    switch (packet_type) {
        case HCI_EVENT_PACKET:
            // Handle events such as connections, disconnections, and pairing
            break;

        case GATT_EVENT_SERVICE_ADDED:
            printf("Service added\n");
            break;

        case GATT_EVENT_CHARACTERISTIC_READ_REQUEST:
            if (packet[2] == my_char_handle) {
                printf("Characteristic read request\n");
                // Respond with the characteristic value
                gatt_server_send_characteristic_value(my_service_handle, my_char_handle, my_char_value, sizeof(my_char_value));
            }
            break;

        case GATT_EVENT_CHARACTERISTIC_WRITE_REQUEST:
            if (packet[2] == my_char_handle) {
                printf("Characteristic write request\n");
                // Handle the incoming value (write it to the characteristic)
                memcpy(my_char_value, &packet[3], size - 3);  // Copy the data written
            }
            break;
    }
}

// Set up the GATT server with services and characteristics
void gatt_server_setup(void) {
    // Initialize the GATT server
    gatt_server_init();

    // Define the GATT service and characteristic
    my_service_handle = gatt_server_create_service(0x180F);  // Sample service UUID (Battery service)
    my_char_handle = gatt_server_add_characteristic(my_service_handle, 0x2A19, GATT_PROPERTY_READ | GATT_PROPERTY_WRITE);

    // Start advertising the service
    gap_advertisements_start();
    printf("GATT service started\n");
}

// Main BTstack loop
void btstack_main(void) {
    // Initialize BTstack
    btstack_init();

    // Power on Bluetooth
    hci_power_control(HCI_POWER_ON);

    // Set up GATT server
    gatt_server_setup();

    // Run the BTstack loop
    btstack_run_loop_execute();
}

int main()
{
    // Initialize standard input/output and GPIO
    stdio_init_all();

    //start bluetooth search
    btstack_main();

    // Define the GPIO pin
    const uint button = 15;  // Choose any available GPIO pin, here using GPIO 15

    // Initialize the GPIO pin as an output
    gpio_init(button);
    gpio_set_dir(button, GPIO_IN);  // Set the pin as an output

    while (true) {
        //Check for button push
        if(button == 1){
            
        }
    }

    return 0;
}
