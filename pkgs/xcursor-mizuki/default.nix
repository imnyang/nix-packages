{ stdenv }:

stdenv.mkDerivation rec {
  name = "xcursor-mizuki";
  version = "1.0.0";

  src = ./xcursor-mizuki.tar.gz;

  installPhase = ''
    runHook preInstall

    install -dm 0755 $out/share/icons/xcursor-mizuki

    cp -rf . $out/share/icons/xcursor-mizuki

    runHook postInstall
  '';
  meta = {
    description = "Mizuki cursor";
    homepage = "https://l9525.booth.pm/items/3905447";
  };
}