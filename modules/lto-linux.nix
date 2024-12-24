{ pkgs, lib, ... }: {
  boot.kernelPackages = pkgs.pkgsLLVM.linuxPackages_latest;
  
  boot.kernelPatches = [
    {
      name = "lto-config";
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        LTO_CLANG_FULL = yes;
        CFI_CLANG = yes;
      };
    }
  ];
}
