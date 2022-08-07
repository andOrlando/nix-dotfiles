{ stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation {
  name = "hosty";
  src = fetchFromGitHub {
    owner = "astrolince";
    repo = "hosty";
    rev = "42cc80a0a7dd94f667519fdf1de3bf974ce63827";
    sha256 = "0cfjzpqzg996ib9sfmv730y76vqf0mp220ns2zxqz04vwxvzj79k";
  };
  #phases = [ "installPhase" ];
  installPhase = ''
    ls
    mkdir -p $out/bin;
    cp -v hosty.sh $out/bin/hosty;
  '';
}
