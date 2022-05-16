{ stdenv
, fetchFromGitHub
, go
, nodejs
}:

stdenv.mkDerivation rec {
  pname = "focalboard";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "mattermost";
    repo = "focalboard";
    rev = "93a061792a756a63d75e208e6bbb6c857d78d867";
    sha256 = "05576bzz66j9nykwkrggyxcnqffvgr8hfl8c22jj67pa7zklyw5h";
  };

  nativeBuildInputs = [ go nodejs ];

  buildPhase = ''
    npm i
    make linux-app
  '';

  installPhase = ''
    ls
  ''; 
}
