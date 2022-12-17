from qutebrowser.api import cmdutils

config.load_autoconfig(False)

@cmdutils.register()
def toggle_sidebar() -> None:
    width = config.get("tabs.width")
    config.set("tabs.width", (width + 260) % 520)


# https://github.com/qutebrowser/qutebrowser/blob/master/doc/help/settings.asciidoc
def set_config(val, prev=[]):
    if isinstance(val, dict) and "setting" not in val:
        for key in val: set_config(val[key], prev + key.split("."))
    else: 
        if isinstance(val, dict): del val["setting"]
        config.set(".".join(prev), val)

set_config({
    "auto_save.session": True,
    "hints.border": "1px solid #42525d",
    "content.blocking.method": "both",
    "editor.command": ["kitty", "-e", "nvim", "{file}", "-c", "normal {line}G{column0}l"],
    "url.searchengines": {
        "setting": True,
        "DEFAULT": "https://search.brave.com/search?q={}",
        "@nix": "https://search.nixos.org/packages?query={}",
        "@yt": "https://www.youtube.com/results?search_query={}",
        "@ddg": "https://duckduckgo.com/?q={}",
        "@google": "https://www.google.com/search?q={}"
    },
    "fonts": {
        "default_family": "LiberationMono",
        "tabs.selected": "FreeSans",
        "tabs.unselected": "FreeSans",
        "statusbar": "12px default_family",
    },
    "tabs": {
        "padding": {"setting": True, "top": 10, "bottom": 10, "left": 10, "right": 10},
        "width": 40,
        "indicator.width": 0,
        "favicons.scale": 1.5,
        "title.format": "{audio}{current_title}",
        "last_close": "default-page",
        "position": "left",
    },
    "statusbar": {
        "widgets": ["keypress","url","scroll","history","progress"],
        "padding": {"setting": True, "bottom": 7, "top": 7, "left": 5, "right": 5},
    },
    "colors": {
        "tabs": {
            "even.bg": "#42525d",
            "odd.bg": "#42525d",
            "selected.even.bg": "#2f3a42",
            "selected.odd.bg": "#2f3a42",
            "bar.bg": "#42525d",
        },
        "completion": {
            "even.bg": "#777f90",
            "odd.bg": "#777f90",
            "item.selected.bg": "#b1bdd6",
            "item.selected.border.bottom": "#000000",
            "item.selected.border.top": "#000000",
            "match.fg": "#6c88d5",
            "item.selected.match.fg": "#6c88d5",
            "scrollbar.bg": "#000000",
            "scrollbar.fg": "#ffffff",
            # https://doc.qt.io/qt-5/qlineargradient.html
            "category.bg": "#405666",
        },
        "statusbar": {
            "command.bg": "#565c68",
            "insert.bg": "#369f70",
            "normal.bg": "#2c363d",
            "caret.bg": "#c86ddf",
            "passthrough.bg": "#6c88d5",
        },
        "hints": {
            "bg": "#b1bdd6",
            "fg": "#000000",
            "match.fg": "#6c88d5",
        },
    },
    "bindings.default": {
        "setting": True,
        "normal": {
            "'": "mode-enter jump_mark",
            "`": "mode-enter set_mark",
            "V": "mode-enter caret ;; selection-toggle --line",
            "v": "mode-enter caret",
            "f": "hint",
            "i": "mode-enter insert",
            "I": "mode-enter passthrough",
            "<escape>": "clear-keychain ;; search ;; fullscreen --leave",

            "h": "scroll left",
            "j": "scroll down",
            "k": "scroll up",
            "l": "scroll right",
            "+": "zoom-in",
            "-": "zoom-out",
            "=": "zoom",
            "/": "set-cmd-text /",
            ":": "set-cmd-text :",
            "?": "set-cmd-text ?",
            "q": "macro-record",
            "@": "macro-run",
            "<ctrl-b>": "scroll-page 0 -1",
            "<ctrl-f>": "scroll-page 0 1",
            "<ctrl-u>": "scroll-page 0 -0.5",
            "<ctrl-d>": "scroll-page 0 0.5",
            "<ctrl-c>": "stop",
            "<ctrl-shift-c>": "yank selection",
            "n": "search-next",
            "N": "search-prev",
            "U": "undo -w",
            "u": "undo",
            "r": "reload",
            "[[": "navigate prev",
            "]]": "navigate next",
            "o": "set-cmd-text -s :open ",
            "O": "set-cmd-text -s :open -t ",
            "t": "open -t",

            "K": "tab-prev",
            "J": "tab-next",
            "<ctrl-shift-k>": "tab-move -",
            "<ctrl-shift-j>": "tab-move +",
            "L": "forward",
            "H": "back",
            "q": "tab-close",
            "<alt-m>": "tab-mute",
            "<ctrl-n>": "toggle-sidebar",
        },
        "command": {
            "<ctrl-w>": "rl-unix-word-rubout",
            "<escape>": "mode-leave",
            "<down>": "completion-item-focus --history next",
            "<up>": "completion-item-focus --history prev",
            "<return>": "command-accept",
            "<tab>": "completion-item-focus next",
            "<shift-tab>": "completion-item-focus prev",
        },
        "hint": {
            "<return>": "hint-follow",
            "<escape>": "mode-leave",
            #"<ctrl-r>": "hint --rapid links tab-bg",
            "<shift-f>": "hint all tab-fg",
            "<shift-b>": "hint all tab-bg",
            #"<ctrl-shift-f>": "hint links",
        },
        "insert": {
            "<ctrl-e>": "edit-text",
            "<escape>": "mode-leave",
            "<shift-escape>": "fake-key <escape>",
            #"<shift-ins>": "insert-text -- {primary}",
        },
        "caret": {
            "$": "move-to-end-of-line",
            "^": "move-to-start-of-line",
            "<ctrl-space>": "selection-drop",
            "<escape>": "mode-leave",
            "<return>": "yank selection",
            "H": "scroll left",
            "J": "scroll down",
            "K": "scroll up",
            "L": "scroll right",
            "h": "move-to-prev-char",
            "j": "move-to-next-line",
            "k": "move-to-prev-line",
            "l": "move-to-next-char",
            "b": "move-to-prev-word",
            "w": "move-to-next-word",
            "y": "yank selection",
        },
        "passthrough": { 
            "<shift-escape>": "mode-leave",
            "<ctrl-w>": "rl-unix-word-rubout",
            "<alt-1>": "tab-select 1 ;; mode-enter passthrough",
            "<alt-2>": "tab-select 2 ;; mode-enter passthrough",
            "<alt-3>": "tab-select 3 ;; mode-enter passthrough",
            "<alt-4>": "tab-select 4 ;; mode-enter passthrough",
            "<alt-5>": "tab-select 5 ;; mode-enter passthrough",
            "<alt-6>": "tab-select 6 ;; mode-enter passthrough",
            "<alt-7>": "tab-select 7 ;; mode-enter passthrough",
            "<alt-8>": "tab-select 8 ;; mode-enter passthrough",
            "<alt-9>": "tab-select -1 ;; mode-enter passthrough",
            "<alt-k>": "tab-prev ;; mode-enter passthrough",
            "<alt-j>": "tab-next ;; mode-enter passthrough",
        },
        "register": { "<escape>": "mode-leave" },
        "prompt": {
            "<ctrl-p>": "prompt-open-download --pdfjs",
            "<ctrl-w>": "rl-unix-word-rubout",
            "<down>": "prompt-item-focus next",
            "<up>": "prompt-item-focus prev",
            "<tab>": "prompt-item-focus next",
            "<shift-tab>": "prompt-item-focus prev",
            "<return>": "prompt-accept",
            "<escape>": "mode-leave",
        },
        "yesno": {
            "<return>": "prompt-accept",
            "<escape>": "mode-leave",
            "N": "prompt-accept --save no",
            "Y": "prompt-accept --save yes",
            "n": "prompt-accept no",
            "y": "prompt-accept yes",
        }
    },
})

