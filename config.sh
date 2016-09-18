#!/bin/bash
# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    set -x
    if [ -n "$IS_OSX" ]
    then
        brew install sdl
    else
        yum -y -v install SDL* mesa-libGL-devel libffi-devel
    fi
    ls
}

function run_tests {
    set -x
    # Runs tests on installed distribution from an empty directory
    python --version
    if [ -n "$IS_OSX" ]
    then
        cd $TRAVIS_BUILD_DIR
    else
        cd /io/libtcod-cffi/
    fi
    python -m nose2
}

if [ -n "$IS_OSX" ]; then
    source config_osx.sh
else
    source config_manylinux.sh
fi
