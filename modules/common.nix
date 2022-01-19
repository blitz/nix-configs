{ config, pkgs, lib, ... }:

let
  jsOverlay = import ../overlay;

  hostName = config.networking.hostName;

  domain = config.networking.domain;
in {
  nix = {
    trustedUsers = [ "root" "julian" ];

    package = pkgs.nix_2_4;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Living on the edge.
  boot.kernelParams = [ "mitigations=off" ];

  boot.cleanTmpDir = true;
  services.journald.extraConfig = ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  services.chrony.enable = true;

  console.font = "Lat2-Terminus16";
  console.useXkbConfig = true;

  environment.variables = {
    EDITOR = pkgs.lib.mkOverride 0 "${pkgs.zile}/bin/zile";
  };

  # Firmware Update
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  # Package Overlay
  nixpkgs.config.allowUnfree = true;

  # Workaround for https://github.com/NixOS/nixpkgs/issues/10183
  # networking.extraHosts = ''
  #   127.0.0.1 ${hostName}.${domain} ${hostName}
  #   ::1 ${hostName}.${domain} ${hostName}
  #  '';
  services.resolved.enable = true;
  #services.nscd.enable = true;

  services.tailscale.enable = true;

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" "sudo" ];
  };
  programs.zsh.promptInit = ''
    eval "$(${pkgs.starship}/bin/starship init zsh)"
  '';
  programs.zsh.shellInit = ''
    eval "$(direnv hook zsh)"
  '';
  nix.gc.automatic = true;
  nix.optimise.automatic = true;

  programs.tmux = {
    enable = true;
    clock24 = true;

    extraConfig = ''
      set -g @tmux_power_theme 'snow'
      run-shell "${pkgs.tmuxPlugins.power-theme}/share/tmux-plugins/power/tmux-power.tmux"
    '';
  };

  environment.systemPackages = with pkgs; [
    bc
    bind
    cachix
    dmidecode
    dstat
    file
    gitFull
    gnupg
    htop
    inetutils
    libarchive
    man-pages
    nix-top
    nmap
    parted
    pciutils
    psmisc
    pv
    pwgen
    tig
    usbutils
    wget
    zile
    lm_sensors
    magic-wormhole

    direnv
    nix-direnv
  ];

  documentation.man.enable = true;
  documentation.dev.enable = true;
  documentation.enable = true;
}
