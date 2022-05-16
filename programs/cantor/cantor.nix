{ stdenv,
  libspectre,
  libsForQt5,
  hicolor-icon-theme,
  libqalculate,
  extra-cmake-modules,
  python,
  luajit,
  R,
  xorg,
  sagemath,
  shared-mime-info,
  cmake,
  fetchurl,
  callPackage,
}:
let
  analitza = callPackage ./analitza.nix {};
in
stdenv.mkDerivation {
  pname = "cantor";
  version = "21.12.2";

  src = fetchurl {
    url = "https://download.kde.org/stable/release-service/21.12.2/src/cantor-21.12.2.tar.xz";
    sha256 = "e85c356bf91896f56a4759270e45c202dd956a557b252772f18338fadaf6086f";
  };

  nativeBuildInputs = [
    extra-cmake-modules
    python
    shared-mime-info
    libsForQt5.qt5.wrapQtAppsHook
    sagemath
    R
  ];
  buildInputs = [
    analitza
    libspectre
    libqalculate
    luajit
    R
    sagemath
    libsForQt5.kpty
    libsForQt5.ktexteditor
    libsForQt5.knewstuff
    libsForQt5.poppler
    libsForQt5.qt5.qtxmlpatterns
    libsForQt5.qt5.qtwebengine
    hicolor-icon-theme
  ];

  postFixup = ''
    sed -i "s/sage-ipython/sage --ipython/" $out/share/cantor/sagebackend/cantor-execsage
  '';
}
