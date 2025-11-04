{ pkgs, ... }: {
  programs.niri.enable = true;

  # These are used by default in Niri.
  environment.systemPackages = with pkgs; [
    fuzzel
    alacritty
  ];
}
