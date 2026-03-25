{ config, inputs, ... }:
{
  imports = [
    ./secrets.nix
    inputs.celler.nixosModules.atticd
  ];

  age.secrets.atticd-env-file = {
    file = ../secrets/celler-server-token.age;
    owner = config.services.atticd.user;
    group = config.services.atticd.group;
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = config.services.atticd.user;
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "atticd" ];
  };

  services.atticd = {
    enable = true;

    # Replace with absolute path to your environment file
    environmentFile = config.age.secrets.atticd-env-file.path;

    settings = {
      listen = "[::]:8080";

      jwt = { };

      database = {
        url = "postgresql:///atticd";
      };

      storage = {
        type = "s3";
        region = "fr-par";
        bucket = "cache-x86-lol";
        endpoint = "https://cache-x86-lol.s3.fr-par.scw.cloud";
      };

      chunking = {
        nar-size-threshold = 128 * 1024;

        min-size = 128 * 1024;
        avg-size = 512 * 1024;
        max-size = 2048 * 1024;
      };

      garbage-collection = {
        interval = "24 hours";
        default-retention-period = "1 year";
      };

      compression = {
        type = "zstd";
        level = 8;
      };
    };
  };

  services.nginx.enable = true;

  services.nginx.virtualHosts."cache.x86.lol" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://${config.services.atticd.settings.listen}";
      extraConfig = ''
        proxy_ssl_server_name on;
        proxy_pass_header Authorization;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Real-IP       $remote_addr;
      '';
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "julian.stecklina+acme@gmail.com";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
