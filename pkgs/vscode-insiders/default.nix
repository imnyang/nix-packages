{ pkgs }:

let
  src = fetchTarball {
    url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
    sha256 = "1v1r8vq41dmxaifqhfhgji12qwgm44xanwbihrv3319384s8bf5f"; 
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