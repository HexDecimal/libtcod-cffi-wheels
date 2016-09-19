#!/bin/bash

PORTABLE_PYPY_URL=https://bitbucket.org/squeaky/portable-pypy/downloads
DOWNLOADS_SDIR=downloads

function install_manylinux_python {
    # Installs portable PyPy
    # Parameter $version
    # Version given in major or major.minor or major.minor.micro e.g
    # "3" or "3.4" or "3.4.1".
    # sets $PYTHON_EXE variable to python executable
    local py_version=$1 # $(fill_pyver $1)
    local py_build="pypy-$py_version-linux_$(get_platform)-portable"
    local py_zip=$py_build.tar.bz2
    local zip_path=$DOWNLOADS_SDIR/$py_zip
    mkdir -p $DOWNLOADS_SDIR
    wget $PORTABLE_PYPY_URL/${py_zip} -P $DOWNLOADS_SDIR
    untar $zip_path
    PYTHON_EXE=$(realpath $py_build/bin/pypy)
}

function install_python {
    # Picks an implementation of Python determined by the current enviroment
    # variables then installs it
    # Sub-function will set $PYTHON_EXE variable to the python executable
    if [ -n "$PYPY_VERSION" ]; then
        install_manylinux_python $PYPY_VERSION
    elif [ -n "$PYTHON_VERSION" ]; then
        export PATH="$(cpython_path $PYTHON_VERSION $UNICODE_WIDTH)/bin:$PATH"
        export PYTHON_EXE="python"
    else
        echo "config error: "
        echo "    expected PYTHON_VERSION or PYPY_VERSION enviroment variable"
        exit 1
    fi
}


function build_multilinux {
    # Runs passed build commands in manylinux container
    #
    # Depends on
    #     MB_PYTHON_VERSION
    #     UNICODE_WIDTH (optional)
    #     BUILD_DEPENDS (optional)
    #     MANYLINUX_URL (optional)
    #     WHEEL_SDIR (optional)
    get_python_environment pypy_venv

    local plat=$1
    [ -z "$plat" ] && echo "plat not defined" && exit 1
    local build_cmds="$2"
    local docker_image=quay.io/pypa/manylinux1_$plat
    docker pull $docker_image
    docker run --rm \
        -e BUILD_COMMANDS="$build_cmds" \
        -e PYTHON_VERSION="$MB_PYTHON_VERSION" \
        -e PYPY_VIRTUALENV="pypy_venv" \
        -e UNICODE_WIDTH="$UNICODE_WIDTH" \
        -e BUILD_COMMIT="$BUILD_COMMIT" \
        -e WHEEL_SDIR="$WHEEL_SDIR" \
        -e MANYLINUX_URL="$MANYLINUX_URL" \
        -e BUILD_DEPENDS="$BUILD_DEPENDS" \
        -e REPO_DIR="$repo_dir" \
        -e DOWNLOADS_SDIR="$DOWNLOADS_SDIR" \
        -e PLAT="$PLAT" \
        -v $PWD:/io \
        $docker_image /io/$MULTIBUILD_DIR/docker_build_wrap.sh
}

set -x
if [ -n "$PYPY_VIRTUALENV" ]; then
    source /io/$PYPY_VIRTUALENV/bin/activate
    python --version
fi
set +x
