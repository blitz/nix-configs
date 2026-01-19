{ config, pkgs, ... }:

{
  services.plausible = {
    enable = true;

    server = {
      baseUrl = "https://${config.networking.hostName}.${config.networking.domain}/";
      secretKeybaseFile = "/var/lib/plausible-secret-keybase";
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/196935#issuecomment-1767451038
  environment.etc = {
    "clickhouse-server/users.d/disable-logging-query.xml" = {
      text = ''
        <clickhouse>
          <profiles>
            <default>
              <log_queries>0</log_queries>
              <log_query_threads>0</log_query_threads>
            </default>
          </profiles>
        </clickhouse>
      '';
    };
    "clickhouse-server/config.d/reduce-logging.xml" = {
      text = ''
        <clickhouse>
          <logger>
            <level>warning</level>
            <console>true</console>
          </logger>
          <query_thread_log remove="remove"/>
          <query_log remove="remove"/>
          <text_log remove="remove"/>
          <trace_log remove="remove"/>
          <metric_log remove="remove"/>
          <asynchronous_metric_log remove="remove"/>
          <session_log remove="remove"/>
          <part_log remove="remove"/>
        </clickhouse>
      '';
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
