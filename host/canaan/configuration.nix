{ config, pkgs, ... }:

{
  imports = [
    ../../modules/laptop.nix
    ../../modules/obs-studio.nix
    ../../modules/cachix.nix
    ../../modules/nixbuild.nix
    ../../modules/rust-dev.nix
  ];

  boot.extraModprobeConfig = ''
    options kvm-amd avic=1
  '';

  boot.kernelParams = [
    # Force use of the thinkpad_acpi driver for backlight control.
    # This allows the backlight save/load systemd service to work.
    "acpi_backlight=native"
  ];

  nixpkgs.overlays = [
    (self: super: {
      linuxPackages_latest = super.linuxPackagesFor (super.linuxPackages_latest.kernel.override {
        argsOverride = {
          src = pkgs.fetchFromGitHub {
            owner = "torvalds";
            repo = "linux";
            rev = "754e0b0e35608ed5206d6a67a791563c631cec07";
            sha256 = "JYEYI6b3BQQlWNNdw54+VPeu8pGOonyxkg7jveuJVgk=";
          };
          version = "5.17-rc4";
          modDirVersion = "5.17.0-rc4";
        };
      });
    })
  ];

  boot.kernelPatches = [
    {
      name = "amd-tsc-calibration";

      # This is a workaround to fix the TSC calibration.
      #
      # https://bugzilla.kernel.org/show_bug.cgi?id=202525
      # https://bugzilla.kernel.org/show_bug.cgi?id=208887
      patch = ../../patches/linux/amd-tsc-calibration-workaround.patch;
    }

    {
      name = "amd-cppc";
      patch = null;
      extraConfig = ''
        X86_AMD_PSTATE y
      '';
    }
  ];

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

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "canaan";
  networking.domain = "localhost";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
