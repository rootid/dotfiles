#!/bin/sh

# Check if it's x86_64 or arm64
function go_os_get_hardware_name() {
  uname -m
}

# Show number of cores
function go_os_get_no_of_cores() {
  sysctl -n hw.ncpu
}


