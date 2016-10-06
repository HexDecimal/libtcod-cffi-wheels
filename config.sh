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
        yum -y install mesa-libGL-devel
        cd SDL-mirror
        ls
        mkdir build
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
