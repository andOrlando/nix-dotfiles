{ lib, fetchurl, rustPlatform }:

with rustPlatform;

buildRustPackage rec {
  pname = "rust-battop";
  version = "a434b80774a8f3ef2db934c362914aa7116c450f";

  src = fetchurl {
	#url = "https://github.com/svartalf/${pname}/archive/refs/tags/${version}.tar.gz";
	url = "https://github.com/svartalf/${pname}/archive/${version}.tar.gz";
    sha256 = "sha256-uUaBVD1eOaTcrYDZPc/FsT73EnDyz7bTiEBFzGb5LLo=";
  };

  patches = [ ./no-cargo-lock.patch ];

  cargoHash = "sha256-5+uBYmC4nlQxsItw2AXSLM3yw04y5r4VysBCZK91CKE=";

  meta = with lib; {
    description = "A control daemon, CLI tools, and a collection of crates for interacting with ASUS ROG laptops.";
    homepage = https://gitlab.com/asus-linux/asusctl;
    license = with licenses; [ mpl20 ];
    platforms = platforms.linux;
  };
}
