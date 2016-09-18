#!/bin/bash

PYPY_URL=https://bitbucket.org/pypy/pypy/downloads

function install_python {
    # Picks an implementation of Python determined by the current enviroment
    # variables then installs it
    # Sub-function will set $PYTHON_EXE variable to the python executable
    if [ -n "$MB_PYTHON_VERSION" ]; then
        install_macpython $MB_PYTHON_VERSION
    elif [ -n "$PYPY_VERSION" ]; then
        install_macpypy $PYPY_VERSION
    else
        echo "expected MB_PYTHON_VERSION enviroment variable"
        exit 1
    fi
}

function install_macpypy {
    # Installs pypy.org PyPy
    # Parameter $version
    # Version given in major or major.minor or major.minor.micro e.g
    # "3" or "3.4" or "3.4.1".
    # sets $PYTHON_EXE variable to python executable
    local pp_version=$1 # $(fill_pyver $1)
    local pp_build=pypy2-v$pp_version-osx64
    local pp_zip=$pp_build.tar.bz2
    local zip_path=$DOWNLOADS_SDIR/$pp_zip
    mkdir -p $DOWNLOADS_SDIR
    wget -nv $PYPY_URL/${pp_zip} -P $DOWNLOADS_SDIR
    untar $zip_path
    PYTHON_EXE=$(realpath $pp_build/bin/pypy)
}
