{ lib, fetchurl, rustPlatform }:

with rustPlatform;

buildRustPackage rec {
  pname = "rust-battop";
  version = "v0.2.4";

  src = fetchurl {
	url = "https://github.com/svartalf/${pname}/archive/refs/tags/${version}.tar.gz";
    sha256 = "sha256-GlSynQwKwkysTs8RJ+cvxQ4AtaR9cFSM6iDwKzDPPno=";
  };

  cargoHash = "sha256-RVdUSHQpVdhCyEuVHfYMqmryhufPZjIuaypYJE3uXH0=";

  meta = with lib; {
    description = "A control daemon, CLI tools, and a collection of crates for interacting with ASUS ROG laptops.";
    homepage = https://gitlab.com/asus-linux/asusctl;
    license = with licenses; [ mpl20 ];
    platforms = platforms.linux;
  };
}
