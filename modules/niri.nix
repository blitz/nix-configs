{ pkgs, ... }: {
  programs.niri.enable = true;

  # These are used by default in Niri.
  environment.systemPackages = with pkgs; [
    # Used by the default config.
    fuzzel
    alacritty

    # Notifications
    mako

    # Lock screen/idle
    swaylock
    swayidle

    # To get a useful tray bar.
    waybar
    pavucontrol
  ];
}
