{
  pkgs,
  commandLineArgs ? [ ],
  enableFeatures ? [ ],
  libvaSupport ? pkgs.stdenv.hostPlatform.isLinux,
  widevineSupport ? false,
}:
pkgs.appimageTools.wrapType2 rec {

  pname = "helium";
  version = "0.11.5.1";

  src = pkgs.fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/${pname}-${version}-x86_64.AppImage";
    sha256 = "sha256-Ni7IZ9UBafr+ss0BcQaRKqmlmJI4IV1jRAJ8jhcodlg=";
  };

  _enableFeatures =
    enableFeatures
    ++ pkgs.lib.optionals libvaSupport [
      "VaapiVideoDecoder"
    ];

  extraPkgs = pkgs: pkgs.lib.optionals libvaSupport [ pkgs.libva ];

  extraBwrapArgs = [
    "--ro-bind-try /etc/chromium /etc/chromium"
  ];

  nativeBuildInputs = [ pkgs.makeWrapper ];

  extraInstallCommands =
    let
      contents = pkgs.appimageTools.extract { inherit pname version src; };
    in
    ''
      wrapProgram $out/bin/${pname} \
        ${
          pkgs.lib.optionalString (
            _enableFeatures != [ ]
          ) "--add-flags \"--enable-features=${pkgs.lib.strings.concatStringsSep "," _enableFeatures}\""
        } \
        ${pkgs.lib.optionalString (
          commandLineArgs != [ ]
        ) "--add-flags \"${pkgs.lib.strings.concatStringsSep " " commandLineArgs}\""} \
        ${pkgs.lib.optionalString widevineSupport ''
          --run "mkdir -p ~/.config/net.imput.helium/WidevineCdm" \
          --run "echo '{\"Path\":\"${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm\"}' > ~/.config/net.imput.helium/WidevineCdm/latest-component-updated-widevine-cdm"
        ''}
      install -m 444 -D ${contents}/${pname}.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'
      cp -r ${contents}/usr/share/icons $out/share
    '';

}
