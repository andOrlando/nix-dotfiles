pkgs:
let
  fast-syntax-highlighting = {
    name = "fast-syntax-highlighting";
    src = pkgs.fetchFromGitHub {
      owner = "zdharma-continuum";
      repo = "fast-syntax-highlighting";
      rev = "817916dfa907d179f0d46d8de355e883cf67bd97";
      sha256 = "0m102makrfz1ibxq8rx77nngjyhdqrm8hsrr9342zzhq1nf4wxxc";
    };
  };
in
{
  enable = true;
  enableCompletion = true;

  dotDir = ".config/zsh";

  initExtra = ''
    PROMPT="%F{141}%n%f:%F{135}%m %F{8}%~ "$'\n'"%(?.%F{4}%B\$%b.%F{9}?) %f"
    RPROMPT=""
    bindkey -v

	ZSHZ_DATA="~/.misc/z"
	ZSHZ_UNCOMMON=1

	# useful function for nixos
	function nix-build-with-nixpkgs() {
		nix-build -E "with import <nixpkgs> {}; callPackage ./$1 {}"
	}
    function rebuild() {
		sudo nixos-rebuild switch -I nixos-config=$HOME/.config/nixos/configuration.nix
	}

	# Remove mode switching delay.
    KEYTIMEOUT=5

    # Change cursor shape for different vi modes.
    function zle-keymap-select {
      if [[ $KEYMAP == vicmd ]] ||
         [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'

      elif [[ $KEYMAP == main ]] ||
           [[ $KEYMAP == viins ]] ||
           [[ $KEYMAP = "" ]] ||
           [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'
      fi
    }
    zle -N zle-keymap-select
    echo -ne '\e[5 q' # Use beam shape cursor on startup.
    preexec() { echo -ne '\e[5 q' } # Use beam shape cursor for each new prompt.
  '';

  history = {
    save = 1000;
    size = 1000;
    path = "$HOME/.misc/zsh_history";
  };

  shellAliases = {
    unziptar = "tar -xvzf";
    ls = "exa --icons --sort extension";
    tree = "exa --icons --sort extension --tree";
    home = "sudoedit /etc/nixos/users/bennett/home.nix";
    config = "sudoedit /etc/nixos/hosts/configuration.nix";
    make-store-writable = "sudo mount /nix/store -o remount,ro";
  };

  plugins = [ fast-syntax-highlighting ];
  oh-my-zsh = {
    enable = true;
    plugins = [ "z" ];
  };
}
