{ inputs, ... }: {
  imports =
    let
      hwModules = inputs.nixos-hardware.nixosModules;
    in [
      # There is a Thinkpad L14 AMD module, but it disables the
      # IOMMU.
      hwModules.lenovo-thinkpad
      hwModules.common-pc-laptop-ssd
      hwModules.common-cpu-amd
      hwModules.common-gpu-amd
    ];

  boot.kernelParams = [
    # Force use of the thinkpad_acpi driver for backlight control.
    # This allows the backlight save/load systemd service to work.
    "acpi_backlight=native"
  ];
}
