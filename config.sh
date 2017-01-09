#!/bin/bash
# Define custom utilities
# Test for OSX with [ -n "$IS_OSX" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.

    # setup Python to try and build a abi3 wheel
    set -x
    pip install "wheel>=0.30.0a0"
    cd libtcod-cffi
    echo "[bdist_wheel]" >> setup.cfg
    echo "py-limited-api = cp33" >> setup.cfg
    cd ..
    set +x


    if [[ -z "$IS_OSX" ]]; then
        yum -y install build-essential make cmake autoconf automake libtool \
               libasound2-devel libpulse-devel libaudio-devel libX11-devel \
               libXext-devel libXrandr-devel libXcursor-devel libXi-devel \
               libXinerama-devel libXxf86vm-devel libxss-devel \
               libgl1-mesa-devel libglu1-mesa-devel libesd0-devel dbus-devel* \
               libudevel-devel mesa-*devel* ibus-devel* \
               libffi libffi-devel
    fi
    
    cd SDL-mirror
    mkdir -p build
    cd build
    ../configure --prefix=/usr --exec-prefix=/usr
    make
    make install
    cd ../..
    set +x
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    python --version
    python -c "import tcod"
}
