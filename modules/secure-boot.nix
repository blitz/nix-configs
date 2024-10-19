{ inputs, pkgs, ... }: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  
  environment.systemPackages = [
    pkgs.sbctl
  ];

  boot.lanzaboote = {
    enable = true;

    configurationLimit = 10;
    pkiBundle = "/etc/secureboot";
  };
}
