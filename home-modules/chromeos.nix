{ config, pkgs, lib, ... }: {
  imports = [
    ./common.nix
  ];

  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    gh

    nixpkgs-fmt
    nil
    nix-diff
    nix-tree
    nix-output-monitor
    nixpkgs-review

    rust-analyzer
    cargo
    rustc

    fractal
    gcr                         # Needed for pinentry
  ];

  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  # Workaround gnome-keyring only starting with a graphical session,
  # which we don't have on ChromeOS. Just start it always.
  systemd.user.services.gnome-keyring = {
    Unit.PartOf = lib.mkForce [ "default.target" ];
    Install.WantedBy = lib.mkForce [ "default.target" ];
  };

  nix = {
    package = pkgs.nixVersions.latest;

    settings = {
      max-jobs = 4;

      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      connect-timeout = 5;
      log-lines = 25;
      warn-dirty = false;
      fallback = true;
    };
  };

  programs.emacs.package = pkgs.emacs30;

  programs.tmux = {
    enable = true;
    clock24 = true;

    terminal = "screen-256color";

    plugins = [
      pkgs.tmuxPlugins.power-theme
    ];
  };

  programs.htop.enable = true;

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      # On ChromeOS this will always light up with "[Systemd]".
      container.disabled = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;

  # Make applications visible to ChromeOS:
  # https://nixos.wiki/wiki/Installing_Nix_on_Crostini
  xdg.configFile."systemd/user/cros-garcon.service.d/override.conf".text = ''
    [Service]
    Environment="PATH=%h/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/local/games:/usr/sbin:/usr/bin:/usr/games:/sbin:/bin"
    Environment="XDG_DATA_DIRS=%h/.nix-profile/share:%h/.local/share:%h/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share"
  '';

  home.stateVersion = "24.11";
  home.username = "blitz";
  home.homeDirectory = "/home/blitz";
}
