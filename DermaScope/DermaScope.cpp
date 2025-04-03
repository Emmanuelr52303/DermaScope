#include <stdio.h>
#include "pico/stdlib.h"
#include "tinyusb/src/tusb.h"
#include "btstack/src/btstack.h"

void btstack_main() {
    // Initialize BTstack
    btstack_init();

    // Initialize Bluetooth SPP
    hci_power_control(HCI_POWER_ON);

    // Set up SPP server or client, depending on your needs
    // For example, you can initialize a Bluetooth serial port here
    // or set up BLE communication

    // Loop to keep the BTstack running
    while(1) {
        btstack_run_loop_execute();
    }
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
