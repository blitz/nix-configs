{ config, pkgs, lib, ... }:

{
  nix = {
    trustedUsers = [ "root" "julian" ];

    package = pkgs.nix_2_4;
    extraOptions = ''
      experimental-features = nix-command flakes

      # This is for direnv.
      keep-outputs = true
      keep-derivations = true
    '';
  };

  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  nixpkgs.overlays = [
    (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; } )
  ];

  # Living on the edge.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "mitigations=off" ];

  # Don't accumulate crap.
  boot.cleanTmpDir = true;
  services.journald.extraConfig = ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';
  nix.gc.automatic = true;
  nix.optimise.automatic = true;

  # Swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  services.chrony.enable = true;

  console.useXkbConfig = true;

  # Microcode / Firmware Update
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  # Package Overlay
  nixpkgs.config.allowUnfree = true;

  services.resolved.enable = true;
  services.tailscale.enable = true;

  # Shell
  environment.variables = {
    EDITOR = pkgs.lib.mkOverride 0 "${pkgs.zile}/bin/zile";
  };
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;

    ohMyZsh = {
      enable = true;
      # Adding tmux here will make programs.tmux ineffective.
      plugins = [ "git" "sudo" ];
    };

    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';
    shellInit = ''
      eval "$(direnv hook zsh)"
    '';
  };

  programs.tmux = {
    enable = true;
    clock24 = true;

    extraConfig = ''
      set -g @tmux_power_theme 'snow'
      run-shell "${pkgs.tmuxPlugins.power-theme}/share/tmux-plugins/power/tmux-power.tmux"
    '';
  };

  programs.htop.enable = true;

  environment.systemPackages = with pkgs; [
    bc
    bind
    cachix
    dmidecode
    dstat
    file
    gitFull
    gnupg
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
    nethack

    direnv
    nix-direnv
  ];

  documentation.man.enable = true;
  documentation.dev.enable = true;
  documentation.enable = true;

  users.mutableUsers = false;
  users.users.julian = {
    description = "Julian Stecklina";
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "kvm" "networkmanager" "dialout" "libvirtd" "docker" ];
    createHome = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErZm6k0S7NahikKEbTQlrOrsLKgr9X+iNoUsGeqDV0F julian@canaan.xn--pl-wia.net"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJWNk2GL46dwZVuHce8r3CbEmsZiUsnfuGlOVkRLJHnL julian@first-temple"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdmNCi+XT6V9hrvJMHbnQfGY23zcHfnxjqaq4ZG3k27 julian@second-temple"
    ];

    hashedPassword = "$6$d4Q85PrE$m/mrZqoe6R4oi.2NHoB6gJicQr85yKtnmZBXUeyap7KPGKCp9SLqfPOprY12cJtjCcM3bsXTUVzS3O6n8VNTx0";
  };
}
