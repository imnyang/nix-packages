{ pkgs, lib, fetchurl }:

let
  inherit (pkgs) stdenv;

  sysAttrs =
    if stdenv.hostPlatform.isDarwin then
      if stdenv.hostPlatform.isAarch64 then {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=darwin-arm64-dmg";
        sha256 = "sha256-K+U6JtVNz1PRzL/0SIEK7RXwQu6LL3p+248Ywbn+mDc=";
        name = "vscode-insiders-darwin-arm64.dmg";
      } else {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=darwin-x64-dmg";
        sha256 = "sha256-ex0ESS9APZxgc7b96Q7EQbckUXE51LmTqDfsnN07W3I=";
        name = "vscode-insiders-darwin-x64.dmg";
      }
    else {
      url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
      sha256 = "sha256-kE99FyilwwFv3zTCkufGwD3s1WwoJ2krg10l3Xy5PRE=";
      name = "vscode-insiders-linux-x64.tar.gz";
    };

  src = fetchurl {
    inherit (sysAttrs) url sha256 name;
  };

in

(pkgs.vscode.override {
  isInsiders = true;
}).overrideAttrs (oldAttrs: {
  pname = "vscode-insiders";
  version = "1.122.0-insider";

  inherit src;

  sourceRoot = lib.optionalString stdenv.hostPlatform.isDarwin ".";

  postUnpack = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export sourceRoot="$(ls -d *.app)"
    chmod -R +w "$sourceRoot"
  '';

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [])
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ pkgs.undmg pkgs.darwin.xattr ];

  buildInputs =
    (oldAttrs.buildInputs or [])
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      pkgs.krb5
      pkgs.libsoup_3
      pkgs.webkitgtk_4_1
    ];

  prePatch = if stdenv.hostPlatform.isDarwin then ''
    ${oldAttrs.prePatch or ""}

    mkdir -p Contents/Resources/app/node_modules/@vscode/ripgrep/bin
    touch Contents/Resources/app/node_modules/@vscode/ripgrep/bin/rg
  '' else if stdenv.hostPlatform.isLinux then ''
    ${oldAttrs.prePatch or ""}

    mkdir -p resources/app/node_modules/@vscode/ripgrep/bin
    touch resources/app/node_modules/@vscode/ripgrep/bin/rg
  '' else "";

  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    cp -r . $out/Applications/Visual\ Studio\ Code\ -\ Insiders.app
    
    # Create a wrapper script in bin/ to launch the app
    mkdir -p $out/bin
    cat > $out/bin/code-insiders << 'EOF'
    #!/bin/sh
    exec "$out/Applications/Visual Studio Code - Insiders.app/Contents/MacOS/Electron" "$@"
    EOF
    chmod +x $out/bin/code-insiders
  '';

  preFixup =
    if stdenv.hostPlatform.isDarwin then ''
      ${oldAttrs.preFixup or ""}

      # Fix executable permissions in the app bundle
      chmod +x "Contents/MacOS/Electron"
      find Contents -type f -perm +111 -exec chmod +x {} \;
      
      # Make the app executable for Gatekeeper/notarization checks
      xattr -d com.apple.quarantine . 2>/dev/null || true
    '' else ''
      ${oldAttrs.preFixup or ""}

      rm -rf resources/app/node_modules/@github/copilot-linuxmusl-x64
    '';

  meta = (oldAttrs.meta or {}) // {
    mainProgram = "code-insiders";

  };
})