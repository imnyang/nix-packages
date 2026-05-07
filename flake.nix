{
  description = "imnyang's nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    
    # Overlay 정의
    overlay = final: prev: {
      waterfox-bin = final.callPackage ./pkgs/waterfox-bin/default.nix { };
      xcursor-mizuki = final.callPackage ./pkgs/xcursor-mizuki/default.nix { };
      pjsk-cursor = final.callPackage ./pkgs/pjsk-cursor/default.nix { };
      helium = final.callPackage ./pkgs/helium/default.nix { };
      helium-sync = final.callPackage ./pkgs/helium-sync/default.nix { };
      vscode-insiders = final.callPackage ./pkgs/vscode-insiders/default.nix { };
    };

    pkgs = import nixpkgs {
      inherit system;
      overlays = [ overlay ];
      config.allowUnfree = true;
    };
  in {
    overlays.default = overlay;

    nixosModules.helium-sync = import ./modules/helium-sync.nix;
    homeManagerModules.helium-sync = import ./modules/helium-sync-hm.nix;

    packages.${system} = {
      inherit (pkgs) 
        waterfox-bin 
        xcursor-mizuki 
        pjsk-cursor 
        helium 
        helium-sync 
        vscode-insiders;
      
      default = pkgs.helium; # 예시로 하나를 기본값으로 지정
    };

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