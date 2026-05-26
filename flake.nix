{
  description = "imnyang's nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    overlay = final: prev: {
      waterfox-bin = final.callPackage ./pkgs/waterfox-bin/default.nix { };
      xcursor-mizuki = final.callPackage ./pkgs/xcursor-mizuki/default.nix { };
      pjsk-cursor = final.callPackage ./pkgs/pjsk-cursor/default.nix { };
      helium = final.callPackage ./pkgs/helium/default.nix { };
      vscode-insiders = final.callPackage ./pkgs/vscode-insiders/default.nix { };
    };

    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f (
      import nixpkgs {
        inherit system;
        overlays = [ overlay ];
        config.allowUnfree = true;
      }
    ));
  in {
    overlays.default = overlay;

    packages = forAllSystems (pkgs: 
      let
        allPkgs = {
          inherit (pkgs) 
            waterfox-bin 
            xcursor-mizuki 
            pjsk-cursor 
            helium 
            vscode-insiders;
        };
      in
        nixpkgs.lib.filterAttrs (name: pkg: 
          nixpkgs.lib.elem pkgs.stdenv.hostPlatform.system (pkg.meta.platforms or [ "x86_64-linux" ])
        ) allPkgs
    );

    nixConfig = {
      extra-substituters = [
        "https://cache.mizuki.guru/public"
      ];
      extra-trusted-public-keys = [
        "cache.mizuki.guru:IgipakDD/clr0XbuaIejPYMT5UkTVGKVTxtWXcsbiAg="
      ];
    };
  };
}