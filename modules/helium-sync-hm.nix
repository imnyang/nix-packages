{ config, lib, pkgs, ... }:

let
  cfg = config.services.helium-sync;

  setupScript = pkgs.writeShellScript "helium-sync-write-config" ''
    CONFIG_DIR="$HOME/.config/helium-sync"
    mkdir -p "$CONFIG_DIR"
    chmod 700 "$CONFIG_DIR"

    DEVICE_ID_FILE="$CONFIG_DIR/device_id"
    if [ ! -f "$DEVICE_ID_FILE" ]; then
      cat /proc/sys/kernel/random/uuid > "$DEVICE_ID_FILE"
      chmod 600 "$DEVICE_ID_FILE"
    fi

    cat > "$CONFIG_DIR/config.json" << EOF
{
  "helium_dir": "__HELIUM_DIR__",
  "s3_bucket": "${cfg.s3Bucket}",
  "s3_region": "${cfg.s3Region}",
  ${lib.optionalString (cfg.s3Endpoint != null) "\"s3_endpoint\": \"${cfg.s3Endpoint}\","}
  ${if cfg.awsProfile != null then ''
    "aws_profile": "${cfg.awsProfile}",
  '' else ''
    "s3_access_key": "${cfg.s3AccessKey}",
    "s3_secret_key": "${cfg.s3SecretKey}",
  ''}
  "sync_interval_minutes": ${toString cfg.syncIntervalMinutes},
  "sync_profiles": ${builtins.toJSON cfg.syncProfiles},
  "log_level": "${cfg.logLevel}",
  "sse_s3": ${if cfg.sseS3 then "true" else "false"}
}
EOF
    sed -i "s|__HELIUM_DIR__|${cfg.heliumDir}|g" "$CONFIG_DIR/config.json"
    chmod 600 "$CONFIG_DIR/config.json"
  '';
in
{
  options.services.helium-sync = {
    enable = lib.mkEnableOption "Helium browser profile synchronisation";

    # pkgs.helium-sync가 이미 정의되어 있다고 가정하거나 직접 지정
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.helium-sync;
      description = "Helium sync package to use.";
    };

    heliumDir = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.config/net.imput.helium";
      description = "Path to the Helium browser config directory.";
    };

    s3Bucket = lib.mkOption { type = lib.types.str; };
    s3Region = lib.mkOption { type = lib.types.str; default = "us-east-1"; };
    s3Endpoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    awsProfile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "default";
    };

    s3AccessKey = lib.mkOption { type = lib.types.str; default = ""; };
    s3SecretKey = lib.mkOption { type = lib.types.str; default = ""; };

    syncProfiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "Default" ];
    };

    syncIntervalMinutes = lib.mkOption { type = lib.types.ints.positive; default = 15; };
    logLevel = lib.mkOption {
      type = lib.types.enum [ "debug" "info" "warn" "error" ];
      default = "info";
    };
    sseS3 = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf cfg.enable {
    # Home Manager 스타일의 패키지 추가
    home.packages = [ cfg.package ];

    # Home Manager의 systemd 서비스 설정
    systemd.user.services.helium-sync = {
      Unit = {
        Description = "Helium browser profile sync (one-shot)";
        After = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStartPre = "${setupScript}";
        ExecStart = "${lib.getExe cfg.package} sync --background";
        Nice = 19;
        IOSchedulingClass = "idle";
        MemoryMax = "100M";
        CPUQuota = "25%";
      };
    };

    systemd.user.timers.helium-sync = {
      Unit = {
        Description = "Helium browser profile sync timer";
      };
      Timer = {
        OnBootSec = "2min";
        OnUnitActiveSec = "${toString cfg.syncIntervalMinutes}min";
        Persistent = true;
        RandomizedDelaySec = "30s";
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
