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

  services.nginx.enable = true;

  services.nginx.virtualHosts."${config.networking.hostName}.${config.networking.domain}" = {
    addSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://${config.services.plausible.server.listenAddress}:${toString config.services.plausible.server.port}";
      proxyWebsockets = true; # needed if you need to use WebSocket
      extraConfig =
        # required when the target is also TLS server with multiple hosts
        "proxy_ssl_server_name on;" +
        # required when the server wants to use HTTP Authentication
        "proxy_pass_header Authorization;"
      ;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "foo@bar.com";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
