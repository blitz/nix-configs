{ ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";

    # https://github.com/tailscale/tailscale/issues/16966
    # https://github.com/NixOS/nixpkgs/issues/438765
    #
    # Should be gone after a kernel update.
    package = pkgs.tailscale.overrideAttrs { doCheck = false; };
  };
}
