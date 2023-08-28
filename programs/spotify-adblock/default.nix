
{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, spotify # unfree
, wget
}:

let

  spotify-adblock = rustPlatform.buildRustPackage rec {
    pname = "spotify-adblock";
    version = "1.0.2-unstable-2023-04-09";

    src = fetchFromGitHub {
      owner = "abba23";
      repo = pname;
      #rev = version;
      rev = "22847a7bfa87edf4ca58ee950fd8977d20f0d337";
      sha256 = "sha256-5tZ+Y7dhzb6wmyQ+5FIJDHH0KqkXbiB259Yo7ATGjSU=";
    };

    configUrl = "https://raw.githubusercontent.com/${src.owner}/${src.repo}/main/config.toml";

    cargoSha256 = "sha256-cergN3x/iQO5GlBmvgNsmSyh8XVEbNPMYhixvf3HGWI=";

    postInstall = ''
      mkdir -p $out/etc/spotify-adblock
      cp config.toml $out/etc/spotify-adblock
    '';

    meta = with lib; {
      description = "Adblocker for Spotify";
      homepage = "https://github.com/abba23/spotify-adblock";
      license = licenses.unlicense;
      maintainers = [ ];
    };
  };

in

spotify.overrideAttrs (prev: {
  installPhase = prev.installPhase + ''
    # add spotify-adblock to libs
    ln -s ${spotify-adblock}/lib/libspotifyadblock.so $libdir

    # rewrap
    wrapProgram $out/share/spotify/spotify \
      --set LD_PRELOAD "${spotify-adblock}/lib/libspotifyadblock.so"

    # rename everything
    mv $out/bin/spotify $out/bin/spotify-adblock
    mv $out/share/applications/spotify.desktop $out/share/applications/spotify-adblock.desktop
    sed -i "s:Exec=spotify:Exec=spotify-adblock:" $out/share/applications/spotify-adblock.desktop
    sed -i "s:^Name=Spotify.*:Name=Spotify adblock:" $out/share/applications/spotify-adblock.desktop
  '';
})
