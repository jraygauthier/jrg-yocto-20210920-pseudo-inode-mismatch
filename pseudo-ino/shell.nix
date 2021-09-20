{ pkgs ? null} @ args:

let
  pkgs = (import ../.nix/default.nix {}).ensurePkgs args;
  nixpkgsSrc = pkgs.path;
in

with pkgs;

mkShell rec {
  name = "jrg-yocto-pseudo-ino-dev-shell";

  buildInputs = [
    # Retrieving sources.
    mr

    # Building images.
    coreutils
    gnumake
    docker-compose
  ];

  shellHook = ''
  '';
}
