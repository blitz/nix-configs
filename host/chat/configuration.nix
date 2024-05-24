{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect

    ../../modules/common.nix
    ../../modules/tailscale-exit-node.nix
    ../../modules/cachix.nix
    ../../modules/matrix-synapse.nix
    ../../modules/matrix-coturn.nix
  ];

  system.autoUpgrade.enable = true;

  networking.hostName = "chat";
  networking.domain = "x86.lol";

  services.openssh.enable = true;

  system.stateVersion = "23.11";
}
