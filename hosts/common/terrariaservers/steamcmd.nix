{
  lib,
  stdenv,
  fetchurl,
  steam-run,
  bash,
  coreutils,
  steamRoot ? "~/.local/share/Steam",
}:

stdenv.mkDerivation {
  pname = "steamcmd";
  version = "newest"; # According to steamcmd_linux.tar.gz mtime

  src = fetchurl {
    url = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz";
    hash = "sha256-zr8ARr/QjPRdprwJSuR6o56/QVXl7eQTc7V5uPEHHnw=";
    curlOpts = "--ipv4 --location --compressed --retry 5 --connect-timeout 15 --max-time 300 --user-agent curl/7.88.1 --insecure";
  };

  # The source tarball does not have a single top-level directory.
  preUnpack = ''
    mkdir $name
    cd $name
    sourceRoot=.
  '';

  buildInputs = [
    bash
    steam-run
  ];

  dontBuild = true;

  installPhase = ''
    echo HI CAN YOU SEE THIS
    mkdir -p $out/share/steamcmd/linux32
    install -Dm755 steamcmd.sh $out/share/steamcmd/steamcmd.sh
    install -Dm755 linux32/* $out/share/steamcmd/linux32

    mkdir -p $out/bin
    substitute ${./steamcmd.sh} $out/bin/steamcmd \
      --subst-var out \
      --subst-var-by coreutils ${coreutils} \
      --subst-var-by steamRoot "${steamRoot}" \
      --subst-var-by steamRun ${steam-run}
    chmod 0755 $out/bin/steamcmd
  '';

  meta = with lib; {
    homepage = "https://developer.valvesoftware.com/wiki/SteamCMD";
    description = "Steam command-line tools";
    mainProgram = "steamcmd";
    platforms = platforms.linux;
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ tadfisher ];
  };
}
