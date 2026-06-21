#!/bin.sh

# First time setup

set -e

if [ "$3" = "$0" ] || [ "$(basename "$0")" = "setup-env.sh" ]; then
    echo "ERROR: You must SOURCE this script, do not execute it directly!"
    echo "Correct usage: . ./setup-env.sh"
    exit 1
fi

echo "--> Initializing Yocto Environment via bitbake-setup..."

./bitbake/bin/bitbake-setup init \
    --non-interactive \
    --setup-dir-name poky-wrynose \
    ./bitbake/default-registry/configurations/poky-wrynose.conf.json \
    poky \
    machine/qemux86-64 \
    distro/poky

cd bitbake-builds/poky-wrynose/ || return 1

. ./build/init-build-env

echo "--> Applying active configuration fragments..."

bitbake-config-build enable-fragment core/yocto/root-login-with-empty-password
bitbake-config-build enable-fragment core/yocto/sstate-mirror-cdn

echo "Yocto configuration done"
