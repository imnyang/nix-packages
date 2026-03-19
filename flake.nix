{
  description = "imnyang's nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = {
      waterfox = pkgs.callPackage ./pkgs/waterfox/default.nix { };
      waterfox-bin = pkgs.callPackage ./pkgs/waterfox-bin/default.nix { };
      default = self.packages.${system}.waterfox-bin;
    };
  };
}
