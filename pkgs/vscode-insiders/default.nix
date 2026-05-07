{ pkgs }:

let
  src = fetchTarball {
    url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
    sha256 = "0cq5p2r949k1nskfacz2j0m9zyg116zpzc8csmxb1q51p7znixkc"; 
  };
in
(pkgs.vscode.override {
  isInsiders = true;
}).overrideAttrs (oldAttrs: {
  pname = "vscode-insiders";
  version = "latest";
  isInsiders = true;
  inherit src;

  buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 pkgs.libsoup_3 pkgs.webkitgtk_4_1 ];

  meta = oldAttrs.meta // {
    mainProgram = "code-insiders";
  };
})