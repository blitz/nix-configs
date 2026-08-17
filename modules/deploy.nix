{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.blitz.deploy;
in
{
  options.blitz.deploy = {
    enable = lib.mkEnableOption "blitz-deploy";

    operation = lib.mkOption {
      type = lib.types.enum [
        "boot"
        "switch"
      ];
      description = "Description of the option.";
    };

    repo = lib.mkOption {
      type = lib.types.str;
      description = "The repo in a format that blitz-deploy understands";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.system.autoUpgrade.enable;
        message = "blitz-deploy conflicts with autoUpgrade";
      }
    ];

    systemd.timers."blitz-deploy" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        Unit = "blitz-deploy.service";
      };
    };

    systemd.services."blitz-deploy" = {
      description = "Automatic Updates";

      # blitz-deploy uses the Nix CLI to realize store paths.
      path = [
        config.nix.package
        config.system.build.nixos-rebuild
      ];

      serviceConfig =
        let
          blitz-deploy = pkgs.callPackage ../pkgs/blitz-deploy { };
        in
        {
          ExecStart = "${lib.getExe blitz-deploy} --project '${cfg.repo}' '${cfg.operation}'";
          Type = "oneshot";
          User = "root";

          After = "network-online.target";
          Wants = "network-online.target";

          Restart = "on-failure";
          RestartSec = 600;
        };
    };
  };
}
