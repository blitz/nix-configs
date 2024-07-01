{ config, pkgs, lib, ... }:

{
  hardware.amdgpu = {
    initrd.enable = true;
    opencl.enable = true;
  };
}
