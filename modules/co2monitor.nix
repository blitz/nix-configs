{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.co2-exporter;
in {
  options.services.co2-exporter = {
    enable = mkEnableOption "CO2 data exporter";

    package = mkOption {
      type = types.package;
      default = pkgs.co2-exporter;
    };

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = mdDoc ''
        The TCP address (without port number) that the service will
        listen on.
      '';
    };

    port = mkOption {
      type = types.int;
      default = 8012;
      description = mdDoc ''
        The TCP port that the service will listen on.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.udev.extraRules = ''
      KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a052", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a052", TAG+="uaccess"
    '';

    systemd.services.co2-exporter = {
      wantedBy = [ "multi-user.target" ];

      environment = {
        ROCKET_ADDRESS = cfg.address;
        ROCKET_PORT = "${builtins.toString cfg.port}";
      };

      serviceConfig = {
        Type = "exec";
        ExecStart = "${cfg.package}/bin/co2-exporter";
      };
    };

    # This does not really belong here.
    services.prometheus = {
      enable = true;

      scrapeConfigs = [
        {
          job_name = "co2-monitor";
          static_configs = [{
            targets = [ "${cfg.address}:${builtins.toString cfg.port}" ];
          }];
        }
      ];
    };

  };
}
