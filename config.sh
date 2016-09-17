#!/bin/bash
# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    if [ -n "$IS_OSX" ]
    then
        brew install sdl
    else
        yum -y install SDL*
        yum -y install mesa-libGL-devel
    fi
    ls
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    python -m nose2
    ls
}

if [ -n "$IS_OSX" ]; then
    source config_osx.sh
else
    source config_manylinux.sh
fi
