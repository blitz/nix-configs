{ config, pkgs, ... }:
let
  emacsWithPackages = (pkgs.emacsPackagesNgGen pkgs.emacs).emacsWithPackages;
in
{
  # For video loopback in OBS Studio
  # boot.extraModulePackages = with config.boot.kernelPackages;
  #   [ v4l2loopback ];

  # Yubikey / GPG
  services.udev.packages = [ pkgs.libu2f-host pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  programs = {
    # ssh.startAgent = false;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    #steam.enable = true;
  };

  # Flatpak
  #services.flatpak.enable = true;

  # Direnv
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  #virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
    chromium
    mpv
    element-desktop
    signal-desktop
    deja-dup
    gnome3.gnome-tweaks
    gnome3.gnome-usage
    gnome3.gnome-boxes
    gnome3.gnome-session
    pkgs.spice-gtk
    gitAndTools.gh
    gparted
    nixpkgs-fmt
    okular
    gimp
    #obs-studio
    #obs-v4l2sink # This needs manual configuration to work :(

    # Emacs
    (emacsWithPackages
      (epkgs: (with epkgs.melpaPackages;
      [
        cmake-mode
        dante
        dhall-mode
        direnv
        flymake-hlint
        haskell-mode
        hlint-refactor
        magit
        markdown-mode
        nasm-mode
        nix-mode
        use-package
        yaml-mode
        lsp-mode
        lsp-haskell
        lsp-ui
        rustic
      ])))

    # Haskell dev
    # ghc
    # haskellPackages.haskell-language-server
    # stack
    # stylish-cabal
    # stylish-haskell

    # Rust dev
    rustup

    # ULX3S
    # fujprog

    # Terminal recording
    asciinema
  ];

  fonts = {
    fontDir = {
      enable = true;
    };

    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      dina-font
      freefont_ttf
      liberation_ttf
      mplus-outline-fonts
      nerdfonts
    ];
  };

  # For GNOME Boxes
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  # https://github.com/NixOS/nixpkgs/issues/60594
  security.wrappers.spice-client-glib-usb-acl-helper.source = "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";

  networking.firewall.enable = false;

  # Swap
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  # Enable sound.
  sound.enable = true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };


  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xkbOptions = "ctrl:nocaps";

  # Enable touchpad support.
  hardware.trackpoint.enable = false;
  services.xserver.libinput.enable = true;

  # Enable the Gnome3.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.gvfs.enable = true;

  services.avahi = {
    enable = true;

    # Needs nscd
    nssmdns = true;

    publish = {
      enable = true;
      workstation = true;
    };
  };

  hardware.opengl.enable = true;

  users.users.julian = {
    description = "Julian Stecklina";
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "kvm" "networkmanager" "dialout" "libvirtd" ];
    createHome = true;
  };
}
