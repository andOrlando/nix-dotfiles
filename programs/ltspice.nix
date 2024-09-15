{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, requireFile
, makeDesktopItem
, copyDesktopItems
, imagemagick }:
mkWindowsApp rec {
  inherit wine;
  pname = "ltspice";
  version = "";

  src = fetchurl {
    url = "https://ltspice.analog.com/software/LTspice64.msi";
    sha256 = lib.fakeSha256;
  };

  wineArch = "win64";
  enableInstallNotification = true;
}
