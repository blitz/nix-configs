{ config, pkgs, ... }:

let
  jsOverlay = import ../overlay;

  hostName = config.networking.hostName;

  domain = config.networking.domain;
in {

  # Direnv
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  nix.trustedUsers = [ "root" "julian" ];

  # Living on the edge.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "mitigations=off" ];

  boot.cleanTmpDir = true;

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
  nixpkgs.overlays = [ jsOverlay ];

  # Workaround for https://github.com/NixOS/nixpkgs/issues/10183
  # networking.extraHosts = ''
  #   127.0.0.1 ${hostName}.${domain} ${hostName}
  #   ::1 ${hostName}.${domain} ${hostName}
  #  '';
  #services.resolved.enable = true;
  #services.nscd.enable = true;

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" "sudo" "tmux" ];
  };
  programs.zsh.promptInit =
    "source ${pkgs.zsh-powerlevel9k}/share/zsh-powerlevel9k/powerlevel9k.zsh-theme";
  programs.zsh.shellInit = ''
    eval "$(direnv hook zsh)"
  '';
  nix.gc.automatic = true;

  environment.systemPackages = with pkgs; [
    bc
    bind
    wget
    zile
    pv
    htop
    dstat
    tmux
    git
    gnupg
    tig
    nix-top
    file
    git
    parted
    usbutils
    pciutils
    libarchive
    psmisc
    nmap
    inetutils
    man-pages
    pwgen
    dmidecode

    direnv
    nix-direnv
  ];

  documentation.man.enable = true;
  documentation.dev.enable = true;
  documentation.enable = true;
}
