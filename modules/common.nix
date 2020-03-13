{ config, pkgs, ... }:

let jsOverlay = import ../overlay;
in {

  # The specific direnv version is required for lorri.
  imports = [ ./direnv.nix ];
  
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
  services.fwupd.enable = true;

  # Package Overlay
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ jsOverlay ];

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" "sudo" "tmux" ];
  };
  programs.zsh.promptInit =
    "source ${pkgs.zsh-powerlevel9k}/share/zsh-powerlevel9k/powerlevel9k.zsh-theme";

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
  ];
}
