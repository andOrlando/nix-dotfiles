{...}:
{
  homelab = {
    enable = true;
    basedomain = "box1.tail8eedf6.ts.net";
    
    homepage.enable = true;
    immich.enable = true;
    immich.mediaLocation = "/mnt/md0/immich";
    jellyfin.enable = true;

    # I can just torrent and import manually...
    # jellyseer also conflicts with 5055 for traccar
    # jellyseerr.enable = true;
    # prowlarr.enable = true;
    # sonarr.enable = true;
    # radarr.enable = true;
    # bazarr.enable = true;

    slskd.enable = true;
    slskd.environmentFile = /var/lib/slskd/slskd.conf;
    slskd.directories.downloads = "/var/lib/slskd/downloads";
    slskd.directories.incomplete = "/var/lib/slskd/incomplete";
    slskd.shares.directories = [ "/mnt/md0/music" ];
    beets.enable = true;
    beets.musicdir = "/mnt/md0/music";

    deluge.enable = true;
    qbittorrent.enable = true;

    # owntracks.enable = true;
    traccar.enable = true;
    navidrome.enable = true;
    # nextcloud.enable = true;
    # nextcloud.domain = "box1";
    opencloud.enable = true;
  };
}
