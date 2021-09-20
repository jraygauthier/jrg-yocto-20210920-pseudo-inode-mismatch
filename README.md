Readme
======

An environment to build yocto projects based on the [crops/poky] docker
container.

This repository formalizes a standard working yocto project structure using
a cache shared between projects (will get automatically created under
`common/yocto-cache` during initial build).

All of the project common and project specific knowledge is encoded as
tasks (PHONY) in the provided [gnumake] `./Makefile`.

Requirements
------------

 -  unix like system (only tested on a linux)
 -  [nix]
 -  [git]
 -  [docker] (daemon and cli)
 -  optional:
     -  [direnv]

[nix]: https://nixos.org/download.html
[git]: https://git-scm.com/downloads
[docker]: https://docs.docker.com/get-docker/
[direnv]: https://direnv.net/
[qemu]: https://www.qemu.org/download/
[crops/poky]: https://hub.docker.com/r/crops/poky
[gnumake]: https://www.gnu.org/software/make/manual/make.html


Entering the reproducible environement
--------------------------------------

Here's a really trivial way to get all required dependencies installed
without cluterring your system (available on any *unix-like* systems):

If not already installed:

 -  [download and install nix](https://nixos.org/download.html)
 -  [optionally download and install direnv](https://direnv.net/)

```bash
$ cd /path/to/my/project/subdir
$ nix-shell
# ..
```

Alternatively, if you decided to install it, you can enter the nix
environement using direnv:

```bash
$ cd /path/to/my/project/subdir
$ direnv allow
# ..
```

Project specific documentation
------------------------------

Each project has its own `README.md` file in its subdirectory.

See:

 -  [pseudo-ino/README.md](./pseudo-ino/README.md)


Contributing
------------

Contributing implies licensing those contributions under the terms of
[LICENSE](./LICENSE), which is an *Apache 2.0* license.
