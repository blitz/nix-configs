{ config, pkgs, lib, ... }:

{
  nix = {
    settings = {
      trusted-users = [ "root" "julian" ];

      # Does this have performance impact?
      auto-optimise-store = true;
    };

    daemonCPUSchedPolicy = "batch";

    extraOptions = ''
      experimental-features = nix-command flakes

      # This is for direnv.
      keep-outputs = true

      # See https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5
      log-lines = 25
      warn-dirty = false
      fallback = true
    '';
  };

  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  nixpkgs.overlays = [
    (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; } )
  ];

  # TODO Where does this come from?
  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-14.21.3"
    "openssl-1.1.1t"
  ];

  # Living on the edge.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  boot.kernelParams = [ "mitigations=off" ];


  boot.kernelPatches = [
    {
      name = "workaround-nixpkgs-265187";
      patch = null;
      extraStructuredConfig = {
        FRAMEBUFFER_CONSOLE_DETECT_PRIMARY = lib.kernel.yes;
        DRM_FBDEV_EMULATION = lib.kernel.yes;
      };
    }
  ];

  # Make dm-crypt fast in the early boot phases.
  boot.initrd.availableKernelModules = lib.optionals (config.system == "x86_64-linux") [
    "aesni_intel"
    "cryptd"
  ];

  # Don't accumulate crap.
  boot.tmp.cleanOnBoot = true;
  services.journald.extraConfig = ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';
  nix.gc = {
    automatic = true;
    dates = lib.mkDefault "monthly";
  };
  nix.optimise.automatic = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.grub.configurationLimit = 5;

  # Swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # Set your time zone.
  time.timeZone = "Europe/Madrid";
  services.chrony.enable = true;

  console.useXkbConfig = true;

  # Microcode / Firmware Update
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  # Package Overlay
  nixpkgs.config.allowUnfree = true;

  services.resolved = {
    enable = true;

    # This leads to spurious failures?
    dnssec = "false";
  };

  # Needed by tailscale.
  networking.firewall.checkReversePath = "loose";

  # Shell
  environment.variables = {
    EDITOR = pkgs.lib.mkOverride 0 "${pkgs.zile}/bin/zile";
  };
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;

    ohMyZsh = {
      enable = true;
      # Adding tmux here will make programs.tmux ineffective.
      plugins = [ "git" "sudo" ];
    };

    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';
    shellInit = ''
      eval "$(direnv hook zsh)"
    '';
  };

  programs.tmux = {
    enable = true;
    clock24 = true;

    extraConfig = ''
      set -g @tmux_power_theme 'snow'
      run-shell "${pkgs.tmuxPlugins.power-theme}/share/tmux-plugins/power/tmux-power.tmux"
    '';
  };

  programs.htop.enable = true;

  environment.systemPackages = with pkgs; [
    bc
    bind
    cachix
    dmidecode
    dstat
    file
    gitFull
    gnupg
    libarchive
    man-pages
    nix-top
    nmap
    parted
    pciutils
    psmisc
    pv
    pwgen
    tig
    usbutils
    wget
    zile
    lm_sensors
    magic-wormhole
    nethack

    direnv
    nix-direnv
  ];

  documentation.man.enable = true;
  documentation.dev.enable = true;
  documentation.doc.enable = false;
  documentation.enable = true;

  users.mutableUsers = false;
  users.users.julian = {
    description = "Julian Stecklina";
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "kvm" "networkmanager" "dialout" "libvirtd" "docker" ];
    createHome = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErZm6k0S7NahikKEbTQlrOrsLKgr9X+iNoUsGeqDV0F julian@canaan.xn--pl-wia.net"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdmNCi+XT6V9hrvJMHbnQfGY23zcHfnxjqaq4ZG3k27 julian@second-temple"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeIiTyh7jJD9x8N64kgUGDgeo3F96i5Av3tHvwePHq5 julian@babylon"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK64yCNWgpDacHh2QJuA+2k+LoloS5ZfaqIojO5cfBoj julian@ig-11"
    ];

    hashedPassword = "$6$d4Q85PrE$m/mrZqoe6R4oi.2NHoB6gJicQr85yKtnmZBXUeyap7KPGKCp9SLqfPOprY12cJtjCcM3bsXTUVzS3O6n8VNTx0";
  };
}
