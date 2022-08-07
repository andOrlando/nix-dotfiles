{ stdenv, fetchFromGitHub, luaPackages, cairo, librsvg, cmake, imagemagick, pkgconfig, gdk-pixbuf
, xorg, libstartup_notification, libxdg_basedir, libpthreadstubs
, xcb-util-cursor, makeWrapper, pango, gobject-introspection
, which, dbus, nettools, git, doxygen
, xmlto, docbook_xml_dtd_45, docbook_xsl, findXMLCatalogs
, libxkbcommon, xcbutilxrm, hicolor-icon-theme
, asciidoctor
#, fontsConf
, playerctl, lm_sensors, brightnessctl
, gtk3Support ? false, gtk3 ? null
}:

# needed for beautiful.gtk to work
assert gtk3Support -> gtk3 != null;

stdenv.mkDerivation rec {
  lgi = luaPackages.lgi;
  lua = luaPackages.lua;
  ldoc = luaPackages.ldoc;
  pname = "awesome";
  version = "git";

  src = fetchFromGitHub {
    owner = "awesomewm";
    repo = "awesome";
    rev = "cafd6526fe2f4d96418a7089cb2d777386bf0956";
    sha256 = "1l98yfdvpf29p9jmwh30n13bixb27lyp4is7kwzsfvj5shpm7qif";
  };

  nativeBuildInputs = [
    cmake
    doxygen
    imagemagick
    makeWrapper
    pkgconfig
    xmlto docbook_xml_dtd_45
    docbook_xsl findXMLCatalogs
    asciidoctor
    ldoc
    playerctl
    lm_sensors
    brightnessctl
  ];

  outputs = [ "out" "doc" ];

  #FONTCONFIG_FILE = toString fontsConf;

  propagatedUserEnvPkgs = [ hicolor-icon-theme ];
  buildInputs = [ cairo librsvg dbus gdk-pixbuf gobject-introspection
                  git lgi libpthreadstubs libstartup_notification
                  libxdg_basedir lua nettools pango xcb-util-cursor
                  xorg.libXau xorg.libXdmcp xorg.libxcb xorg.libxshmfence
                  xorg.xcbutil xorg.xcbutilimage xorg.xcbutilkeysyms
                  xorg.xcbutilrenderutil xorg.xcbutilwm libxkbcommon
                  xcbutilxrm ];
                  #++ lib.optional gtk3Support gtk3;

  cmakeFlags = []; #++ stdenv.lib.optional luaPackages.isLuaJIT "-DLUA_LIBRARY=${lua}/lib/libluajit-5.1.so";

  GI_TYPELIB_PATH = "${pango.out}/lib/girepository-1.0";
  # LUA_CPATH and LUA_PATH are used only for *building*, see the --search flags
  # below for how awesome finds the libraries it needs at runtime.
  LUA_CPATH = "${lgi}/lib/lua/${lua.luaversion}/?.so";
  LUA_PATH  = "${lgi}/share/lua/${lua.luaversion}/?.lua;;";

  postInstall = ''
    # Don't use wrapProgram or the wrapper will duplicate the --search
    # arguments every restart
    mv "$out/bin/awesome" "$out/bin/.awesome-wrapped"
    makeWrapper "$out/bin/.awesome-wrapped" "$out/bin/awesome" \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --add-flags '--search ${lgi}/lib/lua/${lua.luaversion}' \
      --add-flags '--search ${lgi}/share/lua/${lua.luaversion}' \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH"
    wrapProgram $out/bin/awesome-client \
      --prefix PATH : "${which}/bin"
  '';

  passthru = {
    inherit lua;
  };

  #meta = with stdenv.lib; {
  #  description = "Highly configurable, dynamic window manager for X";
  #  homepage    = "https://awesomewm.org/";
  #  license     = licenses.gpl2Plus;
  #  maintainers = with maintainers; [ lovek323 rasendubi ];
  #  platforms   = platforms.linux;
  #};
}