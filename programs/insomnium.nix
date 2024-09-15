{ lib, stdenv, makeWrapper, fetchurl, dpkg, alsa-lib, atk, cairo, cups, dbus, expat
, fontconfig, freetype, gdk-pixbuf, glib, pango, mesa, nspr, nss, gtk3
, at-spi2-atk, gsettings-desktop-schemas, gobject-introspection, wrapGAppsHook
, libX11, libXScrnSaver, libXcomposite, libXcursor, libXdamage, libXext
, libXfixes, libXi, libXrandr, libXrender, libXtst, libxcb, libxshmfence, nghttp2
, libudev0-shim, glibc, curl, openssl, autoPatchelfHook }:

let
  runtimeLibs = lib.makeLibraryPath [
    curl
    glibc
    libudev0-shim
    nghttp2
    openssl
    stdenv.cc.cc.lib
  ];
in stdenv.mkDerivation rec {

  pname = "insomnium";
  version = "0.2.3-a";

  src = fetchurl {
    url = "https://github.com/ArchGPT/insomnium/releases/download/core@${version}/Insomnium.Core-${version}.signed.dmg";
    sha256 = "sha256-OlYfoNNBPSMYDVSIsANKW7yy1DPkYA4x0ALgyipS2d8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    gobject-introspection
    wrapGAppsHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    pango
    gtk3
    gsettings-desktop-schemas
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libxcb
    libxshmfence
    mesa # for libgbm
    nspr
    nss
  ];

  dontBuild = true;
  dontConfigure = true;
  dontWrapGApps = true;

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out/share/insomnium $out/lib $out/bin

    mv usr/share/* $out/share/
    mv opt/Insomnium/* $out/share/insomnium

    ln -s $out/share/insomnia/insomnium $out/bin/insomnium
    sed -i 's|\/opt\/Insomnium|'$out'/bin|g' $out/share/applications/insomnium.desktop
  '';

  preFixup = ''
    wrapProgramShell "$out/bin/insomnium" \
        "''${gappsWrapperArgs[@]}" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations}}" \
        --prefix LD_LIBRARY_PATH : ${runtimeLibs}
  '';

  meta = with lib; {
    description = "The most intuitive cross-platform REST API Client";
    mainProgram = "insomnia";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ markus1189 babariviere kashw2 ];
  };

}
