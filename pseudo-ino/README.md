Readme
======


See [../README](../README.md) for:

 -  requirements
 -  procedure to enter the reproducible nix environment


## Download sources and select default set of conf

```bash
$ make bootstrap-default
# ..
```

Result under: `./src/` for the sources and `./build/conf/` for the
default provided `*.conf` files.

## Build

```bash
$ make build-qemu
# ..
```

Result under `./build/tmp-qemux86-64-official/`.

Common cache under `../common/yocto-cache/` updated.


## Reproducing the inode mismatch issue

 1. Create an initial build (see above step).
 2. Modify one of the package to force the image to be rebuilt (e.g.:
    `./src/meta-pseudo-ino/recipes-pino/pseudo-inode-mismatch-trigger/files/arbitrary-script`)
 3. Launch the build anew.

Bang with the following error:

```log
inode mismatch: '/workdir/build/tmp-qemux86-64-official/work/qemux86_64-poky-linux/qemu-image/1.0-r0/rootfs/etc/ld.so.conf' ino 3298325 in db, 3298733 in request.
creat for '/tmp/sh-thd.scD0qR' replaces existing 1321832 ['/tmp/sh-thd.hpxOvN'].
creat for '/tmp/tmpa6onzwon' replaces existing 1321832 ['/tmp/sh-thd.scD0qR'].
db cleanup for server shutdown, 11:30:42.783
memory-to-file backup complete, 11:30:42.784.
db cleanup finished, 11:30:42.784
debug_logfile: fd 2
pid 7093 [parent 7092], doing new pid setup and server start
Setup complete, sending SIGUSR1 to pid 7092.
debug_logfile: fd 2
pid 317 [parent 316], doing new pid setup and server start
Setup complete, sending SIGUSR1 to pid 316.
path mismatch [1 link]: ino 3298351 db '/workdir/build/tmp-qemux86-64-official/work/qemux86_64-poky-linux/qemu-image/1.0-r0/rootfs/etc/ld.so.conf' req '/workdir/build/tmp-qemux86-64-official/work/qemux86_64-poky-linux/qemu-image/1.0-r0/rootfs/etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service'.
```

Issue might now be systematically reproducible with this simplified project but
definitly was with our client's full project (which we cannot discolsed). If
that is your case, retry step \#2 through step \#3. If still not reproducible,
delete the output and start again from step \#1 until you stumble on this issue.


Note that:

 -  I am building from an ext4. Contrary to other filesystems (i.e: zfs, etc)
    ext4's inode reuse policy to reuse a previouly freed inode immediatly.

 -  Issue was only observed with a *distro* `*.conf` enabling systemd.

 -  We found that it is possible to workaround the issue by removing
    `image-prelink` from the `USER_CLASSES` variable defined in `local.conf`
    (`USER_CLASSES ?= "buildstats image-mklibs image-prelink"` -> `USER_CLASSES
    ?= "buildstats image-mklibs"`).

    So the issue really seems to be trigged by the image preprocessing command
    defined in `poky/meta/classes/image-prelink.bbclass`
    (`IMAGE_PREPROCESS_COMMAND_append_libc-glibc = " prelink_setup; prelink_image; "`).

    Supporting this even more is that `ld.so.conf` is always 

 -  We attempted to reproduce the issue only using pseudo in the context of
    various command cases but were unfortunately unsuccessful in reproducing in
    isolation. There definitely is something we did not grasp from the logs.

    Here's the automated tests project we developped:

     -  [amotus/oe-pseudo-test-env: A reproducible environment for experiments and automated tests on open embedded *pseudo*.](https://github.com/amotus/oe-pseudo-test-env)

        Tested command cases under:

         -  [test_lib/data/cmd_cases](https://github.com/amotus/oe-pseudo-test-env/tree/master/test_lib/data/cmd_cases)

    This little project might possibly be a good start for more torough *pseudo* testing.

    If the *open embedded* / *pseudo* team would like to include this in its CI
    runs or even take this under its umbrella, we're all-in.

