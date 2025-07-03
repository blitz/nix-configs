{ inputs, pkgs, ... }: {
  imports = [ inputs.authentik.nixosModules.default ];
  config = {
    services.authentik = {
      enable = true;

      # These are secrets, but this is a test deployment that is not
      # reachable from the internet.
      environmentFile = "/var/lib/authentik.env";

      settings = {
        # email = {
        #   host = "smtp.example.com";
        #   port = 587;
        #   username = "authentik@example.com";
        #   use_tls = true;
        #   use_ssl = false;
        #   from = "authentik@example.com";
        # };
        disable_startup_analytics = true;
        avatars = "initials";
      };
    };
  };
}
