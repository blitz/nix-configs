{ config, pkgs, ... }:

{
  services.plausible = {
    enable = true;

    server = {
      baseUrl = "https://${config.networking.hostName}.${config.networking.domain}/";
      secretKeybaseFile = "/var/lib/plausible-secret-keybase";
    };

    adminUser = {
      email = "js@alien8.de";
      activate = true;
      passwordFile = "/var/lib/plausible-pw";
    };
  };

  # This should probably use LoadCredential.
  systemd.services.plausible.serviceConfig.EnvironmentFile = "/var/lib/plausible-google-search";

  services.nginx.enable = true;

  services.nginx.virtualHosts."${config.networking.hostName}.${config.networking.domain}" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://${config.services.plausible.server.listenAddress}:${toString config.services.plausible.server.port}";
      proxyWebsockets = true;
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

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
