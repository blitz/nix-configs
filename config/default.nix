{ config, pkgs, ... }:

let jsOverlay = import ../overlay;
in {

  # Living on the edge.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";
  services.chrony.enable = true;

  i18n = {
    consoleFont = "Lat2-Terminus16";
    defaultLocale = "en_US.UTF-8";
    consoleUseXkbConfig = true;
  };

  environment.variables = {
    EDITOR = pkgs.lib.mkOverride 0 "${pkgs.zile}/bin/zile";
  };

  # Yubikey
  services.udev.packages = [ pkgs.libu2f-host ];
  services.pcscd.enable = true;

  # Package Overlay
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    jsOverlay
  ];

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
    emacs
    file
    git
    gparted
    nixfmt
  ];
}
