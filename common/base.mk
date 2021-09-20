# Variables expected to be set by project
# specific makefile.
ifndef PRJ_NAME
$(error 'PRJ_NAME' is not set)
endif

COMMON_DIR := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
REPO_ROOT_DIR := $(abspath $(dir $(abspath $(COMMON_DIR))))
DOCKER_DIR := $(REPO_ROOT_DIR)/.docker
NIX_DIR := $(REPO_ROOT_DIR)/.nix
PRJ_DIR := $(REPO_ROOT_DIR)/$(PRJ_NAME)
PRJ_SRC_DIR := $(PRJ_DIR)/src
PRJ_BUILD_DIR := $(PRJ_DIR)/build
PRJ_MANIFESTS_DIR := $(PRJ_SRC_DIR)/.repo/manifests
PRJ_DOCKER_DIR := $(PRJ_DIR)/docker

DC_OVERRIDE_CUSTOM_YAML_FILE = $(DOCKER_DIR)/common.override.yml
DC_DEFAULT_CUSTOM_YAML_FILE = $(DOCKER_DIR)/common.default.yml

ifeq ($(shell test -e "$(DC_OVERRIDE_CUSTOM_YAML_FILE)" && echo "true"),true)
  DC_CUSTOM_YAML_FILE = $(DC_OVERRIDE_CUSTOM_YAML_FILE)
else
  DC_CUSTOM_YAML_FILE = $(DC_DEFAULT_CUSTOM_YAML_FILE)
endif

common-print-vars:
	@echo "PRJ_NAME='$(PRJ_NAME)'"
	@echo "COMMON_DIR='$(COMMON_DIR)'"
	@echo "REPO_ROOT_DIR='$(REPO_ROOT_DIR)'"
	@echo "DOCKER_DIR='$(DOCKER_DIR)'"
	@echo "NIX_DIR='$(NIX_DIR)'"
	@echo "PRJ_DIR='$(PRJ_DIR)'"
	@echo "PRJ_SRC_DIR='$(PRJ_SRC_DIR)'"
	@echo "PRJ_BUILD_DIR='$(PRJ_BUILD_DIR)'"
	@echo "PRJ_MANIFESTS_DIR='$(PRJ_MANIFESTS_DIR)'"
	@echo "DC_OVERRIDE_CUSTOM_YAML_FILE='$(DC_OVERRIDE_CUSTOM_YAML_FILE)'"
	@echo "DC_DEFAULT_CUSTOM_YAML_FILE='$(DC_DEFAULT_CUSTOM_YAML_FILE)'"
	@echo "DC_CUSTOM_YAML_FILE='$(DC_CUSTOM_YAML_FILE)'"

.PHONY: \
  common-mkdirs \
  common-clean \
  common-clean-yocto-cache \
  common-clean-docker-peristant-state

common-mkdirs:
	mkdir -p $(COMMON_DIR)/yocto-cache/downloads
	mkdir -p $(COMMON_DIR)/yocto-cache/sstate
	mkdir -p $(COMMON_DIR)/docker-persistant-state

common-clean: \
  common-clean-docker-peristant-state \
  common-clean-yocto-cache

common-clean-yocto-cache:
	rm -rf $(COMMON_DIR)/yocto-cache

common-clean-docker-peristant-state:
	rm -rf $(COMMON_DIR)/docker-persistant-state

# Params
#  1: The docker service name.
#  2: The command to run once in the build env.
#     Interractive shell if left empty.
_DOCKER_ENV_RUN_FN = \
	env COMPOSE_UID="$(shell id -u)" COMPOSE_GID="$(shell id -g)" \
	  docker-compose \
	    -f "$(DOCKER_DIR)/common.yml" \
		-f "$(DC_CUSTOM_YAML_FILE)" \
		-f "$(PRJ_DOCKER_DIR)/default.yml" \
	    run $(1) --rm yocto-build-env $(2)

_DOCKER_ENV_CLEANUP_FN = \
	env COMPOSE_UID="$(shell id -u)" COMPOSE_GID="$(shell id -g)" \
	  docker-compose \
	    -f "$(DOCKER_DIR)/common.yml" \
		-f "$(DC_CUSTOM_YAML_FILE)" \
		-f "$(PRJ_DOCKER_DIR)/default.yml" \
	    down --remove-orphans

