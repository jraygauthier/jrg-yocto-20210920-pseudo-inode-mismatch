SUMMARY = "Pseudo inode mismatch trigger package"
HOMEPAGE = "http://git.yoctoproject.org/cgit/cgit.cgi/pseudo/about/?h=oe-core"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = " \
  file://arbitrary-script \
  file://arbitrary-script-once.service \
"

# Add this package to your image's `CORE_IMAGE_EXTRA_INSTALL`,
# and then:
#
#  1. create an initial build.
#  2. modify `./files/arbitrary-script`.
#  3. launch the build anew.
#
# Bang with the following error:
#
# ```
# path mismatch [1 link]: ino 13392623 db '$IMAGE_ROOTFS/etc/ld.so.conf'
# req '$IMAGE_ROOTFS/etc/machine-id'.
# ```
#

RDEPENDS_${PN} += "\
    cpp \
    cpp-symlinks \
    "

# RDEPENDS_${PN} += "\
#     python3-pyjwt \
#     python3-requests \
#     python3-cryptography \
#     "

do_install() {
    install -d "${D}${bindir}"
    install -m 0755 "${WORKDIR}/arbitrary-script" "${D}${bindir}"
    install -d "${D}${systemd_unitdir}/system"
    install -m 0644 "${WORKDIR}/arbitrary-script-once.service" "${D}${systemd_unitdir}/system"
}

inherit systemd
SYSTEMD_SERVICE_${PN} = "arbitrary-script-once.service"
