{ lib,
  trivialBuild,
  fetchFromGitHub,
  emacs,
}:
trivialBuild rec {
  pname = "promela-mode";
  version = "2014-12-12-git";

  src = fetchFromGitHub {
    owner = "g15ecb";
    repo = "promela-mode";
    rev = "53863e62cfedcd0466e1e19b1ca7b5786cb7a576";
    hash = "sha256-pOVIOj5XnZcNVFNyjMV7Iv0X+R+W+mQfT1o5nay2Kww=";
  };

  # elisp dependencies
  propagatedUserEnvPkgs = [
    # None
  ];

  buildInputs = propagatedUserEnvPkgs;

  meta = {
    homepage = "https://github.com/g15ecb/promela-mode";
    description = "Emacs mode for Promela, the language of the Spin model checker";
    # License?
    inherit (emacs.meta) platforms;
  };
}
