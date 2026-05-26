{ pkgs, lib, fetchurl }:

let
  inherit (pkgs) stdenv;

  sysAttrs =
    if stdenv.hostPlatform.isDarwin then
      if stdenv.hostPlatform.isAarch64 then {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=darwin-arm64-dmg";
        sha256 = "sha256-K+U6JtVNz1PRzL/0SIEK7RXwQu6LL3p+248Ywbn+mDc=";
      } else {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=darwin-x64-dmg";
        sha256 = "sha256-ex0ESS9APZxgc7b96Q7EQbckUXE51LmTqDfsnN07W3I=";
      }
    else {
      url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
      sha256 = "sha256-kE99FyilwwFv3zTCkufGwD3s1WwoJ2krg10l3Xy5PRE=";
    };

  src = fetchurl {
    inherit (sysAttrs) url sha256;
  };

in

(pkgs.vscode.override {
  isInsiders = true;
}).overrideAttrs (oldAttrs: {
  pname = "vscode-insiders";
  version = "1.122.0-insider";

  inherit src;

  buildInputs =
    (oldAttrs.buildInputs or [])
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      pkgs.krb5
      pkgs.libsoup_3
      pkgs.webkitgtk_4_1
    ];

  prePatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    ${oldAttrs.prePatch or ""}

    mkdir -p resources/app/node_modules/@vscode/ripgrep/bin
    touch resources/app/node_modules/@vscode/ripgrep/bin/rg
  '';

  preFixup =
    if stdenv.hostPlatform.isDarwin then ''
      ${oldAttrs.preFixup or ""}
    '' else ''
      ${oldAttrs.preFixup or ""}

      rm -rf resources/app/node_modules/@github/copilot-linuxmusl-x64
    '';

  meta = (oldAttrs.meta or {}) // {
    mainProgram = "code-insiders";
  };
})