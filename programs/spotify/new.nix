{ spotify
}:
spotify.overrideAttrs(old: rec {
  # add --prefix LD_PRELOAD : "${spotify-adblock.out}/lib/spotify-adblock.so" \
  installPhase = old.installPhase;
})
