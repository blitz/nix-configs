{
  nix.distributedBuilds = true;

  nix.buildMachines = [
    {
      hostName = "jetson";
      protocol = "ssh-ng";
      systems = [ "aarch64-linux" ];

      maxJobs = 1;              # Not a lot of RAM
      speedFactor = 2;

      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
  ];

  programs.ssh.extraConfig = ''
    Host jetson
      HostName jetson.lan
      User nixremote
      IdentitiesOnly yes
      PubkeyAcceptedKeyTypes ssh-ed25519
      IdentityFile ~/.ssh/id_ed25519
  '';

  programs.ssh.knownHosts = {
    "jetson.lan ssh-ed25519".publicKey = "AAAAC3NzaC1lZDI1NTE5AAAAIE+w3l9K6bMCh0zAelWQRF3VGaCwPzV5btHgt90vxMr6";
    "jetson.lan ssh-rsa".publicKey = "AAAAB3NzaC1yc2EAAAADAQABAAACAQDSjRbI8nJQrqSsoIKl22XEkTxw+v5tfS/Rkq0Xxu1rZfXHqTRYfpOClAPDI2O1pG9noV+ByjGRbSsAzSGH0NZk9YfvefRxFZJXyQryiKcFXf+0XQOamN03SaRcY9zcEuBBx7oDj/Q2CvEXeVjxbFEfdZo6hB0C0ZXVRMZtrk6YMjJvfr/N1Kq0uKe8cA5c/alszkA2YBH+r2O7/PTzi2qduiIfj4mD31qzxKwELGu2n1seX8DP09/6TKbhgBNiJnd/fzFeh7X7RoNfYR/lt6Tw+it2T1BDEUzelrner4uD46Zfp9QxHrj8nopbvfzvk6GOnRAplJ08wLnQP3zHE+l2s9uppxiTgY20sIBXqe+uMuNf93dFKFjuMHlCMRoz4FY/BVVplCKXLrshAEOvA8/2J9r6d/yNiR0aF0ltZD/MFkzSwsiCvdYnnjJ2u3YvKlHgAyW0OFTVu2FWdC1EDDrmqDGQUIZlm9ujHVrWZGyUGTwWDfa2ZQ7UJVFncxHTk5okkqw3NwqhcI51dUhMlKiRseFp/wqT05nAVNqTxgoKVs3ccGNV4Vjv/DLhOK9QhGmnW1DbHol98fErQGdqenvlxEcy88pmJgKzkhZMzOf37KgmJf8uS0Zci94Eb8dOszp0ogLsaCPXpAvNKJD3YgN/w1Fhulb7smfumvVbsbleQQ==";
  };
}
