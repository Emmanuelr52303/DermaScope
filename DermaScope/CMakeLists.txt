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
include_directories(btstack/include)
# Set the path to libusb headers

project(DermaScope C CXX ASM)

set(PICO_CXX_ENABLE_EXCEPTIONS 1)

set(PICO_CXX_ENABLE_RTTI 1)

set(PKG_CONFIG_EXECUTABLE "C:/msys64/usr/bin/pkg-config.exe")

# Initialise the Raspberry Pi Pico SDK
pico_sdk_init()

# Add executable. Default name is the project name, version 0.1

add_executable(DermaScope DermaScope.cpp )
add_subdirectory(tinyusb/src)
add_subdirectory(btstack/port/libusb)

pico_set_program_name(DermaScope "DermaScope")
pico_set_program_version(DermaScope "0.1")

# Modify the below lines to enable/disable output over UART/USB
pico_enable_stdio_uart(DermaScope 1)
pico_enable_stdio_usb(DermaScope 0)

# Add the standard library to the build
target_link_libraries(DermaScope
        pico_stdlib)

# Add the standard include files to the build
target_include_directories(DermaScope PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
)

# Add any user requested libraries
target_link_libraries(DermaScope        
        tinyusb_device
        tinyusb_host
        btstack
        usb-1.0 
        )


pico_add_extra_outputs(DermaScope)

