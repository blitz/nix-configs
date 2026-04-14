{ config, inputs, ... }:
{
  imports = [
    ./secrets.nix
    inputs.celler.nixosModules.cellerd
  ];

  age.secrets.atticd-env-file = {
    file = ../secrets/celler-server-token.age;
    owner = config.services.cellerd.user;
    group = config.services.cellerd.group;
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = config.services.cellerd.user;
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "cellerd" ];
  };

  services.cellerd = {
    enable = true;

    # Replace with absolute path to your environment file
    environmentFile = config.age.secrets.atticd-env-file.path;

    settings = {
      listen = "[::]:8080";

      jwt = { };

      database = {
        url = "postgresql:///cellerd";
      };

      storage = {
        type = "s3";
        region = "fr-par";
        bucket = "cache-x86-lol";
        endpoint = "https://cache-x86-lol.s3.fr-par.scw.cloud";
      };

      chunking = {
        nar-size-threshold = 4 * 1024 * 1024;

        min-size = 2 * 1024 * 1024;
        avg-size = 8 * 1024 * 1024;
        max-size = 16 * 1024 * 1024;
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

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."cache.x86.lol" = {
      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://${config.services.cellerd.settings.listen}";
        extraConfig = ''
          proxy_ssl_server_name on;
          proxy_pass_header Authorization;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Real-IP       $remote_addr;
          proxy_buffering off;
          client_max_body_size 0;
        '';
      };
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
