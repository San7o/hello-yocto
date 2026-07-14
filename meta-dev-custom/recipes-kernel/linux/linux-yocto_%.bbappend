FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://dev-changes.cfg"

# Cheating, NOT FOR PRODUCTION
ERROR_QA:remove = "buildpaths"
