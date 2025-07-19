{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "bin-paste";
  version = "2022-03-28";

  src = fetchFromGitHub {
    owner = "w4";
    repo = "bin";
    rev = "459cf79f506b41da577b18907deff4265846e522";
    sha256 = "sha256-HdkoPNA2JdSP//Mt/m3flhiLWYCm2cQqAdK9r2Vw8JM=";
  };

  postInstall = ''
    mv $out/bin/bin $out/bin/bin-paste
  '';

  # cargoSha256 = "C4D2TyJQUBxWahhZuJtDravjoIKudpBNolcpAgmON9w=";
  cargoHash = "sha256-UAgFrNQnZDdafZ472NtNqqiR7nLCsT66cXar0ZQcQG4=";
}
