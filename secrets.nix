# agenix -i ~/.ssh/id_agesecrets ...
let
  # id_agesecrets
  julian = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2r6yTDSfWjVrIzRSlDFrl5cgMcKilexdnW33xPRsil";
  users = [ julian ];

  first-temple = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElqXx/6eB1MYsh4cVp9f4pLrwowRm4WsF7iwa6fOqOY";
  ms-a2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3Ay9/64qoCYX8plt8l5Bcc1ddOyIUMG3PHybx6dWk8";
  canaan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4FmZrhvCJFMpdEPkouQje0RhDCFoVUklgMQpwyZGUw";
  chat = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKaiPFwxJgFGwIIQ4orvgNFOc7aOmW1GMRQi4epEyY60";

  cellerServer = [
    chat
  ];

  herculesWorkers = [
    ms-a2
    first-temple
    chat
  ];
in
{
  # Celler Admin
  "secrets/celler-private.age".publicKeys = users;

  # AWS credentials
  "secrets/celler-server-token.age".publicKeys = users ++ cellerServer;

  # Hercules CI for "blitz"
  "secrets/hci/blitz-cluster-join-token.key.age".publicKeys = users ++ herculesWorkers;
  "secrets/hci/blitz-binary-caches.json.age".publicKeys = users ++ herculesWorkers;
  "secrets/hci/blitz-secrets.json.age".publicKeys = users ++ herculesWorkers;

  # Hercules CI for "celler-cache"
  "secrets/hci/celler-cluster-join-token.key.age".publicKeys = users ++ herculesWorkers;
  "secrets/hci/celler-binary-caches.json.age".publicKeys = users ++ herculesWorkers;
  "secrets/hci/celler-secrets.json.age".publicKeys = users ++ herculesWorkers;
}
