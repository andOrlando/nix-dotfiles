local s = require "settings"
s.application.prefer_dark_mode = true
s.session.always_save = true
--s.tablist.always_visible = true why does this not work
s.undoclose.max_saved_tabs = 25
s.webview.enable_developer_extras = true
s.window.search_engines = {
	default="https://duckduckgo.com/?q=%s",
	["@nix"]="https://search.nixos.org/packages?query=%s",
	["@yt"]="https://www.youtube.com/results?search_query=%s",
	["@gh"]="https://github.com/search?q=%s",
}

local select = require "select"
select.label_maker = function()
	local chars = charset("asdfghjkl")
	return trim(sort(reverse(chars)))
end
