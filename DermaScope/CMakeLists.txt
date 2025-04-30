# Generated Cmake Pico project file

cmake_minimum_required(VERSION 3.16)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Initialise pico_sdk from installed location
# (note this can come from environment, CMake cache etc)

set(PICO_BOARD pico_w CACHE STRING "Board type")

# Pull in Raspberry Pi Pico SDK (must be before project)
include(pico_sdk_import.cmake)

project(DermaScope C CXX ASM)

# Initialise the Raspberry Pi Pico SDK
pico_sdk_init()

# Add executable. Default name is the project name, version 0.1
add_executable(DermaScope DermaScope.cpp)

pico_set_program_name(DermaScope "DermaScope")
pico_set_program_version(DermaScope "0.1")

# Modify the below lines to enable/disable output over UART/USB
pico_enable_stdio_uart(DermaScope 1)
pico_enable_stdio_usb(DermaScope 1)

# Add the standard library to the build
target_link_libraries(DermaScope pico_stdlib)

# Add libraries for hardware support
target_link_libraries(DermaScope 
        hardware_spi
        hardware_i2c
        pico_cyw43_arch_lwip_threadsafe_background
        pico_lwip
        pico_lwip_http
)

# Include necessary directories
target_include_directories(DermaScope PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
)

# Set compile definitions
target_compile_definitions(DermaScope PRIVATE
    -DPICO_CYW43_SUPPORTED=1
    LWIP_TIMEVAL_PRIVATE=0
)

# Enable lwIP and thread-safe background mode
set(CYW43_LWIP 1)
set(PICO_CYW43_ARCH_THREADSAFE_BACKGROUND 1)

# Generate extra output files (e.g., .uf2)
pico_add_extra_outputs(DermaScope)
