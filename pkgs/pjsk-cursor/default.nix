{ stdenv }:

let
  homepage = "https://colorfulstage.com/media/download/";

  mkCursor = { name, src }:
    stdenv.mkDerivation rec {
      inherit name src;
      version = "1.0.0";

      installPhase = ''
        runHook preInstall

        install -dm 0755 $out/share/icons/${name}

        cp -rf . $out/share/icons/${name}

        runHook postInstall
      '';

      meta = {
        description = "Project Sekai cursor theme";
        inherit homepage;
      };
    };

  makeVariant = group: character:
    {
      ani = mkCursor {
        name = "pjsk-cursor-${group}-${character}-ani";
        src = ../../assets/${group}-${character}-ani.tar.gz;
      };

      cur = mkCursor {
        name = "pjsk-cursor-${group}-${character}-cur";
        src = ../../assets/${group}-${character}-cur.tar.gz;
      };
    };

  makeGroup = group: characters:
    builtins.listToAttrs (map (character: {
      name = character;
      value = makeVariant group character;
    }) characters);
in
{
  leoneed = makeGroup "leoneed" [
    "honami"
    "ichika"
    "miku"
    "saki"
    "shiho"
  ];

  mmj = makeGroup "mmj" [
    "airi"
    "haruka"
    "miku"
    "minori"
    "shizuku"
  ];

  n25 = makeGroup "n25" [
    "ena"
    "kanade"
    "mafuyu"
    "miku"
    "mizuki"
  ];

  vbs = makeGroup "vbs" [
    "akito"
    "an"
    "kohane"
    "miku"
    "toya"
  ];

  virtualsinger = makeGroup "virtualsinger" [
    "kaito"
    "len"
    "luka"
    "meiko"
    "miku"
    "rin"
  ];

  wxs = makeGroup "wxs" [
    "emu"
    "miku"
    "nene"
    "rui"
    "tsukasa"
  ];
}