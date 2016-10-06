#!/bin/bash
# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    if [ -n "$IS_OSX" ]; then
        brew install sdl2
    else
        set -x
        #yum -y install mesa-libGL-devel
        yum -y install build-essential make cmake autoconf automake libtool libasound2-dev libpulse-dev libaudio-dev libx11-dev libxext-dev libxrandr-dev libxcursor-dev libxi-dev libxinerama-dev libxxf86vm-dev libxss-dev libgl1-mesa-dev libesd0-dev libdbus-1-dev libudev-dev libgles1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libibus-1.0-dev
        cd SDL-mirror
        ls -a
        mkdir -p build
        cd build
        ../configure
        make
        make install
        set +x
    fi
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    python -c "import tcod"
}
