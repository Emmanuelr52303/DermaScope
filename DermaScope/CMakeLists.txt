# Generated Cmake Pico project file

cmake_minimum_required(VERSION 3.13)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Initialise pico_sdk from installed location
# (note this can come from environment, CMake cache etc)

# == DO NOT EDIT THE FOLLOWING LINES for the Raspberry Pi Pico VS Code Extension to work ==
if(WIN32)
    set(USERHOME $ENV{USERPROFILE})
else()
    set(USERHOME $ENV{HOME})
endif()
set(sdkVersion 2.1.1)
set(toolchainVersion 14_2_Rel1)
set(picotoolVersion 2.1.1)
set(picoVscode ${USERHOME}/.pico-sdk/cmake/pico-vscode.cmake)
if (EXISTS ${picoVscode})
    include(${picoVscode})
endif()
# ====================================================================================
set(PICO_BOARD pico_w CACHE STRING "Board type")

# Pull in Raspberry Pi Pico SDK (must be before project)
include(pico_sdk_import.cmake)

project(DermaScope C CXX ASM)

set(PICO_CYW43_LWIP_HTTPD 1)

# Initialise the Raspberry Pi Pico SDK
pico_sdk_init()

# Add executable. Default name is the project name, version 0.1
add_executable(DermaScope DermaScope.cpp )


pico_set_program_name(DermaScope "DermaScope")
pico_set_program_version(DermaScope "0.1")

# Generate PIO header
pico_generate_pio_header(DermaScope ${CMAKE_CURRENT_LIST_DIR}/blink.pio)

# Modify the below lines to enable/disable output over UART/USB
pico_enable_stdio_uart(DermaScope 1)
pico_enable_stdio_usb(DermaScope 0)

# Add the standard library to the build
target_link_libraries(DermaScope)

link_directories(${PICO_SDK_PATH}/lib)

# Add the standard include files to the build
target_include_directories(DermaScope PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
)

target_compile_definitions(DermaScope PRIVATE
    -DPICO_CYW43_SUPPORTED=1
    LWIP_TIMEVAL_PRIVATE=0
)

# Add any user requested libraries
target_link_libraries(DermaScope 
        hardware_spi
        hardware_i2c
        hardware_pio
        pico_stdlib
        pico_cyw43_arch_lwip_threadsafe_background
        pico_lwip
        pico_lwip_http
        )

# Disable default exit handling
add_definitions(-DNO_EXIT_HANDLER)

pico_add_extra_outputs(DermaScope)

