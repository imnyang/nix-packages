{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "helium-sync";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "imnyang";
    repo = "helium-sync";
    rev = "v${version}";
    hash = "sha256-Iml9UjCRN2o7cR+IJR72ujQ8sCW8xjzwhHal3NqpuVo=";
  };

  vendorHash = "sha256-sWi8QV1uMjfgRMATjXb/qCp6IvBQojtLI3Gr2BHS9Hs=";

  subPackages = [ "cmd/helium-sync" ];

  meta = {
    description = "Synchronize selected Helium browser profile data across devices using Amazon S3";
    homepage = "https://github.com/imnyang/helium-sync";
    license = lib.licenses.mit;
    mainProgram = "helium-sync";
  };
}
