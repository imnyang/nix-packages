{ pkgs }:

let
  src = fetchTarball {
    url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
    sha256 = "0y0fcb1fadms3zp191gh74kn7vhp0mm02582km1anvsryc4ks5dq"; 
  };
in
(pkgs.vscode.override {
  isInsiders = true;
}).overrideAttrs (oldAttrs: {
  pname = "vscode-insiders";
  version = "1.122.0-insider";
  isInsiders = true;
  inherit src;

  buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 pkgs.libsoup_3 pkgs.webkitgtk_4_1 ];

  meta = oldAttrs.meta // {
    mainProgram = "code-insiders";
  };
})