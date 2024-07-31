{ pkgs, lib, rustPlatform, fetchFromGitHub, pkg-config, openssl }:
rustPlatform.buildRustPackage rec {
  pname = "gitlab-timelogs";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "phip1611";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-+s/471R9wI6pG0UtoM+zgm0mq6CFJ3/yDwpbacJfm90=";
  };

  cargoSha256 = "sha256-0pteiu2bvnS/OIo8+i6DxYy8XcffhfM+IAwkks0w/Wg=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "Gitlab Time Accounting Helper";
    homepage = "https://gitlab.com/phip1611/gitlab-timelogs";
    changelog = "https://gitlab.com/phip1611/gitlab-timelogs/-/releases#v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ blitz ];
    mainProgram = "gitlab-timelogs";
  };
}
