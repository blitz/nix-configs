{ inputs, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk = {
      ms-a2 = {
        device = "/dev/nvme0n1";
        type = "disk";

        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "2G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            encryptedSwap = {
              size = "8G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };

            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
