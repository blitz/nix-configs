{ pkgs, ... }: {

  services.keycloak = {
    enable = true;
    settings = {
      hostname = "localhost";
      http-enabled = true;
      hostname-strict-https = false;
    };

    database.passwordFile = "${pkgs.writeText "dbPassword" "very-insecure-password-but-doesnt-matter-for-testing"}";
  };

}
