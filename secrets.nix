let
  # id_agesecrets
  julian = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2r6yTDSfWjVrIzRSlDFrl5cgMcKilexdnW33xPRsil";
  users = [ julian ];

  first-temple = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJDyIr/FSz1cJdcoW69R+NrWzwGK/+3gJpqD1t8L2zE";
  ms-a2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3Ay9/64qoCYX8plt8l5Bcc1ddOyIUMG3PHybx6dWk8";
  systems = [ first-temple ms-a2 ];
in
{
  # "secret1.age".publicKeys = [ user1 system1 ];
  # "secret2.age".publicKeys = users ++ systems;
  # "armored-secret.age" = {
  #   publicKeys = [ user1 ];
  #   armor = true;
  # };

  "secrets/cluster-join-token.key.age".publicKeys = [ julian first-temple ];
  "secrets/binary-caches.json.age".publicKeys = [ julian first-temple ];
}
