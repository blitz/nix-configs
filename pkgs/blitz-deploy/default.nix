{ rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage {
  pname = "blitz-deploy";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "blitz";
    repo = "blitz-deploy";
    rev = "9c9b41c6fa9c9b22b352a99370ce07aa505d4a40";
    hash = "sha256-m7W0S+MO9pMASoCn5FYLNOrhUEVO0koWwnPLrg8PGVs=";
  };

  cargoHash = "sha256-R2eGtH/dWqg4jbToXl6sTg2gQxfvwqQqziaUDCaVUFU=";

  meta = {
    mainProgram = "blitz-deploy";
  };
}
