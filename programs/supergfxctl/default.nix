{ lib, rustPlatform, fetchFromGitLab, pkg-config, udev, kmod }:

rustPlatform.buildRustPackage rec {
  pname = "supergfxctl";
  version = "4.0.5";

  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname;
    rev = version;
    sha256 = "sha256-hdHZ1GNhEotyOOPW3PJMe4+sdTqwic7iCnVsA5a1F1c=";
  };

  patches = [
    ./no-config-write.patch
  ];

  postPatch = ''
    substituteInPlace data/supergfxd.service \
      --replace /usr/bin $out/bin
    substituteInPlace src/controller.rs \
      --replace \"modprobe\" \"${kmod}/bin/modprobe\" \
      --replace \"rmmod\" \"${kmod}/bin/rmmod\"
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];

  cargoHash = "sha256-+D/4cDMp6bwyavbfFO7RAFPTmbizS3+5qr6sJzA5JiE=";

  makeFlags = [ "prefix=${placeholder "out"}" ];
  # Use default phases since the build scripts install systemd services and udev rules too
  buildPhase = "buildPhase";
  installPhase = "installPhase";

  meta = with lib; {
    description = "Graphics switching tool";
    homepage = "https://gitlab.com/asus-linux/supergfxctl";
    license = licenses.mpl20;
    maintainers = [ maintainers.Cogitri ];
  };
}
