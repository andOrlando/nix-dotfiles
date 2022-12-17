{ rustPlatform,
  lib,
  fetchFromGitHub,
  spotify-unwrapped,
  alsaLib,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  curlWithGnuTls,
  dbus,
  expat,
  ffmpeg,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk2,
  gtk3,
  libxkbcommon,
  libdrm,
  libgcrypt,
  libnotify,
  libpng,
  libpulseaudio,
  mesa,
  nss,
  pango,
  stdenv,
  systemd,
  xorg,
  zlib,
  gnome3,
  makeWrapper,
  tree,
}:
with rustPlatform;
let
  deps = [
    alsaLib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    #curl # error: libcurl-gnutls.so.4: No such file or directory
    curlWithGnuTls
    dbus
    expat
    ffmpeg
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk2
    gtk3 libxkbcommon # spotify-unwrapped-1.1.55.498
    libdrm
    libgcrypt
    libnotify
    libpng
    libpulseaudio
    mesa
    nss
    pango
    stdenv.cc.cc
    systemd
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libxcb
    xorg.libSM
    xorg.libICE
    zlib
  ];
in
buildRustPackage rec {
  pname = "spotify-adblock";
  version = "1.0.2";
  src = fetchFromGitHub {
    owner = "abba23";
    repo = "spotify-adblock";
    rev = "9ba383b7b41c25c960e91732590ec45be0ff4e73";
    sha256 = "sha256-YGD3ymBZ2yT3vrcPRS9YXcljGNczJ1vCvAXz/k16r9Y=";
  };
  cargoHash = "sha256-bYqkCooBfGeHZHl2/9Om+0qbudyOCzpvwMhy8QCsPRE=";
  nativeBuildInputs = [ makeWrapper tree ];

  installPhase = ''
    runHook preInstall

    tree
    mkdir -p $out/{lib,bin}
    cp target/x86_64-unknown-linux-gnu/release/libspotifyadblock.so $out/lib/

    libdir=${spotify-unwrapped}/lib/spotify
    librarypath="${lib.makeLibraryPath deps}:$libdir"

    makeWrapper ${spotify-unwrapped}/share/spotify/.spotify-wrapped $out/bin/spotify-adblock \
      --prefix LD_LIBRARY_PATH : "$librarypath" \
      --prefix PATH : "${gnome3.zenity}/bin" \
      --suffix LD_PRELOAD : "$out/lib/libspotifyadblock.so"

    # Desktop file
    # based on spotify/default.nix
    mkdir -p $out/share/applications
    cp ${spotify-unwrapped}/share/spotify/spotify.desktop $out/share/applications/spotify-adblock.desktop
    # fix Icon line in the desktop file (#48062)
    sed -i "
      s/^Icon=.*/Icon=spotify-client/;
      s/Exec=spotify/Exec=spotify-adblock/;
      s/Name=Spotify/Name=Spotify Adblock/;
    " $out/share/applications/spotify-adblock.desktop
    # Icons
    for i in 16 22 24 32 48 64 128 256 512; do
      ixi="$i"x"$i"
      mkdir -p "$out/share/icons/hicolor/$ixi/apps"
      ln -s "${spotify-unwrapped}/share/spotify/icons/spotify-linux-$i.png" \
        "$out/share/icons/hicolor/$ixi/apps/spotify-client.png"
    done

    runHook postInstall
  '';

}
