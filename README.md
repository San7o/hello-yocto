# hello-yocto

Yocto is a collection of tools and configurations for building Linux images.

The goal of yocto is to build a full Linux distribution tailored to a specific
target and/or usecase. This includes the toolchain, bootloader, kernel and
filesystem image. Keep in mind that Yocto is not a particular tool, it is more
of an umbrella project under the Linux Foundation. It uses the "OpenEmbedded"
framework which provides tools and configurations to build Linux, the build
system is called BitBake, and the reference base distribution you start with is
called "poky".

This repo is a small example of how to structure and use a yocto-based project.

## Quickstart

### Using Bitbake

Setup:

```bash
. setup-env.sh
```

Build:

```bash
bitbake core-image-minimal
```

Run the image:

```bash
runqemu snapshot nographic slirp
```

Generate the SDK:

```bash
bitbake core-image-minimal -c populate_sdk
```

### Using Kas

```bash
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt
```

Build:

```bash
kas build kas/qemux86-64.yml
```

You can also use `kas-conainer` to use a Docker container for the toolchain:

```bash
kas-container build kas/qemux86-64.yml
```

Run the image:

```bash
kas shell kas/qemux86-64.yml
runqemu snapshot nographic slirp
```

Generate the SDK:

```bash
kas build kas/qemux86-64.yml -c populate_sdk
```

## Layers

Layers allow you to customize the build system. Layers themselves contain
various types of build instructions such as recipes.

Create a layer:

```bash
bitbake-layers create-layer meta-dummy
```

Add a layer:

```bash
bitbake-layers add-layer meta-dummy
```

Show layers:

```bash
bitbake-layers show-layers
```

## Recipes

A recipe is a set of instructions for building packages, including where to
obtain the upstream sources, patches to apply, dependencies, compile options
etc.

When creating a recipe, you need to write a `.bb` file which implements all the
functionalities needed to install the package, such as `do_compile()` and
`do_build()`.

The directory structure would look like this:

```
meta-test/
  README
  conf/
    layer.conf
  recipes-example
    example/
      example-0.1/
        example.c
      example_0.1.bb
```

`example_0.1.bb`:

```bash
SUMMARY = "Example application"
SECTION = "examples"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://example.c"

# Avoid a compilation error: No GNU_HASH in the elf binary
TARGET_CC_ARCH += "${LDFLAGS}"

S = "${WORKDIR}"

do_compile() {
	     ${CC} example.c -o example
}

do_install() {
	     install -d ${D}${bindir}
	     install -m 0755 example ${D}${bindir}
}
```

To build the recipe:

```bash
bitbake example
```

To view a recipe's environment:

```
bitbake -e example
```

## Other commands

List fragments:

```bash
bitbake-config-build list-fragments
```

List appends:

```bash
bitbake-layers show-appends
```

Enable debug messages:

```bash
bitbake -DDD <package>
```

When a build broke and it fails to compile the next time:

```bash
kas build --target binutils -c cleansstate kas/qemux86-64.yml
```
