#!/usr/bin/env bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
install -m 0600 /entry-point/ssh/known_hosts ~/.ssh/known_hosts
source "/workdir/src/poky/oe-init-build-env" "/workdir/build"

# Allow user to customize the uboot config, the machine and set a
# tmpdir suffix for named experiments. Also allow user to pass
# a template conf so that he gets a proper default local.conf
# and bblayer.conf when those do not exist.
declare extrawhite_a=( \
  "${BB_ENV_EXTRAWHITE}" \
  "TEMPLATECONF" \
  "UBOOT_CONFIG" \
  "MACHINE" \
  "TMPDIR_SUFFIX" \
  "LOCALCONF_FLAVOR" \
)

declare extrawhite
printf -v extrawhite " %s" "${extrawhite_a[@]}"
export "BB_ENV_EXTRAWHITE=$extrawhite"

if [ $# -gt 0 ]; then
    exec bash -c "$*"
else
    exec bash -i
fi
