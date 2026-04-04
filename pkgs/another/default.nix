{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}:

let
  pname = "another";
  version = "0.3.0";

  src = fetchurl {
    url = "https://github.com/Zfinix/another/releases/download/v${version}/Another_${version}_amd64.AppImage";
    hash = "sha256-R9gnSZRnrorg2qzXDRFlsuuQa3YHdA0Y8g40EpEAm7g=";
  };

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Another";
    comment = "Android mirroring and control app";
    exec = "another";
    categories = [
      "Utility"
    ];
    terminal = false;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop
  '';

  meta = {
    description = "Desktop app for mirroring and controlling Android devices";
    homepage = "https://github.com/Zfinix/another";
    license = lib.licenses.mit;
    mainProgram = "another";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
