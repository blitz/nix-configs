{
  config,
  lib,
  pkgs,
  ...
}:
{

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
        ExecStart = "${lib.getExe blitz-deploy} --project github:blitz/nix-configs/master boot";
        Type = "oneshot";
        User = "root";

        Wants = "network-online.target";
        After = "network-online.target";
      };
  };
}
