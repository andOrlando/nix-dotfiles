{ lib
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "save-manager";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "andOrlando";
    repo = "save-manager";
    rev = "ad73d83fdf7f76042d8e701b9bfd67555ab4e3e2";
    sha256 = "sha256-dQx1DFKKYQH9To8bU4TFgHJXKvB3xYLPrxsCwcRUVos=";
  };

  cargoHash = "sha256-owHMu6vQM0/+lkFIRTOPENYcCWdckPH7Keln425xbBw=";

  meta = with lib; {
    description = "Manages saves";
    homepage = "https://github.com/andOrlando/save-manager";
    license = licenses.mit;
  };
}
