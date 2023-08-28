{ stdenv
, lib
, bash
, makeWrapper
}:
let
  script = ./rebuild.sh;
  name = "rebuild";
in
stdenv.mkDerivation {
  inherit name;
  phases = ["installPhase"];
  buildInputs = [ bash ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${script} $out/bin/${name}
    wrapProgram $out/bin/${name} \
      --prefix PATH : ${lib.makeBinPath [ bash ]}
  '';
}
