CUSTOM_OVERLAY = "custom-overlay"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://${CUSTOM_OVERLAY}.dts"

KERNEL_DEVICETREE:append = " ${CUSTOM_OVERLAY}.dtbo"

do_configure:append() {
    cp ${WORKDIR}/${CUSTOM_OVERLAY}.dts ${S}/arch/${ARCH}/boot/dts/
}
