{ config, lib, ... }:
let
  cfg = config.blitz.quiet-boot;
in
{
  options.blitz.quiet-boot = {
    enable = lib.mkEnableOption "quiet boot";
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.verbose = false;
    boot.consoleLogLevel = 3;

    boot.kernelParams = [
      "quiet"
      "udev.log_level=3"
    ];

    boot.initrd.systemd.enable = true;
    boot.plymouth.enable = true;

  };
}
