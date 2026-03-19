{
  description = "imnyang's nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    overlay = final: prev: {
      waterfox = final.callPackage ./pkgs/waterfox/default.nix { };
      waterfox-bin = final.callPackage ./pkgs/waterfox-bin/default.nix { };
    };
    pkgs = nixpkgs.legacyPackages.${system}.extend overlay;
  in {
    overlays.default = overlay;

    packages.${system} = {
      inherit (pkgs) waterfox waterfox-bin;
      default = pkgs.waterfox-bin;
    };
  };
}
