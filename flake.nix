{
  description = "imnyang's nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    overlay = final: prev: {
      # waterfox = final.callPackage ./pkgs/waterfox/default.nix { };
      # another = final.callPackage ./pkgs/another/default.nix { };
      waterfox-bin = final.callPackage ./pkgs/waterfox-bin/default.nix { };
      xcursor-mizuki = final.callPackage ./pkgs/xcursor-mizuki/default.nix { stdenv = final.stdenv; };
      pjsk-cursor = final.callPackage ./pkgs/pjsk-cursor/default.nix { stdenv = final.stdenv; };
      helium = final.callPackage ./pkgs/helium/default.nix { };
      helium-sync = final.callPackage ./pkgs/helium-sync/default.nix { };
    };
    pkgs = nixpkgs.legacyPackages.${system}.extend overlay;
  in {
    overlays.default = overlay;

    nixosModules.helium-sync = import ./modules/helium-sync.nix;
    homeManagerModules.helium-sync = import ./modules/helium-sync-hm.nix;

    packages.${system} = {
      inherit (pkgs) waterfox-bin xcursor-mizuki pjsk-cursor helium helium-sync;
      # default = pkgs.waterfox-bin;
    };
  };
}
