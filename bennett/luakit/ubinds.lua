local window = require("window")
local webview = require("webview")
local taborder = require("taborder")
local settings = require("settings")

-- Binding aliases
local lousy = require("lousy")
local modes = require("modes")

-- Util aliases
local join, split = lousy.util.table.join, lousy.util.string.split

-- URI aliases
local split_uri = lousy.uri.split

-- Add binds to special mode "all" which adds its binds to all modes.
modes.add_binds("all", {
	{ "<Escape>", "Return to `normal` mode.",
		function (w)
			if not w:is_mode("passthrough") then w:set_prompt(); w:set_mode() end
			return not w:is_mode("passthrough")
		end },
	{ "<Control-[>", "Return to `normal` mode.", function (w) w:set_mode() end },
	{ "<Mouse2>", [[Open link under mouse cursor in new tab or navigate to the
		contents of `luakit.selection.primary`.]],
		function (w, m)
			-- Ignore button 2 clicks in form fields
			if not m.context.editable then
				-- Open hovered uri in new tab
				local uri = w.view.hovered_uri
				if uri then
					w:new_tab(uri, { switch = false, private = w.view.private })
				else -- Open selection in current tab
					uri = luakit.selection.primary
					-- Ignore multi-line selection contents
					if uri and not string.match(uri, "\n.+") then
						w:navigate(uri)
					end
				end
			end
		end
	},
	{ "<Shift-Scroll>", "Scroll the current page left/right.", function (w, o)
		w:scroll{ xrel = settings.get_setting("window.scroll_step")*o.dy }
	end },
})

local actions = { scroll = {
	up = {
		desc = "Scroll the current page up.",
		func = function (w, m) w:scroll{ yrel = -settings.get_setting("window.scroll_step")*(m.count or 1) } end,
	},
	down = {
		desc = "Scroll the current page down.",
		func = function (w, m) w:scroll{ yrel =  settings.get_setting("window.scroll_step")*(m.count or 1) } end,
	},
	left = {
		desc = "Scroll the current page left.",
		func = function (w, m) w:scroll{ xrel = -settings.get_setting("window.scroll_step")*(m.count or 1) } end,
	},
	right = {
		desc = "Scroll the current page right.",
		func = function (w, m) w:scroll{ xrel =  settings.get_setting("window.scroll_step")*(m.count or 1) } end,
	},
	page_up = {
		desc = "Scroll the current page up a full screen.",
		func = function (w, m) w:scroll{ ypagerel = -(m.count or 1) } end,
	},
	page_down = {
		desc = "Scroll the current page down a full screen.",
		func = function (w, m) w:scroll{ ypagerel =  (m.count or 1) } end,
	},
}, zoom = {
	zoom_in = {
		desc = "Zoom in to the current page.",
		func = function (w, m) w:zoom_in(settings.get_setting("window.zoom_step") * (m.count or 1)) end,
	},
	zoom_out = {
		desc = "Zoom out from the current page.",
		func = function (w, m) w:zoom_out(settings.get_setting("window.zoom_step") * (m.count or 1)) end,
	},
	zoom_set = {
		desc = "Zoom to a specific percentage when specifying a count, and reset the page zoom otherwise.",
		func = function (w, m)
			local zoom_level = m.count or settings.get_setting_for_view(w.view, "webview.zoom_level")
			w:zoom_set(zoom_level/100)
		end,
	},
}}

