{ pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };
}
