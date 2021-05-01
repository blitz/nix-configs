{ config, pkgs, ... }: {

  boot.plymouth = {
    #enable = true;
  };

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  # I use this as a build server at times.
  services.xserver.displayManager.gdm.autoSuspend = false;
}
