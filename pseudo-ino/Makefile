.PHONY: clean

_MKF_DIR := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
PRJ_NAME := $(shell basename "$(_MKF_DIR)")
include $(_MKF_DIR)/../common/base.mk

print-vars: common-print-vars
	@echo "_MKF_DIR='$(_MKF_DIR)'"

mkdirs: common-mkdirs
	$(call _DOCKER_ENV_MKDIRS)

conf-use-default: mkdirs
	$(call _DOCKER_ENV_INSTALL_LAYER_TEMPLATECONF,meta-pseudo-ino)

bootstrap-default: conf-use-default
	@rm -f "$(PRJ_SRC_DIR)/.mrconfig" \
	&& mr --trust-all bootstrap "$(PRJ_DIR)/mr/default.mrconfig" "$(PRJ_SRC_DIR)" \
	&& touch "$${HOME}/.mrtrust" \
	&& ( \
	  cat "$${HOME}/.mrtrust" | grep -q "$(PRJ_SRC_DIR)/.mrconfig" \
	  || echo "$(PRJ_SRC_DIR)/.mrconfig" >> "$${HOME}/.mrtrust" \
    ) \
	&& ( \
	  cd "$(PRJ_SRC_DIR)" \
	  && mr checkout \
	  && mr pin \
	)

_assert-bb-build-preconds: mkdirs
	$(call _DOCKER_ENV_ASSERT_BB_PRE_FN)

enter-build-env: _assert-bb-build-preconds
	$(call _DOCKER_ENV_RUN_FN,,)

build-qemu: _assert-bb-build-preconds
	$(call _DOCKER_ENV_RUN_FN,,env \
	  'MACHINE=qemux86-64' \
	  bitbake qemu-image \
  	)

run-docker-qemu: _assert-bb-build-preconds
	$(call _DOCKER_ENV_RUN_FN,,env 'MACHINE=qemux86-64' runqemu slirp nographic)

clean: \
  clean-docker \
  clean-build-dir

clean-build-dir:
	rm -rf $(PRJ_BUILD_DIR)

clean-docker:
	$(call _DOCKER_ENV_CLEANUP_FN)
