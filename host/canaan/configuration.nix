{ config, pkgs, ... }:

{
  imports = [
    ../../modules/laptop.nix
    #../../modules/obs-studio.nix
    ../../modules/cachix.nix
    ../../modules/nixbuild.nix
    ../../modules/rust-dev.nix
    #../../modules/games.nix
  ];

  nixpkgs.overlays = [
    (final: prev:
      let
        valgrind = prev.valgrind.overrideAttrs (attrs: {
          patches = attrs.patches ++ [
            (prev.fetchurl {
              url = "https://github.com/jtojnar/nixpkgs/raw/4fc9bb0d8cfad756eb929acd3be92a7019f8ef97/pkgs/development/tools/analysis/valgrind/Support-NIX_DEBUG_INFO_DIRS.patch";
              hash = "sha256-kd7azMA00Kd+f8RWPYAS2bMEXB6xlhwL2yeTqDaAiQ8=";
            })
          ];
        });
      in {
        gnome = prev.gnome.overrideScope' (gfinal: gprev: {
          gnome-session = gprev.gnome-session.overrideAttrs (attrs: {
            preFixup = ''
            # Also replaces the wrapper creation from original preFixup
            substituteInPlace "$out/bin/gnome-session" \
              --replace "$out/libexec/gnome-session-binary" "${prev.coreutils}/bin/env XDG_DATA_DIRS=$out/share:$GSETTINGS_SCHEMAS_PATH:${gprev.gnome-shell}/share:\$XDG_DATA_DIRS XDG_CONFIG_DIRS=${gprev.gnome-settings-daemon}/etc/xdg:\$XDG_CONFIG_DIRS NIX_DEBUG_INFO_DIRS=$debug/lib/debug:${prev.glib.debug}/lib/debug ${valgrind}/bin/valgrind --leak-check=full --error-exitcode=1 $out/libexec/gnome-session-binary"
          '';
          });
        });
      })
  ];
  
  # Session restart debug
  services.xserver.displayManager.gdm.debug = true;
  services.xserver.desktopManager.gnome.debug = true;
  
  environment.enableDebugInfo = true;
  environment.systemPackages = [
    # Explicitly install to get debug symbols.
    pkgs.gnome.gnome-shell
    pkgs.gnome.mutter
    pkgs.gnome.gnome-session
    pkgs.glib
    pkgs.gjs
    pkgs.spidermonkey_102
  ];

  # Quiet boot
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet" "udev.log_level=3"

    # Force use of the thinkpad_acpi driver for backlight control.
    # This allows the backlight save/load systemd service to work.
    "acpi_backlight=native"
  ] ;

  boot.initrd.systemd.enable = true;
  boot.plymouth.enable = true;
  hardware.amdgpu.loadInInitrd = true;
  hardware.amdgpu.opencl = true;

  # Who doesn't like fast virtualization.
  boot.extraModprobeConfig = ''
    options kvm-amd avic=1
  '';

  powerManagement.powertop.enable = true;

  # For building Raspberry Pi system images. Disabled for now, because
  # we have nixbuild.net.
  #
  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.thinkfan = {
    enable = true;
    levels = [
      [0  0   55]
      [1  50  65]
      [2  60  68]
      [3  65  72]
      [4  67  75]
      [5  68  78]
      [6  69  79]
      [7  70  80]
      [127 78 32767]
    ];

    # Disble bias because it causes annoying spinups of the fan.
    extraArgs = [ "-b" "0" ];
    #sensors = "tp_thermal /proc/acpi/ibm/thermal";
  };

  services.power-profiles-daemon.enable = true;

  # Use the systemd-boot EFI boot loader.

  # XXX Disabled for lanzaboote.
  boot.loader.systemd-boot.enable = false;

  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "canaan";
  networking.domain = "localhost";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
