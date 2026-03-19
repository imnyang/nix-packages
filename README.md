# imnyang Nix Packages
imnyang's custom nixpkgs overlay.

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
}

