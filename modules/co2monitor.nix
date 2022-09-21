{ config, pkgs, lib, ... }: {

  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a052", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a052", TAG+="uaccess"
  '';

  services.prometheus = {
    enable = true;

    scrapeConfigs = [
      # {
      #   job_name = "chrysalis";
      #   static_configs = [{
      #     targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
      #   }];
      # }
    ];
  };
}
