let
  # id_agesecrets
  julian = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2r6yTDSfWjVrIzRSlDFrl5cgMcKilexdnW33xPRsil";
  users = [ julian ];

  first-temple = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElqXx/6eB1MYsh4cVp9f4pLrwowRm4WsF7iwa6fOqOY";
  ms-a2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3Ay9/64qoCYX8plt8l5Bcc1ddOyIUMG3PHybx6dWk8";
  plausible = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICK8+ZrBHGXOZC8u/83u7OoI5ODZrNCGZLg/nKlz/McN";
  systems = [
    first-temple
    ms-a2
  ];
in
{
  # "secret1.age".publicKeys = [ user1 system1 ];
  # "secret2.age".publicKeys = users ++ systems;
  # "armored-secret.age" = {
  #   publicKeys = [ user1 ];
  #   armor = true;
  # };

  "secrets/cluster-join-token.key.age".publicKeys = [
    julian
    first-temple
    ms-a2
  ];
  "secrets/binary-caches.json.age".publicKeys = [
    julian
    first-temple
    ms-a2
  ];
  "secrets/celler-server-token.age".publicKeys = [
    julian
    plausible
  ];
}
