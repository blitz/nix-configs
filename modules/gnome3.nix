{ config, pkgs, ... }:
let
  emacsWithPackages = (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages;
in
{
  nixpkgs.overlays = [
    (self: super: {
      gnome = super.gnome // {
        geary = super.gnome.geary.overrideAttrs (old: {
          patches = (old.patches or []) ++ [
            # https://gitlab.gnome.org/GNOME/geary/-/issues/1320
            ../patches/geary/0001-smtp-don-t-use-domain-for-EHLO-if-it-s-not-a-FQDN.patch
          ];
        });
      };

      gnome-console = super.gnome-console.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          # https://gitlab.gnome.org/GNOME/console/-/issues/147
          ../patches/gnome-console/no-audible-bell.patch
        ];
      });
    })
  ];

  # Yubikey / GPG
  services.udev.packages = [ pkgs.libu2f-host pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  programs = {
    geary.enable = true;

    firefox = {
      enable = true;
      package = pkgs.firefox-wayland;
    };
  };

  environment.systemPackages = with pkgs; [

    # AMD GPUs crap their pants with hardware decoding in online meetings.
    #
    # (google-chrome.override {
    #   commandLineArgs = "--ozone-platform-hint=auto --use-gl=egl --enable-features=VaapiVideoDecoder,VaapiVideoEncoder";
    # })
    google-chrome

    mpv
    element-desktop
    signal-desktop
    deja-dup
    gnome3.gnome-tweaks
    gnome3.gnome-boxes
    virt-manager
    gitAndTools.gh
    gparted
    okular
    gimp

    gnomeExtensions.tailscale-status

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
        editorconfig
        toml-mode
        ggtags
        elm-mode
        (epkgs.callPackage ../emacs/promela-mode.nix {})
      ])))

    # Development
    nixpkgs-fmt
    global

    # Elm Development
    elmPackages.elm-format
    elmPackages.elm-language-server
    elmPackages.elm

    # Legacy Coding
    msmtp
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
        global
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
      mplus-outline-fonts.githubRelease
      nerdfonts
    ];
  };

  # For GNOME Boxes
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu.swtpm.enable = true;
    qemu.ovmf.enable = true;
  };
  virtualisation.spiceUSBRedirection.enable = true;

  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  # Enable sound.
  sound.enable = true;

  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;
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
}
