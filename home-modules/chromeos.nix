{ pkgs, ... }: {
  imports = [
    ./common.nix
  ];

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

  programs.emacs.package = pkgs.emacs30-nox;

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
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
  home.username = "blitz";
  home.homeDirectory = "/home/blitz";
}
