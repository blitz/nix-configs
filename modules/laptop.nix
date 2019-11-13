{ config, pkgs, ... }: {
  # Yubikey / GPG
  services.udev.packages = [ pkgs.libu2f-host pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  programs = {
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

  environment.systemPackages = with pkgs; [
    firefox-wayland
    mpv
    riot-desktop
    gnome3.evolution
    gnome3.gnome-documents
    gnome3.gnome-tweaks
    gnome3.gnome-usage
    gnome3.vinagre
    emacs
    gparted
    nixfmt
    okular
    gimp
  ];

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      noto-fonts
      freefont_ttf
      powerline-fonts
      terminus_font
    ];
  };

  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi.enable = false;
  services.avahi.nssmdns = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.workstation = true;
  services.printing.drivers = [ pkgs.brlaser ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xkbOptions = "ctrl:nocaps";

  # Enable touchpad support.
  hardware.trackpoint.enable = false;
  services.xserver.libinput.enable = true;

  # Enable the Gnome3.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.gvfs.enable = true;
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.opengl.enable = true;

  users.users.julian = {
    description = "Julian Stecklina";
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "kvm" "networkmanager" "dialout" ];
    createHome = true;
  };
}
