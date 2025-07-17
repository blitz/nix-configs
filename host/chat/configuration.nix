{ lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect

    ../../modules/common.nix
    ../../modules/tailscale-exit-node.nix
    ../../modules/cachix.nix
    ../../modules/matrix-synapse.nix
    #../../modules/matrix-coturn.nix
  ];

  # /boot doesn't have a lot of space.
  boot.loader.grub.configurationLimit = lib.mkForce 2;

  system.autoUpgrade.enable = true;

  networking.hostName = "chat";
  networking.domain = "x86.lol";

  services.openssh.enable = true;

  system.stateVersion = "23.11";
}
