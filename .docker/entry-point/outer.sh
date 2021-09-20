#!/usr/bin/env bash
# We want our inner entrypoint to run from within pocky entry.
# This will ensure that users, groups and all are setup properly.
exec /usr/bin/distro-entry.sh "/usr/bin/dumb-init" -- "/usr/bin/poky-entry.py" "/entry-point/inner.sh" "$@"
