SUMMARY = "QEMU image for the Pseudo Inode Mismatch project"

inherit core-image

CORE_IMAGE_EXTRA_INSTALL += " \
    pseudo-inode-mismatch-trigger \
"

export PSEUDO_DEBUG = "of"
# export PSEUDO_DEBUG_FILE = "${WORKDIR}/pseudo/pseudo.log"

IMAGE_FSTYPES = "ext4"
