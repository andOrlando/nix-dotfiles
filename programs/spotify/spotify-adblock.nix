{
  lib,
  fetchFromGitHub,
  callPackage,
  rustPlatform,
  gnumake,
  spotify-deb ? (callPackage ./spotify-deb.nix {}),
  makeDesktopItem,
  autoPatchelfHook,
  self, # TODO I don't think this is required either
}:
rustPlatform.buildRustPackage rec {
  pname = "spotify-adblock";
  version = "v1.0.2";

  src = fetchFromGitHub {
    owner = "abba23";
    repo = pname;
    rev = version;
    sha512 = "+QHTztOjoHJbIKXzmbFmO8BeWzoC0Yr0JcGUrlZQwubumGtiz7Z3qarc/vPjans6bmw0t20hUJrcFZzU+IRXJw==";
  };

  cargoSha256 = "28PQ3fsdqc8bWH3XfOW9QxYM/yN5F1lpYx9VpAvlbQA=";

  nativeBuildInputs = [
    autoPatchelfHook
    gnumake
  ];
  
  preBuild = ''
    substituteInPlace src/lib.rs \
      --replace "/etc/spotify-adblock/config.toml" "${placeholder "out"}/etc/spotify-adblock/config.toml"
  '';

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/etc/${pname}
    install -D --mode=644 --strip target/x86_64-unknown-linux-gnu/release/libspotifyadblock.so $out/lib/${pname}.so
    install -D --mode=644 config.toml $out/etc/${pname}/config.toml
  '';

  meta = with lib; {
    description = "Preloaded library which blocks spotify's ad domains, effectively blocking any ads";
    homepage = "https://github.com/${src.owner}/${pname}";
    license = licenses.gpl3;
    platforms = ["x86_64-linux"];
    architectures = ["amd64" "x86"]; # TODO remove this?
  };
}

