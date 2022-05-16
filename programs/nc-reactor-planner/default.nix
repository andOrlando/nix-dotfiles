{ stdenv
, fetchurl
, mono
}:

stdenv.mkDerivation rec {
  pname = "nc-reactor-planner";
  version = "1.0";

  src = fetchurl {
    url = "https://github.com/hellrage/NC-Reactor-Planner/releases/download/v1.2.25/NC.Reactor.Planner.1.2.25.exe";
    sha256 = "0hb13bxwakywjjlqs05k8d0y48iiskbn5mgllmifcfzd0jv4whr2";
  };

  buildInputs = [ mono ];

  phases = [ "unpackPhase" "installPhase"];

  unpackPhase = ''
    cp $src run.exe
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp run.exe $out
    echo mono $out/run.exe > $out/bin/nc-reactor-planner
    chmod +x $out/bin/nc-reactor-planner
  ''; 

}
