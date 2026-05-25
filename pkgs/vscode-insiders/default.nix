{ pkgs }:

let
  src = fetchTarball {
    url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
    sha256 = "04brczgkvpkqrg018wss9z5hk56n4d58r1bd7zq83wsycma9mq2b"; 
  };
in
(pkgs.vscode.override {
  isInsiders = true;
}).overrideAttrs (oldAttrs: {
  pname = "vscode-insiders";
  version = "1.122.0-insider";
  isInsiders = true;
  inherit src;

  buildInputs = (oldAttrs.buildInputs or []) ++ [ pkgs.krb5 pkgs.libsoup_3 pkgs.webkitgtk_4_1 ];

  prePatch = ''
    ${oldAttrs.prePatch or ""}
    mkdir -p resources/app/node_modules/@vscode/ripgrep/bin
    touch resources/app/node_modules/@vscode/ripgrep/bin/rg
  '';

  preFixup = ''
    ${oldAttrs.preFixup or ""}
    rm -rf resources/app/node_modules/@github/copilot-linuxmusl-x64
  '';

  meta = (oldAttrs.meta or {}) // {
    mainProgram = "code-insiders";
  };
})