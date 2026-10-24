{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "figma-linux";
  version = "126.10.10";

  src = fetchurl {
    url = "https://github.com/IliyaBrook/figma-linux/releases/download/${version}/figma-desktop-${version}-amd64.AppImage";
    hash = "sha256-Qc1VIbRsVse91Hb0OtheY7KheoPObkvJkwxF4ZppGxk=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;

    # The upstream AppImage registers an AppImage-specific desktop entry at
    # runtime. That bypasses this package's FHS wrapper when a figma:// URL is
    # opened, so Electron cannot find libraries such as libnspr4.so.
    postExtract = ''
      substituteInPlace $out/AppRun \
        --replace-fail 'integrate_desktop 2>/dev/null || true' \
          'true # Desktop integration is provided by the Nix package'
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/usr/share/applications/io.github.nickvdp.figma-desktop-linux.desktop \
      -t $out/share/applications
    substituteInPlace $out/share/applications/io.github.nickvdp.figma-desktop-linux.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname} %U'

    # The AppImage's runtime desktop integration is disabled above so that
    # figma:// links use this package's FHS wrapper. Register the URI scheme
    # explicitly and pass the callback URL through to Electron.
    if ! grep -q '^MimeType=.*x-scheme-handler/figma' \
      $out/share/applications/io.github.nickvdp.figma-desktop-linux.desktop; then
      substituteInPlace $out/share/applications/io.github.nickvdp.figma-desktop-linux.desktop \
        --replace-fail '[Desktop Entry]' \
          '[Desktop Entry]\nMimeType=x-scheme-handler/figma;'
    fi

    install -Dm444 ${appimageContents}/io.github.nickvdp.figma-desktop-linux.png \
      $out/share/icons/hicolor/256x256/apps/io.github.nickvdp.figma-desktop-linux.png
  '';

  extraPkgs = pkgs: with pkgs; [
    libappindicator-gtk3
    libnotify
    libsecret
  ];

  meta = {
    description = "Figma Desktop for Linux";
    homepage = "https://github.com/IliyaBrook/figma-linux";
    license = lib.licenses.unfree;
    mainProgram = "figma-linux";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
