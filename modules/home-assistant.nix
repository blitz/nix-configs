{ config, pkgs, ... }:
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "met"
      "radio_browser"
      "zha"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
    };
  };
}
