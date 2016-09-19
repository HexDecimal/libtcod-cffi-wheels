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
    wget -nv $PORTABLE_PYPY_URL/${py_zip} -O $DOWNLOADS_SDIR/$py_zip
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

    local plat=$1
    [ -z "$plat" ] && echo "plat not defined" && exit 1
    local build_cmds="$2"
    local docker_image=quay.io/pypa/manylinux1_$plat
    docker pull $docker_image
    docker run --rm \
        -e BUILD_COMMANDS="$build_cmds" \
        -e PYTHON_VERSION="$MB_PYTHON_VERSION" \
        -e PYPY_VERSION="$PYPY_VERSION" \
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


function make_workon_venv {
    # Make a virtualenv in given directory ('venv' default)
    # Set $PYTHON_EXE, $PIP_CMD to virtualenv versions
    # Parameter $venv_dir
    #    directory for virtualenv
    local venv_dir=$1
    if [ -z "$venv_dir" ]; then
        venv_dir="venv"
    fi
    venv_dir=`abspath $venv_dir`
    check_python
    $VIRTUALENV_CMD --python=$PYTHON_EXE $venv_dir
    PYTHON_EXE=$venv_dir/bin/python
    PIP_CMD=$venv_dir/bin/pip
}

function remove_travis_ve_pip {
    # Remove travis installs of virtualenv and pip
    if [ "$($SUDO which virtualenv)" == /usr/local/bin/virtualenv ]; then
        $SUDO pip uninstall -y virtualenv;
    fi
    if [ "$($SUDO which pip)" == /usr/local/bin/pip ]; then
        $SUDO pip uninstall -y pip;
    fi
}

function install_pip {
    # Generic install pip
    # Gets needed version from version implied by $PYTHON_EXE
    # Installs pip into python given by $PYTHON_EXE
    # Assumes pip will be installed into same directory as $PYTHON_EXE
    check_python
    mkdir -p $DOWNLOADS_SDIR
    curl $GET_PIP_URL > $DOWNLOADS_SDIR/get-pip.py
    # Travis VMS now install pip for system python by default - force install
    # even if installed already
    $SUDO $PYTHON_EXE $DOWNLOADS_SDIR/get-pip.py --ignore-installed
    local py_mm=`get_py_mm`
    PIP_CMD="$SUDO `dirname $PYTHON_EXE`/pip$py_mm"
}

function repair_wheelhouse {
    local in_dir=$1
    local out_dir=${2:-$in_dir}
    for whl in $in_dir/*.whl; do
        if [[ $whl == *none-any.whl ]]; then  # Pure Python wheel
            if [ "$in_dir" != "$out_dir" ]; then cp $whl $out_dir; fi
        else
            auditwheel show $whl
            auditwheel repair $whl -w $out_dir/
            # Remove unfixed if writing into same directory
            if [ "$in_dir" == "$out_dir" ]; then rm $whl; fi
        fi
    done
    chmod -R a+rwX $out_dir
}

export SUDO=sudo

if [ -f /.dockerenv ]; then
    if [ -n "$PYPY_VERSION" ]; then
        export SUDO=""
        if [ -d "pypy_venv" ]; then
            source pypy_venv/bin/activate
            pip freeze
        else
            get_python_environment pypy_venv
        fi
        python --version
    fi
    return
fi

function install_run {
    # Install wheel, run tests
    #
    # In fact wraps the actual work which happens in the container.
    #
    # Depends on
    #  PLAT (can be passed in as argument)
    #  MB_PYTHON_VERSION
    #  UNICODE_WIDTH (optional)
    #  WHEEL_SDIR (optional)
    #  MANYLINUX_URL (optional)
    #  TEST_DEPENDS  (optional)
    local plat=${1:-$PLAT}
    bitness=$([ "$plat" == i686 ] && echo 32 || echo 64)
    local docker_image="matthewbrett/trusty:$bitness"
    docker pull $docker_image
    docker run --rm \
        -e PYTHON_VERSION="$MB_PYTHON_VERSION" \
        -e PYPY_VERSION="$PYPY_VERSION" \
        -e UNICODE_WIDTH="$UNICODE_WIDTH" \
        -e WHEEL_SDIR="$WHEEL_SDIR" \
        -e MANYLINUX_URL="$MANYLINUX_URL" \
        -e TEST_DEPENDS="$TEST_DEPENDS" \
        -v $PWD:/io \
        $docker_image /io/$MULTIBUILD_DIR/docker_test_wrap.sh
}