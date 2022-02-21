{ config, pkgs, ... }:
let
  emacsWithPackages = (pkgs.emacsPackagesNgGen pkgs.emacs).emacsWithPackages;
in
{
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback video_nr=10 card_label="OBS Video Source" exclusive_caps=1
  '';

  # Yubikey / GPG
  services.udev.packages = [ pkgs.libu2f-host pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  services.gnome.evolution-data-server.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs = {
    evolution = {
      enable = true;
      plugins = [ pkgs.evolution-ews ];
    };

    # ssh.startAgent = false;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    steam = {
      #enable = true;
    };
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
    firefox-wayland
    (chromium.override {
      commandLineArgs = "--enable-features=VaapiVideoDecoder";
    })
    mpv
    element-desktop
    signal-desktop
    deja-dup
    magic-wormhole
    gnome3.gnome-tweaks
    gnome3.gnome-usage
    gnome3.gnome-boxes
    gnome3.gnome-session
    pkgs.spice-gtk
    gitAndTools.gh
    gitAndTools.git-machete
    gparted
    nixpkgs-fmt
    okular
    gimp
    picocom
    delta
    #obs-studio
    #obs-v4l2sink # This needs manual configuration to work :(
    libreoffice-fresh
    kooha                       # screenrecording

    # Emacs
    (emacsWithPackages
      (epkgs: (with epkgs.melpaPackages;
      [
        clang-format
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
    #rustup
    gcc

    # C++ dev
    clang-tools

    # ULX3S
    # fujprog

    # Work
    mattermost-desktop

    # Terminal recording
    asciinema

    # Legacy development
    (pkgs.buildFHSUserEnv {
      name = "legacy-env";
      targetPkgs = pkgs: with pkgs; [
        gcc binutils
        gnumake coreutils patch zlib zlib.dev curl git m4 bison flex acpica-tools
        ncurses.dev
        elfutils.dev
        openssl openssl.dev
        cpio pahole gawk perl bc nettools rsync
        gmp gmp.dev
        libmpc
        mpfr mpfr.dev
        zstd python3Minimal
        file unzip
      ];
    })
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
  # security.wrappers.spice-client-glib-usb-acl-helper.source = "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";

  networking.firewall.enable = false;

  # Swap
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  # Enable sound.
  sound.enable = true;

  security.rtkit.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
    media-session.config.bluez-monitor.rules = [
      {
        # Matches all cards
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            # mSBC is not expected to work on all headset + adapter combinations.
            "bluez5.msbc-support" = true;
            # SBC-XQ is not expected to work on all headset + adapter combinations.
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          # Matches all sources
          { "node.name" = "~bluez_input.*"; }
          # Matches all outputs
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          "node.pause-on-idle" = false;
        };
      }
    ];
  };
  hardware.pulseaudio.enable = false;

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

    # This resets permissions to 0700. :(
    #createHome = true;
  };
}
