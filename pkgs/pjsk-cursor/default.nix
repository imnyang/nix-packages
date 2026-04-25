{
  lib,
  stdenv,
  symlinkJoin,
}:

let
  homepage = "https://colorfulstage.com/media/download/";
  pnameBase = "pjsk-cursor";
  version = "1.0.0";

  meta = {
    description = "Project Sekai cursor theme";
    inherit homepage;
  };

  mkCursor =
    { pname, src }:
    stdenv.mkDerivation {
      inherit
        pname
        src
        version
        meta
        ;

      installPhase = ''
        runHook preInstall

        install -dm 0755 $out/share/icons/${pname}

        cp -rf . $out/share/icons/${pname}

        runHook postInstall
      '';

    };

  makeVariant =
    group: character:
    let
      pnameVariant = "${pnameBase}-${group}-${character}";
      variants = {
        ani = mkCursor {
          pname = "${pnameVariant}-ani";
          src = ../../assets/${group}-${character}-ani.tar.gz;
        };

        cur = mkCursor {
          pname = "${pnameVariant}-cur";
          src = ../../assets/${group}-${character}-cur.tar.gz;
        };
      };
    in
    symlinkJoin {
      pname = pnameVariant;
      inherit version meta;

      paths = lib.attrsets.attrValues variants;
      passthru = variants;
    };

  makeGroup =
    group: characters:
    let
      pname = "${pnameBase}-${group}";
      cursors = builtins.listToAttrs (
        map (character: {
          name = character;
          value = makeVariant group character;
        }) characters
      );

      mkCursorVariantJoin =
        pname: selector:
        symlinkJoin {
          inherit pname version meta;

          paths = lib.mapAttrsToList (name: selector) cursors;
        };

    in
    symlinkJoin {
      inherit pname version meta;

      paths = lib.attrsets.attrValues cursors;
      passthru = cursors // {
        cur = mkCursorVariantJoin "${pname}-cur" (cursor: cursor.cur);
        ani = mkCursorVariantJoin "${pname}-ani" (cursor: cursor.ani);
      };
    };
  groups = {
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
  };

  mkGroupVariantJoin =
    pname: selector:
    symlinkJoin {
      inherit pname version meta;

      paths = lib.mapAttrsToList (name: selector) groups;
    };
in
symlinkJoin {
  pname = pnameBase;
  inherit version meta;
  paths = lib.attrsets.attrValues groups;
  passthru = groups // {
    cur = mkGroupVariantJoin "${pnameBase}-cur" (group: group.cur);
    ani = mkGroupVariantJoin "${pnameBase}-ani" (group: group.ani);
  };
}
