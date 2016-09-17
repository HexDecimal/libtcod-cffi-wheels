#!/bin/bash

PYPY_URL=https://bitbucket.org/pypy/pypy/downloads

if [ -z $PORTABLE_PYPY_VERSION ]; then
    return
fi

function before_install {
    set -x
    export CC=clang
    export CXX=clang++
    get_macpython_environment $PORTABLE_PYPY_VERSION venv
    source venv/bin/activate
    pip install --upgrade pip wheel
}

function install_macpython {
    # Installs pypy.org PyPy
    # Parameter $version
    # Version given in major or major.minor or major.minor.micro e.g
    # "3" or "3.4" or "3.4.1".
    # sets $PYTHON_EXE variable to python executable
    local py_version=$1 # $(fill_pyver $1)
    #local py_stripped=$(strip_ver_suffix $py_version)
    local py_build=pypy2-v$py_version-osx64
    local py_zip=$py_build.tar.bz2
    local zip_path=$DOWNLOADS_SDIR/$py_zip
    mkdir -p $DOWNLOADS_SDIR
    #curl $PYPY_URL/${py_zip} > $zip_path
    wget $PYPY_URL/${py_zip} -P $DOWNLOADS_SDIR
    ls -a $DOWNLOADS_SDIR
    untar $zip_path
    PYTHON_EXE=$(realpath $DOWNLOADS_SDIR/$py_build/bin/pypy)
}
