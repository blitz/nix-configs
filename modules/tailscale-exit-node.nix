{ pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };
}
