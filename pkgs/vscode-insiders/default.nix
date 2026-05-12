{ pkgs }:

let
  src = fetchTarball {
    url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
    sha256 = "09dk54da3kwjnvnr2hvwblcba0big2pb1a3bsvgdfhl0sl24p4i1"; 
  };
in
(pkgs.vscode.override {
  isInsiders = true;
}).overrideAttrs (oldAttrs: {
  pname = "vscode-insiders";
  version = "1.120.0-insider";
  isInsiders = true;
  inherit src;

  buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 pkgs.libsoup_3 pkgs.webkitgtk_4_1 ];

  meta = oldAttrs.meta // {
    mainProgram = "code-insiders";
  };
})