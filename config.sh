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
        yum search mesa
        yum search dbus
        #yum -y install mesa-libGL-devel
        yum -y install build-essential make cmake autoconf automake libtool libasound2-devel libpulse-devel libaudio-devel libx11-devel libxext-devel libxrandr-devel libxcursor-devel libxi-devel libxinerama-devel libxxf86vm-devel libxss-devel libgl1-mesa-devel libesd0-devel libdbus-1-devel libudevel-devel libgles1-mesa-devel libgles2-mesa-devel libegl1-mesa-devel libibus-1.0-devel
        cd SDL-mirror
        mkdir -p build
        cd build
        ../configure
        make
        make install
        ls -a
        cd ../..
        set +x
    fi
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    python -c "import tcod"
}
