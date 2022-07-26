{ lib
, fetchFromGitLab
, fetchpatch
, rustPlatform
, pkg-config
, udev
}:
rustPlatform.buildRustPackage rec {
  pname = "asusctl";
  version = "git-2584d699";
  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname;
    rev = "2584d69930e615482a756000dd77ab5ff821f6f5";
    sha256 = "sha256-H0EvH/UAllMdYXj6P3BJIEmEAdyaIhGYguP9BPv8GsQ=";
  };
  cargoHash = "sha256-eVjdZ3CUOt3q+pROU2R4v4TA0f4kO/t5/1HI+aFJpYw=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];

  postInstall = ''
    make install INSTALL_PROGRAM=true DESTDIR=$out prefix=
  '';

  meta = {
    description = "Control utility for ASUS ROG";
    longDescription = ''
      asusd is a utility for Linux to control many aspects of various ASUS
      laptops but can also be used with non-asus laptops with reduced features.
    '';
    homepage = "https://asus-linux.org";
    license = lib.licenses.mpl20;
  };
}
