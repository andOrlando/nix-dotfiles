{ lib, stdenv, fetchFromGitHub, gnat, gprbuild, ... }:

#let 
#  gprbuild = (import <nixpkgs> {}).gprbuild;
#in
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
    mkdir -p $out/bin $out/sub-bin

    # populate sub-bin (hidden bin)
    cp bin/words *\.GEN *\.LAT *\.SEC $out/sub-bin

    # create the script that's actually run
    echo "( cd $out/sub-bin; $out/sub-bin/words )" > $out/bin/words
    chmod +x $out/bin/words
  ''; 

  meta = with lib; {
    description = "Whitaker's Words is a latin word parser and dictionary";
    homepage = "https://mk270.github.io/whitakers-words/";
    #liscence = "";
    maintainers = [];
    platforms = platforms.linux;
  };
}
