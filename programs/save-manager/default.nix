{ lib
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "save-manager";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "andOrlando";
    repo = "save-manager";
    rev = "676e6b84c2a6c26d79ab0e9480b6569d6f7e7dea";
    sha256 = lib.fakeSha256;
  };

  cargoHash = lib.fakeHash;

  meta = with lib; {
    description = "Manages saves";
    homepage = "https://github.com/andOrlando/save-manager";
    license = licenses.mit;
  };
}
