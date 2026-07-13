let
  # id_agesecrets
  julian = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2r6yTDSfWjVrIzRSlDFrl5cgMcKilexdnW33xPRsil";
  users = [ julian ];

  first-temple = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElqXx/6eB1MYsh4cVp9f4pLrwowRm4WsF7iwa6fOqOY";
  ms-a2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3Ay9/64qoCYX8plt8l5Bcc1ddOyIUMG3PHybx6dWk8";
  plausible = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICK8+ZrBHGXOZC8u/83u7OoI5ODZrNCGZLg/nKlz/McN";

  cellerServer = [
    plausible
  ];

  herculesWorkers = [
    ms-a2
    first-temple
  ];
in
{
  "secrets/celler-server-token.age".publicKeys = users ++ cellerServer;

  # Hercules CI for "blitz"
  "secrets/blitz-cluster-join-token.key.age".publicKeys = users ++ herculesWorkers;
  "secrets/blitz-binary-caches.json.age".publicKeys = users ++ herculesWorkers;

  # Hercules CI for "celler-cache"
  "secrets/celler-cluster-join-token.key.age".publicKeys = users ++ herculesWorkers;
  "secrets/celler-binary-caches.json.age".publicKeys = users ++ herculesWorkers;
}