modes.add_binds("normal", {
	-- Autoparse the `[count]` before a binding and re-call the hit function
	-- with the count removed and added to the opts table.
	{ "<any>", [[Meta-binding to detect the `^[count]` syntax. The `[count]` is parsed
		and stripped from the internal buffer string and the value assigned to
		`state.count`. Then `lousy.bind.hit()` is re-called with the modified
		buffer string & original modifier state.

		#### Example binding

		lousy.bind.key({}, "%", function (w, state)
			w:scroll{ ypct = state.count }
		end, { count = 0 })

	This binding demonstrates several concepts. Firstly that you are able to
	specify per-binding default values of `count`. In this case if the user
		types `"%"` the document will be scrolled vertically to `0%` (the top).

		If the user types `"100%"` then the document will be scrolled to `100%`
		(the bottom). All without the need to use `lousy.bind.buf` bindings
		everywhere and or using a `^(%d*)` pattern prefix on every binding which
		would like to make use of the `[count]` syntax.]],
		function (w, m)
			local count, buffer
			if m.buffer then
				count = string.match(m.buffer, "^(%d+)")
			end
			if count then
				buffer = string.sub(m.buffer, #count + 1, (m.updated_buf and -2) or -1)
				local opts = join(m, {count = tonumber(count)})
				opts.buffer = (#buffer > 0 and buffer) or nil
				if lousy.bind.hit(w, m.binds, m.mods, m.key, opts) then
					return true
				end
			end
			return false
		end },

	{ "i", "Enter `insert` mode.", function (w) w:set_mode("insert") end },
	{ ":", "Enter `command` mode.", function (w) w:set_mode("command") end },
	{ "<Control-z>", "Enter `passthrough` mode.", function (w) w:set_mode("passthrough") end },

	-- Scrolling
	{ "j", actions.scroll.down },
	{ "k", actions.scroll.up },
	{ "h", actions.scroll.left },
	{ "l", actions.scroll.right },

	{ "^", "Scroll to the absolute left of the document.", function (w) w:scroll{ x =  0 } end },
	{ "$", "Scroll to the absolute right of the document.", function (w) w:scroll{ x = -1 } end },
	{ "0", "Scroll to the top of the document.",
		function (w, m) if not m.count then w:scroll{ y = 0 } else return false end end },
	{ "<Control-e>", actions.scroll.down },
	{ "<Control-y>", actions.scroll.up },

	{ "<Control-d>", "Scroll half page down.", function (w) w:scroll{ ypagerel =  0.5 } end },
	{ "<Control-u>", "Scroll half page up.", function (w) w:scroll{ ypagerel = -0.5 } end },
	{ "<Control-f>", actions.scroll.page_down },
	{ "<Control-b>", actions.scroll.page_up },
	{ "<Page_Down>", actions.scroll.page_down },
	{ "<Page_Up>", actions.scroll.page_up },

	-- Specific scroll
	{ "gg", "Go to the top of the document.", function (w, m) w:scroll{ ypct = m.count } end, {count=0} },
	{ "G", "Go to the bottom of the document.", function (w, m) w:scroll{ ypct = m.count } end, {count=100} },
	{ "%", "Go to `[count]` percent of the document.", function (w, m) w:scroll{ ypct = m.count } end },

	-- Zoom
	{ "+", actions.zoom.zoom_in },
	{ "-", actions.zoom.zoom_out },
	{ "=", actions.zoom.zoom_set },
	{ "<F11>", "Toggle fullscreen mode.", function (w) w.win.fullscreen = not w.win.fullscreen end },

	-- Open primary selection contents.
	{ "pp", [[Open URLs based on the current primary selection contents in the current tab.]],
		function (w)
			local uris = split_uri(luakit.selection.primary or "")
			if #uris == 0 then w:notify("Nothing in primary selection...") return end
			local uri1 = table.remove(uris, 1)
			w:navigate(uri1)
			for _, uri in ipairs(uris) do
				w:new_tab(uri)
			end
		end },
	{ "pt", [[Open URLs based on the current primary selection contents in new tabs.]],
		function (w)
			local uris = split_uri(luakit.selection.primary or "")
			if #uris == 0 then w:notify("Nothing in primary selection...") return end
			for _, uri in ipairs(uris) do
				w:new_tab(uri)
			end
		end },
	{ "pw", [[Open URLs based on the current primary selection contents in a new window.]],
		function (w)
			local uris = split_uri(luakit.selection.primary or "")
			if #uris == 0 then w:notify("Nothing in primary selection...") return end
			local uri1 = table.remove(uris, 1)
			w = window.new({uri1})
			for _, uri in ipairs(uris) do
				w:new_tab(uri)
			end
		end },

	-- Open clipboard contents.
	{ "PP", [[Open URLs based on the current clipboard selection contents in the current tab.]],
		function (w)
			local uris = split_uri(luakit.selection.clipboard or "")
			if #uris == 0 then w:notify("Nothing in clipboard...") return end
			local uri1 = table.remove(uris, 1)
			w:navigate(uri1)
			for _, uri in ipairs(uris) do
				w:new_tab(uri)
			end
		end },
	{ "PT", [[Open URLs based on the current clipboard selection contents in new tabs.]],
		function (w)
			local uris = split_uri(luakit.selection.clipboard or "")
			if #uris == 0 then w:notify("Nothing in clipboard...") return end
			for _, uri in ipairs(uris) do
				w:new_tab(uri)
			end
		end },
	{ "PW", [[Open URLs based on the current clipboard selection contents in a new window.]],
		function (w)
			local uris = split_uri(luakit.selection.clipboard or "")
			if #uris == 0 then w:notify("Nothing in clipboard...") return end
			local uri1 = table.remove(uris, 1)
			w = window.new({uri1})
			for _, uri in ipairs(uris) do
				w:new_tab(uri)
			end
		end },

	-- Yanking
	{ "Y", "Yank current URI to primary selection.", function (w)
			local uri = string.gsub(w.view.uri or "", " ", "%%20")
			luakit.selection.primary = uri
			w:notify("Yanked uri: " .. uri)
		end },
	{"y", "Yank current URI to clipboard.", function (w)
		local uri = string.gsub(w.view.uri or "", " ", "%%20")
		luakit.selection.clipboard = uri
		w:notify("Yanked uri (to clipboard): " .. uri)
	end },
	{ "ys", "Yank current selection to clipboard.", function()
		luakit.selection.clipboard = luakit.selection.primary
	end },

	-- Commands
	{ "<Control-a>", "Increment last number in URL.",
		function (w, m)
			local uri = w:inc_uri(m.count)
			if uri ~= w.view.uri then w:navigate(uri)
			else w:warning("No number in URL") end
		end, {count = 1} },
	{ "<Control-x>", "Decrement last number in URL.",
		function (w, m)
			local uri = w:inc_uri(-m.count)
			if uri ~= w.view.uri then w:navigate(uri)
			else w:warning("No number in URL") end
		end, {count = 1} },
	{ "o", "Open one or more URLs.", function (w) w:enter_cmd(":open ") end },
	{ "O", "Open one or more URLs in a new tab.", function (w) w:enter_cmd(":tabopen ") end },
	{ "<Control-o>", "Open one or more URLs in a new window.", function (w) w:enter_cmd(":winopen ") end },

	{ "H", "Go back in the browser history `[count=1]` items.", function (w, m) w:back(m.count) end },
	{ "L", "Go forward in the browser history `[count=1]` times.", function (w, m) w:forward(m.count) end },
	{ "<Back>", "Go back in the browser history.", function (w, m) w:back(m.count) end },
	{ "<Forward>", "Go forward in the browser history.", function (w, m) w:forward(m.count) end },

	-- Tab
	{ "J", "Go to previous tab.", function (w) w:prev_tab() end },
	{ "K", "Go to next tab.", function (w) w:next_tab() end },
	{ "<F1>", "Show help.", function (w) w:run_cmd(":help") end },
	{ "<F12>", "Toggle web inspector.", function (w) w:run_cmd(":inspect!") end },
	{ "gT", "Go to previous tab.", function (w) w:prev_tab() end },

	{ "gt", "Go to next tab (or `[count]` nth tab).",
		function (w, m)
			if not w:goto_tab(m.count) then w:next_tab() end
	end, {count=0} },
	{ "g0", "Go to first tab.", function (w) w:goto_tab(1) end },
	{ "g$", "Go to last tab.", function (w) w:goto_tab(-1) end },

	{ "t", "Open a new tab.", function (w) w:new_tab(settings.get_setting("window.new_tab_page")) end },
	{ "q", "Close current tab (or `[count]` tabs).",
		function (w, m) for _=1,m.count do w:close_tab() end end, {count=1} },

	{ "<Control-Shift-J>", "Reorder tab left `[count=1]` positions.",
		function (w, m)
			w.tabs:reorder(w.view,
				(w.tabs:current() - m.count) % w.tabs:count())
		end, {count=1} },

	{ "<Control-Shift-K>", "Reorder tab right `[count=1]` positions.",
		function (w, m)
			w.tabs:reorder(w.view,
				(w.tabs:current() + m.count) % w.tabs:count())
		end, {count=1} },

	{ "^gH$", "Open homepage in new tab.", function (w) w:new_tab(settings.get_setting("window.home_page")) end },
	{ "^gh$", "Open homepage.", function (w) w:navigate(settings.get_setting("window.home_page")) end },
	{ "^gy$", "Duplicate current tab.",
		function (w, m)
			local params = {
				{ session_state = w.view.session_state },
				{ private = w.view.private, order = taborder.after_current }
			}
			for _=1,m.count do w:new_tab(unpack(params)) end
		end, {count=1} },

	{ "r", "Reload current tab.", function (w) w:reload() end },
	{ "R", "Reload current tab (skipping cache).", function (w) w:reload(true) end },
	{ "<Control-c>", "Stop loading the current tab.", function (w) w.view:stop() end },
	{ "<Control-R>", "Restart luakit (reloading configs).", function (w) w:restart() end },

	-- Window
	{ "^ZZ$", "Quit and save the session.", function (w) w:save_session() w:close_win() end },
	{ "^ZQ$", "Quit and don't save the session.", function (w) w:close_win() end },
})

modes.add_binds("insert", {
	{ "<Control-z>", "Enter `passthrough` mode, ignores all luakit keybindings.",
		function (w) w:set_mode("passthrough") end },
})

modes.add_binds("passthrough", {
	{ "<Shift-Escape>", "Return to `normal` mode.", function (w) w:set_prompt(); w:set_mode() end },
})

-- Switching tabs with Mod1+{1,2,3,...}
do
	local mod1binds = {}
	for i=1,10 do
		table.insert(mod1binds, {
			("<Mod1-%d>"):format(i % 10), "Jump to tab at index "..i..".", function (w) w.tabs:switch(i) end
		})
	end
	modes.add_binds("normal", mod1binds)
end

-- Command bindings which are matched in the "command" mode from text
-- entered into the input bar.
modes.add_cmds({
	{ "^%S+!", [[Detect bang syntax in `:command!` and recursively calls
		`lousy.bind.match_cmd(..)` removing the bang from the command string
		and setting `bang = true` in the bind opts table.]],
		function (w, opts)
			local command, args = opts.buffer
			command, args = string.match(command, "^(%S+)!+(.*)")
			if command then
				opts = join(opts, { bang = true })
				return lousy.bind.match_cmd(w, opts.binds, command .. args, opts)
			end
		end },

	{ "<Control-Return>", [[Expand `:[tab,win]open example` to `:[tab,win]open www.example.com`.]],
		function (w)
			local tokens = split(w.ibar.input.text, "%s+")
			if string.match(tokens[1], "^:%w*open$") and #tokens == 2 then
				w:enter_cmd(string.format("%s www.%s.com", tokens[1], tokens[2]))
			end
			w:activate()
		end },

	{ ":c[lose]", "Close current tab.", function (w) w:close_tab() end },
	{ ":print", "Print current page.", function (w) w.view:eval_js("print()", { no_return = true }) end },
	{ ":stop", "Stop loading.", function (w) w.view:stop() end },
	{ ":reload", "Reload page.", function (w) w:reload() end },
	{ ":restart", "Restart browser (reload config files).", function (w, o) w:restart(o.bang) end },
	{ ":write", "Save current session.", function (w) w:save_session() end },
	{ ":noh[lsearch]", "Clear search highlighting.", function (w) w:clear_search() end },
	{ ":back", "Go back in the browser history `[count=1]` items.", function (w, o) w:back(tonumber(o.arg) or 1) end },
	{ ":f[orward]", "Go forward in the browser history `[count=1]` items.",
		function (w, o) w:forward(tonumber(o.arg) or 1) end },
	{ ":inc[rease]", "Increment last number in URL.", function (w, o) w:navigate(w:inc_uri(tonumber(o.arg) or 1)) end },
	{ ":o[pen]", "Open one or more URLs.", {
		func = function (w, o) w:navigate(o.arg) end,
		format = "{uri}",
	}},
	{ ":t[abopen]", "Open one or more URLs in a new tab.", {
		func = function (w, o) w:new_tab(o.arg, { switch = true }) end,
		format = "{uri}",
	}},
	{ ":priv-t[abopen]", "Open one or more URLs in a new private tab.", {
		func = function (w, o) w:new_tab(o.arg, { private = true }) end,
		format = "{uri}",
	}},
	{ ":w[inopen]", "Open one or more URLs in a new window.", {
		func = function (_, o) window.new({o.arg}) end,
		format = "{uri}",
	}},
	{ ":javascript, :js", "Evaluate JavaScript snippet.",
		function (w, o)
			if o.arg then
				w.view:eval_js(o.arg, {
					no_return = true,
					callback = function (_, err)
						w:error(err)
					end,
				})
			else
				w:error("No argument provided")
			end
		end },

	-- Tab manipulation commands
	{ ":tab", "Execute command and open result in new tab.", {
		func = function (w, o) w:new_tab() w:run_cmd(":" .. o.arg) end,
		format = "{command}",
	}},
	{ ":tabd[o]", "Execute command in each tab.", {
		func = function (w, o) w:each_tab(function () w:run_cmd(":" .. o.arg) end) end,
		format = "{command}",
	}},
	{ ":tabdu[plicate]", "Duplicate current tab.",
		function (w) w:new_tab({ session_state = w.view.session_state }) end },
	{ ":tabfir[st]", "Switch to first tab.", function (w) w:goto_tab(1) end },
	{ ":tabl[ast]", "Switch to last tab.", function (w) w:goto_tab(-1) end },
	{ ":tabn[ext]", "Switch to the next tab.", function (w) w:next_tab() end },
	{ ":tabp[revious]", "Switch to the previous tab.", function (w) w:prev_tab() end },
	{ ":tabde[tach]", "Move the current tab tab into a new window.", function (w) window.new({w.view}) end },
	{ ":q[uit]", "Close the current window.", function (w, o) w:close_win(o.bang) end },

	{ ":wq[all]", "Save the session and quit.", function (w, o)
		local force = o.bang
		if not force and not w:can_quit() then return end
		w:save_session()
		for _, ww in pairs(window.bywidget) do
			ww:close_win(true)
		end
	end },

	{ ":lua", "Evaluate Lua snippet.", function (w, o)
			local a = o.arg
			if a then
				-- Parse as expression first, then statement
				-- With this order an error message won't contain the print() wrapper
				local ret, err = loadstring("print(" .. a .. ")", "lua-cmd")
				if err then
					ret, err = loadstring(a, "lua-cmd")
				end
				if err then
					w:error(err)
				else
					setfenv(ret, setmetatable({}, { __index = function (_, k)
						if _G[k] ~= nil then return _G[k] end
						if k == "w" then return w end
						if package.loaded[k] then return package.loaded[k] end
			end, __newindex = _G }))
		ret()
	end
else
	w:set_mode("lua")
end
	end },

	{ ":dump", "Dump current tabs html to file.",
		function (w, o)
			local fname = string.gsub(w.win.title, '[^%w%.%-]', '_')..'.html' -- sanitize filename
			local file = o.arg or luakit.save_file("Save file", w.win, xdg.download_dir or '.', fname)
			if file then
				local fd = assert(io.open(file, "w"), "failed to open: " .. file)
				local view = w.view
				local co = coroutine.create(function ()
					local html = assert(view:get_source(), "Unable to get HTML")
					assert(fd:write(html), "unable to save html")
					io.close(fd)
					w:notify("Dumped HTML to: " .. file)
				end)
				luakit.idle_add(function () coroutine.resume(co) end)
			end
		end },

	{ ":save", "Save page as shown to file.",
		function (w, o)
			local fname = string.gsub(w.win.title, '[^%w%.%-]', '_')..'.mhtml' -- sanitize filename
			local file = o.arg or luakit.save_file("Save file", w.win, xdg.download_dir or '.', fname)
			if file then
				local view = w.view
				-- FIXME: note that this is called after all calls
				-- to luakit.save_file(), including those not called
				-- by :save; the better way to do this is to make
				-- save_file() return an ID, store that in a table, and
				-- check that table before showing a notification.
				view:add_signal("save-finished", function(v, f, err)
					local ww = webview.window(v)
					ww:notify(err or ("Saved to: " .. f))
				end)
				view:save(file)
			end
		end },
})

local function convert (str, new_type)
	local convertion_table = {
		number = tonumber,
		boolean = function (val)
			if val == "true" then return true
			elseif val == "false" then return false
			else error("'"..val.."' is not a boolean")
			end
		end,
		string = function (val) return val end,
		enum = function (val) return val end,
	}

	return convertion_table[new_type](str)
end

modes.add_cmds({
	{ ":set", "Change a setting.", {
		func = function (w, o)
			o.arg = o.arg or ""
			local key, value = o.arg:match("^%s*(%S+)%s+(.*)$")
			if (key and value) == nil then
				w:error("Usage: ':set <setting> <value>'")
				return
			end
			local setting = settings.get_settings()[key]
			if setting == nil then
				w:error("Setting not found: "..key)
				return
			end
			value = convert(value, setting.type)
			settings.set_setting(key, value)
		end,
		format = "{setting}",
	}},
	{ ":seton", "Change a setting for a specific domain.", {
		func = function (w, o)
			o.arg = o.arg or ""
			local domain, key, value = o.arg:match("^%s*(%S+)%s+(%S+)%s+(.*)$")
			if (domain and key and value) == nil then
				w:error("Usage: ':seton <domain> <setting> <value>'")
				return
			end
			local setting = settings.get_settings()[key]
			if setting == nil then
				w:error("Setting not found: "..key)
				return
			end
			value = convert(value, setting.type)
			settings.set_setting(key, value, { domain = domain })
		end,
		format = "{domain} {setting}",
	}}
})

modes.remove_binds("passthrough", {"<Escape>"})
