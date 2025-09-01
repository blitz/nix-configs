{ ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # https://github.com/tailscale/tailscale/issues/16966
  # https://github.com/NixOS/nixpkgs/issues/438765
  #
  # Should be gone after a kernel update.
  nixpkgs.overlays = [
    (_: prev: {
      tailscale = prev.tailscale.overrideAttrs (old: {
        checkFlags =
          builtins.map (
            flag:
            if prev.lib.hasPrefix "-skip=" flag
            then flag + "|^TestGetList$|^TestIgnoreLocallyBoundPorts$|^TestPoller$"
            else flag
          )
            old.checkFlags;
      });
    })
  ];
}
