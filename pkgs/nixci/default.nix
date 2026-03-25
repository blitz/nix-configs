{
  lib,
  stdenvNoCC,
  makeWrapper,
  git,
  nix-eval-jobs,
  jq,
  nix,
  attic-client,                 # TODO This should be celler
}:
stdenvNoCC.mkDerivation {
  name = "nixci";

  src = ./src;

  nativeBuildInputs = [
    makeWrapper
  ];

  doConfigure = false;
  doBuild = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper $out/bin/nixci nixci \
      --prefix PATH ${
        lib.makeBinPath [
          git
          nix-eval-jobs
          jq
          nix
          attic-client
        ]
      }

    runHook postInstall
  '';
}
