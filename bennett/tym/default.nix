{ stdenv
, lib
, fetchFromGitHub
, gnumake
, autoconf
, automake
, pkgconf
, gtk3
, vte
, pcre2
, pcre
, xorg
, libthai
, libselinux
, libsepol
, libdatrie
}:

stdenv.mkDerivation rec {
  pname = "tym";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "endaaman";
    repo = "tym";
    rev = "f9a250960b811b28bf89f0ddaa3ed75f7cfe020c";
    sha256 = "18widgr7s7hf8va29kvp4zgnsgvgspfvy1wa5cp3qd0qryc66lhm";
  };

  nativeBuildInputs = [ 
    gnumake 
    autoconf 
    automake 
    pkgconf 
    gtk3 
    vte 
    pcre2 
    pcre 
    xorg.libXdmcp
    libthai
    libselinux
    libsepol
    libdatrie
  ];

  buildPhase = ''
    autoreconf -fvi
    ./configure
    make
  '';

  installPhase = ''
    ls
    mkdir $out/bin
  '';

  #meta = with lib; {
  #  description = "Whitaker's Words is a latin word parser and dictionary";
  #  homepage = "https://mk270.github.io/whitakers-words/";
  #  liscence = liscences.mit;
  #  platforms = platforms.linux;
  #};
}
