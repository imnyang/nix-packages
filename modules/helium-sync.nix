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

    package = lib.mkPackageOption pkgs "helium-sync" { };

    heliumDir = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.config/net.imput.helium";
      description = "Path to the Helium browser config directory. Supports shell variables.";
    };

    s3Bucket = lib.mkOption { type = lib.types.str; };
    s3Region = lib.mkOption { type = lib.types.str; default = "us-east-1"; };
    s3Endpoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional custom S3 endpoint (e.g. for R2 or MinIO).";
    };

    awsProfile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "default";
      description = "AWS profile name. Set to null to use explicit access/secret keys.";
    };

    s3AccessKey = lib.mkOption { type = lib.types.str; default = ""; };
    s3SecretKey = lib.mkOption { type = lib.types.str; default = ""; };

    syncProfiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "Default" ];
      description = "List of profile names to synchronize.";
    };

    syncIntervalMinutes = lib.mkOption { type = lib.types.ints.positive; default = 15; };
    logLevel = lib.mkOption {
      type = lib.types.enum [ "debug" "info" "warn" "error" ];
      default = "info";
    };
    sseS3 = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf cfg.enable {
    # Make helium-sync available in the user environment
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.helium-sync = {
      description = "Helium browser profile sync (one-shot)";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        # Write config before every sync so changes take effect immediately
        ExecStartPre = "${setupScript}";
        ExecStart = "${lib.getExe cfg.package} sync --background";
        Nice = 19;
        IOSchedulingClass = "idle";
        MemoryMax = "100M";
        CPUQuota = "25%";
      };
    };

    systemd.user.timers.helium-sync = {
      description = "Helium browser profile sync timer";
      after = [ "network-online.target" ];
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "${toString cfg.syncIntervalMinutes}min";
        Persistent = true;
        RandomizedDelaySec = "30s";
      };
    };
  };
}
