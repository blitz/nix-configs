{ lib, pkgs, ... }: {
  boot.kernelPackages = lib.mkForce pkgs.pkgsLLVM.linuxPackages_latest;

  boot.kernelPatches = [
    {
      name = "clang-lto";
      patch = null;

      structuredExtraConfig = with lib.kernel; {
        # This somehow breaks Rust support. Not sure why yet.
        #
        # LTO_CLANG_THIN = yes;

        CFI_ICALL_NORMALIZE_INTEGERS = yes;
        CFI_CLANG = yes;
      };
    }
  ];


}
