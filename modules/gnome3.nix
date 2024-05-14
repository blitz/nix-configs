{ config, pkgs, lib, ... }:
{
  # Yubikey / GPG
  services.udev.packages = [ pkgs.libu2f-host pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  programs = {
    evolution.enable = true;
    virt-manager.enable = true;

    # This is still weird and we end up with lots of 1password processes?
    #
    # _1password.enable = true;
    # _1password-gui.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    # Lots of hardware craps its pants with hardware decoding in online meetings.
    (google-chrome.override {
      commandLineArgs = [
        # https://github.com/NixOS/nixpkgs/issues/306471
        "--enable-features=UseOzonePlatform"

        "--ozone-platform-hint=wayland"
      ]
      ++ (lib.optional (config.networking.hostName == "avalon")
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder");
    })

    mpv
    fractal

    # These can run directly under Wayland as they are Electron apps. See NIXOS_OZONE_WL above.
    signal-desktop
    #drawio

    pika-backup
    gnome3.gnome-tweaks
    gnome3.gnome-boxes
    gparted
    okular
    gimp

    # Change webcam zoom: v4l2-ctl -d /dev/video2 -c zoom_absolute=150
    v4l-utils

    gnomeExtensions.tailscale-status

    # Podcasting and Meetings
    zoom-us
    gnome-network-displays

    # Debugging
    clinfo
    intel-gpu-tools
    radeontop
  ];

  fonts = {
    fontDir = {
      enable = true;
    };

    enableGhostscriptFonts = true;
    packages = with pkgs; [
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

    # For UEFI Secure Boot support.
    qemu.ovmf.enable = true;
    qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
    qemu.runAsRoot = false;

    # For TPM 2.0
    qemu.swtpm.enable = true;
  };

  # USB Passthrough
  virtualisation.spiceUSBRedirection.enable = true;

  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin pkgs.mfcl8690cdwcupswrapper ];

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
