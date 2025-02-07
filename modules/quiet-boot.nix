{
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 3;

  boot.kernelParams = [
    "quiet" "udev.log_level=3"
  ];

  boot.initrd.systemd.enable = true;
  boot.plymouth.enable = true;
}
