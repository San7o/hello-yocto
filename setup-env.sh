#!/bin/bash

TOP_DIR="$(pwd)"
BITBAKE_SETUP_DIR="poky-wrynose"
BUILD_DIR="${TOP_DIR}/bitbake-builds/${BITBAKE_SETUP_DIR}/"

print_help () {
    echo "usage:"
    echo ". ./setup-env.sh <flags>"
    echo ""
    echo "Flags:"
    echo "    -f,--force   Force sync, runs bitbake-setup init again. Do this"
    echo "                 if you changed something in configs/"
    echo "    -h,--help    Print this help message"
}

info () {
    echo "INFO: $1"
}

# Flags
FORCE_SYNC=0

for arg in "$@"; do
    if [ "$arg" = "-h" ] || [ "$arg" = "--help" ]; then
        print_help
        exit 0
    fi
    if [ "$arg" = "-f" ] || [ "$arg" = "--force" ]; then
        FORCE_SYNC=1
        info "Using force sync"
    fi
done


if [ "$3" = "$0" ] || [ "$(basename "$0")" = "setup-env.sh" ]; then
    echo "ERROR: You must SOURCE this script, do not execute it directly!"
    print_help
    exit 1
fi

BITBAKE_INIT_ARGS="--non-interactive \
        ${TOP_DIR}/configs/poky-wrynose.conf.json \
        poky \
        machine/qemux86-64 \
        distro/poky"

if [ ! -d "${BUILD_DIR}" ]; then

    echo "--> Initializing Yocto Environment via bitbake-setup..."

    "${TOP_DIR}/bitbake/bin/bitbake-setup" init \
        --setup-dir-name ${BITBAKE_SETUP_DIR} \
        ${BITBAKE_INIT_ARGS} \

    if [ $? -ne 0 ]; then
        echo "ERROR: bitbake-setup init failed"
        return 1
    fi

elif [ ${FORCE_SYNC} -eq 1 ]; then

    echo "--> Updating Yocto Environment via bitbake-setup..."

    "${TOP_DIR}/bitbake/bin/bitbake-setup" update \
        --setup-dir "${BUILD_DIR}" \
        --update-bb-conf yes

    if [ $? -ne 0 ]; then
        echo "ERROR: bitbake-setup update failed"
        return 1
    fi
else
    echo "--> Existing build directory found. Skipping initialization."
fi

# Layers
DUMMY_LAYER=meta-dummy

if [ ! -d ${DUMMY_LAYER} ]; then
    echo "--> Creating ${DUMMY_LAYER}..."
    ${TOP_DIR}/bitbake/bin/bitbake-layers create-layer ${DUMMY_LAYER}
fi

cd "${BUILD_DIR}" || return 1

if [ -f "./build/init-build-env" ]; then
    . ./build/init-build-env
else
    . ./build/build-env
fi


if [ -d ../../../${DUMMY_LAYER} ]; then
    echo "--> Adding ${DUMMY_LAYER} layer..."
    bitbake-layers add-layer ../../../${DUMMY_LAYER}
fi

echo "--> Applying active configuration fragments..."

bitbake-config-build enable-fragment core/yocto/root-login-with-empty-password
bitbake-config-build enable-fragment core/yocto/sstate-mirror-cdn

echo "-----------------------------------------------------"
echo " Yocto environment ready. You can now run 'bitbake'."
echo "-----------------------------------------------------"
