#
# The minimal dependencies required to run utility scripts in
# this (`nix`) directory.
#

{ pkgs ? null
, workspaceDir ? null
} @ args:

let
  nixpkgsSrc = builtins.fetchTarball {
    # nixos-21.05 at 28/06/2021
    url = "https://github.com/nixos/nixpkgs/archive/f77036342e2b690c61c97202bf48f2ce13acc022.tar.gz";
    sha256 = "1vcrb2s6ngfv0vy7nwlqdqhy1whlrck3ws4ifk5dfhmvdy3jqmr4";
  };
  nixpkgs = nixpkgsSrc;

  # None at this time.
  srcs = {};
  pickedSrcs = {};

  # This repo's internal overlay.
  overlayInternal = import ./overlay-internal.nix { inherit srcs pickedSrcs; };
  overlayInternalReqs = builtins.attrNames (overlayInternal {} {});

  hasOverlayInternal = pkgs: builtins.all (x: x) (
    builtins.map (
      x: builtins.hasAttr x pkgs)
      overlayInternalReqs
  );

  # The set of overlays used by this repo.
  overlays = [
    overlayInternal
  ];

  importPkgs = { nixpkgs ? null } @ args:
      let
        nixpkgs =
          if args ? "nixpkgs" && null != args.nixpkgs
            then args.nixpkgs
            else nixpkgsSrc;  # From top level.
      in
    assert null != nixpkgs;
    import nixpkgs { inherit overlays; };


  ensurePkgs = { pkgs ? null, nixpkgs ? null }:
    if null != pkgs
      then
        if hasOverlayInternal pkgs
            # Avoid extending a `pkgs` that already has our overlays.
          then pkgs
        else
          pkgs.appendOverlays overlays
    else
      importPkgs { inherit nixpkgs; };

  pkgs = ensurePkgs args;
in

with pkgs;

let
  nixpkgs-get-store-path = writeScriptBin "nixpkgs-get-store-path" ''
    #!${bash}/bin/sh
    echo "${nixpkgs}"
  '';
in

{
  inherit nixpkgs ensurePkgs;
}
