#!/bin/bash

PORTABLE_PYPY_URL=https://bitbucket.org/squeaky/portable-pypy/downloads

https://bitbucket.org/squeaky/portable-pypy/downloads/pypy-5.4.1-linux_i686-portable.tar.bz2

function install_manylinux_python {
    # Installs portable PyPy
    # Parameter $version
    # Version given in major or major.minor or major.minor.micro e.g
    # "3" or "3.4" or "3.4.1".
    # sets $PYTHON_EXE variable to python executable
    local pp_version=$1 # $(fill_pyver $1)
    local pp_build=pypy-$py_version-${get_platform}-portable
    local pp_zip=$py_build.tar.bz2
    local zip_path=$DOWNLOADS_SDIR/$pp_zip
    mkdir -p $DOWNLOADS_SDIR
    wget $PYPY_URL/${pp_zip} -P $DOWNLOADS_SDIR
    untar $zip_path
    PYTHON_EXE=$(realpath $py_build/bin/pypy)
}

function install_python {
    # Picks an implementation of Python determined by the current enviroment
    # variables then installs it
    # Sub-function will set $PYTHON_EXE variable to the python executable
    if [ -n "$PYTHON_VERSION" ]; then
        export PATH="$(cpython_path $PYTHON_VERSION $UNICODE_WIDTH)/bin:$PATH"
        export PYTHON_EXE="python"
    elif [ -n "$PYPY_VERSION" ]; then
        install_manylinux_python $PYPY_VERSION
    else
        echo "config error: "
        echo "    expected PYTHON_VERSION or PYPY_VERSION enviroment variable"
        exit 1
    fi
}

if [ -f /.dockerenv ]; then
    set -x
    get_python_environment venv
fi
