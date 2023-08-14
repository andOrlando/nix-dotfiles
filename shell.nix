# Shell for bootstrapping flake-enabled nix and home-manager
# You can enter it through 'nix develop' or (legacy) 'nix-shell'
# I stole this from https://github.com/Misterio77/nix-starter-configs/blob/main/standard/shell.nix :P
# slightly modified because the other one is kinda annoying

{ pkgs ? (import <nixpkgs>) { } }: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [ nix home-manager git ];
  };
}
