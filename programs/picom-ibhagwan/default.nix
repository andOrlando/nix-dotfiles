{ asciidoc
, dbus
, docbook_xml_dtd_45
, docbook_xsl
, fetchFromGitHub
, lib
, libconfig
, libdrm
, libev
, libGL
, libX11
, libxcb
, libxdg_basedir
, libXext
, libXinerama
, libxml2
, libxslt
, makeWrapper
, meson
, ninja
, pcre
, pixman
, pkg-config
, stdenv
, uthash
, xcbutilimage
, xcbutilrenderutil
, xorgproto
, xwininfo
, withDebug ? false
}:

stdenv.mkDerivation rec {
  pname = "picom";
  version = "8.2";

  src = fetchFromGitHub {
    owner = "ibhagwan";
    repo = "picom";
    rev = "c4107bb6cc17773fdc6c48bb2e475ef957513c7a";
    sha256 = "035fbvb678zvpm072bzzpk8h63npmg5shkrzv4gfj89qd824a5fn";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    asciidoc
    docbook_xml_dtd_45
    docbook_xsl
    makeWrapper
    meson
    ninja
    pkg-config
    uthash
  ];

  buildInputs = [
    dbus
    libconfig
    libdrm
    libev
    libGL
    libX11
    libxcb
    libxdg_basedir
    libXext
    libXinerama
    libxml2
    libxslt
    pcre
    pixman
    xcbutilimage
    xcbutilrenderutil
    xorgproto
  ];

  # Use "debugoptimized" instead of "debug" so perhaps picom works better in
  # normal usage too, not just temporary debugging.
  mesonBuildType = if withDebug then "debugoptimized" else "release";
  dontStrip = withDebug;

  mesonFlags = [
    "-Dwith_docs=true"
  ];

  installFlags = [ "PREFIX=$(out)" ];

  # In debug mode, also copy src directory to store. If you then run `gdb picom`
  # in the bin directory of picom store path, gdb finds the source files.
  postInstall = ''
    wrapProgram $out/bin/picom-trans \
      --prefix PATH : ${lib.makeBinPath [ xwininfo ]}
  '' + lib.optionalString withDebug ''
    cp -r ../src $out/
  '';

  meta = with lib; {
    description = "A fork of XCompMgr, a sample compositing manager for X servers";
    longDescription = ''
      A fork of XCompMgr, which is a sample compositing manager for X
      servers supporting the XFIXES, DAMAGE, RENDER, and COMPOSITE
      extensions. It enables basic eye-candy effects. This fork adds
      additional features, such as additional effects, and a fork at a
      well-defined and proper place.
      The package can be installed in debug mode as:
        picom.override { withDebug = true; }
      For gdb to find the source files, you need to run gdb in the bin directory
      of picom package in the nix store.
    '';
    license = licenses.mit;
    homepage = "https://github.com/ibhagwan/picom";
    platforms = platforms.linux;
  };
}
