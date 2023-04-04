pkgs:
let
  local = import ../../local.nix;
in
{
  enable = true;

  shellAliases = {
    unziptar = "tar -xvzf";
    ls = "exa --icons --sort extension";
    tree = "exa --icons --sort extension --tree";
    rebuild = "${local.configdir}/rebuild.sh";
    home = "$EDITOR ${local.configdir}/users/$USER/home.nix";
    config = "$EDITOR ${local.configdir}/hosts/$(hostname)/configuration.nix";
    make-store-writable = "sudo mount /nix/store -o remount,ro";
    gsudo = "sudo git -c \"include.path=$HOME/.config/git/config\"";
  };

  plugins = [
    {
      name = "z";
      src = pkgs.fetchFromGitHub {
        owner = "jethrokuan";
        repo = "z";
        rev = "ddeb28a7b6a1f0ec6dae40c636e5ca4908ad160a";
        sha256 = "0c5i7sdrsp0q3vbziqzdyqn4fmp235ax4mn4zslrswvn8g3fvdyh";
      };
    }
  ];

  shellInit = ''

    # set prompt
    function fish_prompt
        printf "%s%s%s@%s%s %s%s \n%s\$%s " \
            (set_color brblue) $USER \
            (set_color normal) \
            (set_color blue) $hostname \
            (set_color brblack) (prompt_pwd -d 12) \
            (set_color -o blue) (set_color normal)
    end

    # set title
    function fish_title
        if [ -z $argv ]; echo (prompt_pwd -d 12)
        else; echo $argv
        end
    end

	# useful functions for nixos
	function nix-build-with-nixpkgs; nix-build -E "with import <nixpkgs> {}; callPackage ./$argv[1] {}"; end
    # function rebuild; sudo nixos-rebuild switch -I nixos-config=$HOME/.config/nixos/configuration.nix; end
    function nix-fetch-sha256-gh; nix-prefetch-url --unpack "https://github.com/$argv[1]/$argv[2]/archive/$argv[3].tar.gz"; end
    function nix-store-mount-rw; sudo mount -o remount,rw /nix/store; end
    function nix-store-mount-r; sudo mount -o remount,r /nix/store; end
	function svim; sudo -E vim; end

    # set vim mode
    function fish_user_key_bindings
        fish_default_key_bindings -M insert
        fish_vi_key_bindings --no-erase insert
    end

    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_blink block

    # set theme
    set fish_color_normal normal
    set fish_color_command brblue
    set fish_color_keyword brred
    set fish_color_quote brgreen
    set fish_color_redirection brblack
    set fish_color_end normal
    set fish_color_error brred -o
    set fish_color_param brmagenta
    set fish_color_valid_path normal
    set fish_color_option magenta
    set fish_color_comment brblack
    set fish_color_selection brblack
    set fish_color_cancel red -o
    set fish_color_autosuggest green 

    set fish_pager_color_progress normal --background=brblack
    set fish_pager_color_prefix magenta -o
    set fish_pager_color_completion normal
    set fish_pager_color_description brblue 
    set fish_pager_color_selected_background normal
    set fish_pager_color_selected_prefix brblue -o
    set fish_pager_color_selected_completion brblue -o
    set fish_pager_color_selected_description brbluee-o

  '';
}