_DOCKER_ENV_MKDIRS = \
	mkdir -p $(PRJ_DIR) && \
	mkdir -p $(PRJ_SRC_DIR) && \
	mkdir -p $(PRJ_BUILD_DIR) && \
	mkdir -p $(PRJ_BUILD_DIR)/conf

# As a supplement to the 'TEMPLATECONF' environment variable
# that should have been set via the project specific docker
# compose yml file. This brings the conf content earlier
# so that dev has an opportunity to edit those before the
# first build.
# We makes sure that layer at least defines a mandatory
# 'bblayer.conf.sample' and a 'local.conf.sample'. Any other
# '*.sample' files will copied as well.
# Note also that installed conf files will be read-only which
# will act as a seal. Once dev edit one of these a breaks the
# seal. This might allow us to perform a validation before
# official build for example.
# Params:
#  1: The top level layer's name where samples for the project
#     are located.
_DOCKER_ENV_INSTALL_LAYER_TEMPLATECONF = \
	declare layer_name="$(1)" \
	&& declare src_smpl_dir="$(PRJ_SRC_DIR)/$${layer_name}/conf" \
	&& declare tgt_conf_dir="$(PRJ_BUILD_DIR)/conf" \
	&& declare tgt_conf_mode="555" \
	&& rm -f "$${tgt_conf_dir}/templateconf.cfg" \
	&& echo "/workdir/src/$${layer_name}/conf" > "$${tgt_conf_dir}/templateconf.cfg" \
	&& chmod "$${tgt_conf_mode}" "$${tgt_conf_dir}/templateconf.cfg" \
	&& test -f "$${src_smpl_dir}/bblayers.conf.sample" \
	&& test -f "$${src_smpl_dir}/local.conf.sample" \
	&& declare sample_to_install="$$(find "$${src_smpl_dir}" -mindepth 1 -maxdepth 1 -name '*.sample' -exec basename "{}" ".sample" \;)" \
	&& for s in $${sample_to_install}; do install -m "$${tgt_conf_mode}" "$${src_smpl_dir}/$${s}.sample" "$${tgt_conf_dir}/$${s}"; done

_DOCKER_ENV_ASSERT_BB_PRE_FN = \
	test -f "$(PRJ_BUILD_DIR)/conf/local.conf" -a -f "$(PRJ_BUILD_DIR)/conf/bblayers.conf"

_REPO_INIT_AND_SYNC_PINNED_FROM_MANIFEST = \
	MANIFEST_REPO_URL="$(1)" && \
	MANIFEST_REPO_BRANCH"$(2)" && \
	MANIFEST_BASENAME="$(3)" && \
	cd $(PRJ_SRC_DIR) && \
	repo init \
	  --no-repo-verify \
	  -u "$${MANIFEST_REPO_URL}" \
	  -b "$${MANIFEST_REPO_BRANCH}" \
	  -m "$${MANIFEST_BASENAME}" && \
	repo sync --detach

_REPO_REMOTE_ADD_AND_FETCH_FN = \
	REPO_URL="$(1)" && \
	REPO_DIR="$(PRJ_SRC_DIR)/$(2)" && \
	REMOTE="$(3)" && \
	2>/dev/null git \
	  -C "$${REPO_DIR}" \
	  remote add -f "$${REMOTE}" "$${REPO_URL}" \
	  || git -C "$${REPO_DIR}" fetch "$${REMOTE}"

_REPO_START_WORK_ON_BRANCH_FN = \
	REPO_DIR="$(PRJ_SRC_DIR)/$(1)" \
	BRANCH="$(2)" && \
	REMOTE="origin" && \
	cd "$${REPO_DIR}" && \
	git -C . config checkout.defaultRemote "$${REMOTE}" && \
	git -C . checkout "$${BRANCH}" && \
	git -C . branch --set-upstream-to="$${REMOTE}/$${BRANCH}" "$${BRANCH}"
