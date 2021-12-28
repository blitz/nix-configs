{ config, pkgs, ... }:

{
  boot.extraModprobeConfig = ''
    options kvm-amd avic=1
  '';

  # boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linuxPackages_5_15.kernel.override {
    argsOverride = {
      src = pkgs.fetchurl {
        url = "https://github.com/blitz/linux/archive/refs/heads/v5.16-amd-acpi.tar.gz";
        sha256 = "sha256-V0+u+xe1+kvktvVil0kHEjSaSHNxHIYgOjsXIHO0bsY=";
      };
      version = "5.16-rc7";
      modDirVersion = "5.16.0-rc7";
    };
  });

  boot.kernelPatches = [
    {
      name = "amd-cppc";
      patch = null;
      extraConfig = ''
        X86_AMD_PSTATE y
      '';
    }
  ];
  
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