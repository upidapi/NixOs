{
  stdenvNoCC,
  unzip,
  fetchurl,
  ...
}:
stdenvNoCC.mkDerivation rec {
  pname = "jfa-go";
  version = "0.6.0";
  nativeBuildInputs = [unzip];
  meta.mainProgram = pname;
  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out/bin
    cp --no-preserve=all -r ${pname} $out/bin
    chmod +x $out/bin/${pname}
  '';
  src = fetchurl {
    url = "https://github.com/hrfee/${pname}/releases/download/v${version}/${pname}_${version}_Linux_x86_64.zip";
    hash = "sha256-FedQI4AWlFfsbD93ew4b1rfmWwHBM7L0wfsppky7xZE=";
  };
}
