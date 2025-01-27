{
  nix.distributedBuilds = true;

  nix.buildMachines = [
    {
      hostName = "aarch64-01";
      protocol = "ssh-ng";
      systems = [ "aarch64-linux" ];
      maxJobs = 40;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
  ];

  programs.ssh.extraConfig = ''
    Host aarch64-01
      HostName fd00:5ec:0:8008::3
      User nixbuild
      IdentitiesOnly yes
      PubkeyAcceptedKeyTypes ssh-ed25519
      IdentityFile ~/.ssh/id_ed25519
  '';

  programs.ssh.knownHosts = {
    # aarch64-01
    "fd00:5ec:0:8008::3 ssh-ed25519".publicKey = "AAAAC3NzaC1lZDI1NTE5AAAAIH9NXi+pEIjOcsgh6uIcLxyGAP1pnp87E0T8dBj8wahG";
    "fd00:5ec:0:8008::3 ssh-rsa".publicKey = "AAAAB3NzaC1yc2EAAAADAQABAAACAQDGRUrwjLpjj7fl8npbpUzQiDyWxb2J4Hh788jKMde6Jjsnu8uttN3Uewsu7Dp72gxhLdsrsVrgDLkZ+Omcyr0bG5gvVEw0NSWL4WLiWzacwlF3hMKTnHsFr0resmcGAM4HvLKdyYKO+gC35+BVW+P7XRDWvpuVmhLEmMLcLWGUf0DAYXmxKuNAU7CjGFlRboidXW+kn1BYoo1Erz2aduRpR/HOcs21oL8+vZMFH/Dx7B8Rnk4gbjm0NutDiyrQrJywT0y+cgacJDSn7eZ+q0gJoToDmwMINLuQxHmza4YqSVyaWtqqiVJyQbq88UCUwo25awy2JDdyhHS2LBMwLYlbxeCDuwpFOK7AvYavK13xoOjPqFNBXACv4byI1WlLcPWYQe5PcQKersDqJ7uD8NRhOfExXk82dGJU/SkV7eznK5K9axHBfgvt255WGdqPCjIc2Ii00SmlqlkEuAz6QJw5dOkeZdEXdissN9jH0r41U6FETrfMipnw+bu5uM30zrfRSnVvHcJvuOWJl+utUctowrqjI5b7LztCgqQgLEWaTb0pf4UZ5XLmC54FAqGVWWPNzlY68KRpAUrvrdtIwpFaaIYf+yu2JeDpSxUOh8XqoZxcMQGVpLElCdpReQktNDxo9JusUYmuTD2Prl3Undf07EkPz7R6bor1FYOq2ojodQ==";
  };
}
