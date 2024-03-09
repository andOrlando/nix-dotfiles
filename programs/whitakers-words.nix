{ stdenv
, lib
, fetchFromGitHub
, gnat
, gprbuild
}:

stdenv.mkDerivation rec {
  pname = "whitakers-words";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "mk270";
    repo = "whitakers-words";
    rev = "566ea3416f777353297df93bf8f8623b188db506";
    sha256 = "1r66zx6ya7jxpzsf77lx0cbfzznlpil92fasrs2p4sag7469jzfz";
  };

  nativeBuildInputs = [ gnat gprbuild ];

  installPhase = ''
    mkdir -p $out/bin

    # copy all important files to out
    cp bin/words *\.GEN *\.LAT *\.SEC $out

    # create the script that will actually be in path
    echo "( cd $out; $out/words )" > $out/bin/words
    chmod +x $out/bin/words
  ''; 

  meta = with lib; {
    description = "Whitaker's Words is a latin word parser and dictionary";
    homepage = "https://mk270.github.io/whitakers-words/";
    liscence = liscences.mit;
    platforms = platforms.linux;
  };
}
