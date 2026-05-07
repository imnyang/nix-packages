# imnyang Nix Packages
imnyang's custom nixpkgs overlay.

## Included Packages
- `helium`: Helium AppImage wrapper
- `helium-sync`: Helium Sync utility
- `vscode-insiders`: VSCode Insiders
- `waterfox-bin`: Waterfox Browser
- `xcursor-mizuki`: Custom cursor
- `pjsk-cursor`: Custom cursor

[Build Status](https://git.mizuki.guru/imnyang/nix-packages/actions)

## Usage
Add the following to your nix configuration:

```nix
{
  inputs = {
    nixpkgs.url = "...";
    imnyang.url = "git+https://git.mizuki.guru/imnyang/nix-packages.git";
  };

  outputs = { imnyang, nixpkgs, ... }: 
    let pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [ imnyang.overlays.default ];
    };
    {
      # use some packages
    };

    nixConfig = {
      extra-substituters = [
        "https://cache.mizuki.guru/public"
      ];
      extra-trusted-public-keys = [
        "cache.mizuki.guru:IgipakDD/clr0XbuaIejPYMT5UkTVGKVTxtWXcsbiAg="
      ];
    };
}
```

## Modules

### helium-sync

#### NixOS
```nix
{
  inputs.imnyang.url = "git+https://git.mizuki.guru/imnyang/nix-packages.git";
  outputs = { self, nixpkgs, imnyang }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      modules = [
        imnyang.nixosModules.helium-sync
      ];
    };
  };
}
```

#### Home Manager
```nix
{
  inputs.imnyang.url = "git+https://git.mizuki.guru/imnyang/nix-packages.git";
  outputs = { self, home-manager, imnyang, ... }: {
    homeConfigurations.my-user = home-manager.lib.homeManagerConfiguration {
      modules = [
        imnyang.homeManagerModules.helium-sync
      ];
    };
  };
}
```
