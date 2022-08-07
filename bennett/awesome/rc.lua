---@diagnostic disable: undefined-global
print("reloading")
pcall(require, "luarocks.loader")

--load libraries
local awful = require "awful"
local beautiful = require "beautiful"
local naughty = require "naughty"
local wibox = require "wibox"
local gears = require "gears"
local images = require "images"
local dpi = beautiful.xresources.apply_dpi
local GLib = require("lgi").GLib
local cairo = require("lgi").cairo
naughty.notify {text="reloaded config"}

-- error handling before I load handwritten libraries lol
-- can't trust myself lol
if awesome.startup_errors then naughty.notify({
	preset = naughty.config.presets.critical,
	title = "Oops, there were errors during startup!",
	text = awesome.startup_errors }) end

local in_error = false
awesome.connect_signal("debug::error", function (err)
	-- Make sure we don't go into an endless error loop
	if in_error then return end
	in_error = true

	naughty.notify({ preset = naughty.config.presets.critical,
		title = "Oops, an error happened!",
		text = tostring(err) })
	in_error = false
end)
function TEST(str) naughty.notify {text=tostring(str), --[[timeout=20]]} end


--libraries
local rubato = require "lib.rubato"
local color = require "lib.color"
local slider = require "lib.awesome-widgets.slider"
local coolwidget = require "lib.awesome-widgets.coolwidget"
local recycler = require "lib.awesome-widgets.recycler"
local bling = require "lib.bling"
local playerctl = bling.signal.playerctl.lib()

--load other important stuff
require "awful.hotkeys_popup"
require "awful.hotkeys_popup.keys"
require "awful.autofocus"

require "lib.volume"
require "lib.deviceinfo"
--require "lib.battery"

local globalkeys, clientkeys, clientbuttons = table.unpack(require "binding.bindings_key")

--if cpu is at like 95% then make rubato instant
awesome.connect_signal("signal::cpu", function(percent) RUBATO_MANAGER.timed.override.instant = percent > 95 end)

-- does some more stuff
awesome.register_xproperty("WM_CLASS", "string") --picom stuff?
awful.spawn.with_shell "sh -c \"if [ ! $(pgrep picom) ]; then picom; fi\""
beautiful.init({
	hotkeys_border_width = 0,
	hotkeys_label_fg = "#000000",
})

--TODO: make its own file
awful.rules.rules = {
	{	rule = {},
		properties = {
			border_width = 0,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen
		},
	},
	{	rule_any = { type = {"normal", "dialog"} },
		properties = { titlebars_enabled = true },
	},
    {	rule_any = { --floating
			class = {
				"Blueman-manager",
				"Tor Browser",
				"Wpa_gui",
				"sun-awt-X11-XWindowPeer"
			},
			role = {"pop-up"}
		},
		properties = { floating = true },
	},
	{	rule = { --android studio
			instance = 'sun-awt-X11-XWindowPeer',
			class = 'jetbrains-studio',
			type = 'dialog'
		},
		properties = {
			titlebars_enabled = false,
			border_width = 0,
			floating = true,
			focus = true,
			placement = nil
		}
	},
	{	rule = { --more android studio
			instance = 'sun-awt-X11-XFramePeer',
			class = 'jetbrains-studio',
			name = 'Android Virtual Device Manager'
		},
		rule_any = {
			name = {
				'Android Virtual Device Manager',
				'Welcome to Android Studio',
				'win0'
			}
		},
		properties = {
			titlebars_enabled = true,
			floating = true,
			focus = true,
			placement = awful.placement.centered
		}
	},
}

TAGLIST_ICON_THEME="Papirus"

--searches through likely directories for the theme folder in question
--this works on nixos so it'll probably work on just about anything
local icon_directories = setmetatable({}, {
	__index=function(self, value)
		if rawget(self, value) then return rawget(self, value) end

		local dir = GLib.build_filenamev({GLib.get_home_dir(), ".icons"}).."/"..value
		if gears.filesystem.dir_readable(dir) then rawst(self, value, dir); return dir end

		dir = GLib.build_filenamev({GLib.get_user_data_dir(), "icons"}).."/"..value
		if gears.filesystem.dir_readable(dir) then rawst(self, value, dir); return dir end

		for _,v in ipairs(GLib.get_system_data_dirs()) do
			dir = GLib.build_filenamev({v, "icons"}).."/"..value
			if gears.filesystem.dir_readable(dir) then rawset(self, value, dir); return dir end
		end
	end
})
local function get_icon(name, path)
	local icon_path = icon_directories[name].."/"..path
	if not io.open(icon_path, "r") then return end --ensure that it exists

	--create a surface from the icon path
	--local s = gears.surface(icon_path)
	local s = gears.surface(icon_path)
	local img = cairo.ImageSurface.create(cairo.Format.ARGB32, s:get_width(), s:get_height())
	local cr  = cairo.Context(img)
	cr:set_source_surface(s, 0, 0)
	cr:paint()

	--update the client's icon
	return img
end
local function set_client_icon(client)
	local icon = get_icon(TAGLIST_ICON_THEME, "128x128/apps/"..string.lower(client.class)..".svg")
	if icon then client.icon = icon._native end
end

--TODO: fix not working for qutebrowser on new laptop for some reason
-- does client stuff
client.connect_signal("manage", function (client)
	-- Prevent clients from being unreachable after screen count changes.
    if awesome.startup
			and not client.size_hints.user_position
			and not client.size_hints.program_position then
		awful.placement.no_offscreen(client)
    end

	--set icon theme
	set_client_icon(client)
	local editing = false
	client:connect_signal("property::icon", function()
		if editing then return end
		editing = true; set_client_icon(client); editing = false
	end)
end)
client.connect_signal("mouse::enter", function(c) c:emit_signal("request::activate", "mouse_enter", {raise = false}) end)

-- A bunch of table stdlib additions because
-- these are pretty hard to live without
function table.tablex2()
	local obj = {_props = {}, _props_i = {}}
	setmetatable(obj, {
		__index = function(self, key)
			if table.index({"insert","remove","collapse","iter"}, key) then return rawget(obj, key) end
			return self._props[key] or self._props_i[key]
		end,
		__newindex = function(self, key, value)
			if self._props[key] then self._props[key] = value
			elseif self._props_i[key] then self._props_i[key] = value
			else
				self._props[key] = value
				self._props_i[value] = key
			end
		end
	})
	rawset(obj, "insert", function(self, item)
		local index = 1
		while true do
			if not self._props[index] then
				self._props[index] = item
				self._props_i[item] = index
				break
			end
			index = index + 1
		end
	end)
	rawset(obj, "remove", function(self, item)
		for k,v in pairs(self._props) do
			if v == item then
				self._props[k] = nil
				self._props_i[v] = nil
				break
			end
		end
		self:collapse()
	end)
	rawset(obj, "remove_at", function(self, index)
		for k,v in pairs(self._props_i) do
			if v == index then
				self._props[v] = nil
				self._props_i[k] = nil
				break
			end
		end
		self:collapse()
	end)
	rawset(obj, "collapse", function(self)
		local open = {}
		for i=1,table.maxn(self._props) do
			if self._props[i] == nil then table.insert(open, i)
			elseif open[1] ~= nil then
				self._props[open[1]] = self._props[i]
				self._props_i[self._props[i]] = open[1]
				table.remove(open, 1)
			end
		end
	end)
	rawset(obj, "iter", function(self) return self._props end)
	return obj
end
function table.remove_element(tbl, element)
	local res
	for k,v in pairs(tbl) do if v == element then res = table.remove(tbl, k); break end end
	return res
end
function table.index(table, element)
	for k,v in pairs(table) do if element == v then return k end end
	return false
end
function table.tostringdeep(tbl, indents)
	indents = indents or ""
	local res = ""
	for k,v in pairs(tbl) do
		if type(v) == "table" then res = res.."\n"..indents..tostring(k)..": "..table.tostringdeep(v, indents.."  ")
		else res = res.."\n"..indents..tostring(k)..": "..tostring(v) end
	end
	return res
end
function table.tostring(table)local r="{ ";for k,v in pairs(table)do r=r..tostring(k).."="..tostring(v)..", "end;return r:sub(1,-3).." }"end
function table.map(table, func)
	local res = {}
	for k,v in pairs(table) do res[k] = func(v) end
	return res
end
function table.apply(table, func)
	for k,v in pairs(table) do table[k] = func(v) end
end

local theme = {
	
}
local theme_update_functions = {}

local ui = {
	screen = nil,
	create = function(ui, screen)
		ui.screen = screen
		ui:create_sidebar()
	end,

	create_tasklist_item = function(ui)

		--placeholder textbox for finding text size
		local textsize = wibox.widget {
			font = "Liberation Sans 11", text = "Yy",
			widget = wibox.widget.textbox
		}:get_preferred_size_at_dpi(ui.screen.dpi)

		--creates the actual widget
		local w = wibox.widget {
			{
				{
					forced_height = dpi(30),
					forced_width = dpi(30),
					widget = awful.widget.clienticon,
					id = "icon"
				},
				margins = dpi(5),
				widget = wibox.container.margin
			},
			{
				{
					font = "Liberation Sans 11",
					ellipsize = "end",
					widget = wibox.widget.textbox,
					id = "text"
				},
				forced_width = dpi(380) - dpi(40) - dpi(32+6),
				forced_height = dpi(40),
				left = dpi(8),
				right = dpi(4),
				top = (dpi(40) - textsize) / 2,
				bottom = (dpi(40) - textsize) / 2,
				widget = wibox.container.margin
			},
			{
				{
					image = images.drag,
					resize = false,
					widget = wibox.widget.imagebox
				},
				--this is here because for some weird reason it doesn't
				--actually heed the valign and halign...
				margins = dpi(4),
				valign = "center",
				halign = "center",
				width = dpi(32),
				height = dpi(32),
				strategy = "exact",
				shape = gears.shape.circle,
				id = "drag_bg",
				widget = coolwidget.background.constraint.place.margin.container
			},
			bg = "#444956",
			shape = gears.shape.rounded_rect,
			strategy = "exact",
			layout = coolwidget.constraint.background.fixed.horizontal
		}
		local icon = w:get_children_by_id("icon")[1]
		local text = w:get_children_by_id("text")[1]
		local drag_bg = w:get_children_by_id("drag_bg")[1]

		--animates it with the sidebar
		ui.sidebar_timed:subscribe(function(pos)
			if w.opacity == 0 then return end
			w.width = pos * dpi(340) + dpi(40)
		end)

		--instantiates or destroys (sends to unused) a widget
		function w:populate(client)
			self.client = client
			text.text = client.name

			if client then icon:set_client(client) end
			client:connect_signal("property::name", function() text.text = client.name end)
			client:connect_signal("property::minimized", function() --[[TODO: do something]] end)

			w.width = ui.sidebar_timed.pos * dpi(340) + dpi(40)
		end

		local drag_trans = color.transition(color.color{hex="#444956"}, color.color{hex="#444956"} + "0.06l")
		local drag_timed = rubato.timed {
			duration = 0.2,
			intro = 0.075,
			subscribed = function(pos) drag_bg.bg = drag_trans(pos).hex; drag_bg:emit_signal("widget::redraw_needed") end
		}
		local drag_timer = gears.timer {
			timeout = 0.8,
			single_shot = true,
			callback = function() ui.dropdown:popup(w.client, position_timed.target) end
		}
		drag_bg:connect_signal("mouse::enter", function()
			drag_timed.target = 1
			drag_timer:start()
		end)
		drag_bg:connect_signal("mouse::leave", function()
			drag_timed.target = 0
			drag_timer:stop()
		end)

		return w
	end,

	create_tasklist_dropdown_item = function(text, image, func)
		local item_trans = color.transition(color.color{hex="#444956"} + "0.03l", color.color{hex="#444956"} + "0.05l")
		local w = wibox.widget {
			{	nil,
				{	text = text,
					align = "center",
					widget = wibox.widget.textbox },
				{	{	forced_width = dpi(24),
						image = image,
						widget = wibox.widget.imagebox },
					top = dpi(8),
					bottom = dpi(8),
					right = dpi(6),
					halign = "center",
					widget = wibox.container.margin },
				forced_height = dpi(40),
				forced_width = dpi(160),
				layout = wibox.layout.align.horizontal,
				buttons = awful.button({}, 1, func), },
			widget = wibox.container.background
		}
		w.item_timer = rubato.timed {
			duration = 0.1,
			subscribed = function(pos) w.bg = item_trans(pos).hex end
		}
		w:connect_signal("mouse::enter", function() w.item_timer.target = 1 end)
		w:connect_signal("mouse::leave", function() w.item_timer.target = 0 end)
		return w
	end,
	create_tasklist_dropdown = function(ui)
		local minimize = ui.create_tasklist_dropdown_item("Minimize", images.minimize, function()
			ui.dropdown.client.minimized = not ui.dropdown.client.minimized
		end)
		local close = ui.create_tasklist_dropdown_item("Close", images.close, function()
			ui.dropdown.client:kill()
			ui.dropdown:unpopup()
		end)
		local fclose = ui.create_tasklist_dropdown_item("Force Close", images.fclose, function()
			awesome.kill(ui.dropdown.client.pid, 9)
			ui.dropdown:unpopup()
		end)

		minimize.shape = function(cr, width, height) return gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false) end
		fclose.shape = function(cr, width, height) return gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true) end

		ui.dropdown = wibox.widget {
			{
				minimize,
				close,
				fclose,
				layout = wibox.layout.fixed.vertical
			},
			bg = (color.color{hex="#444956"} + "0.03l").hex,
			shape = gears.shape.rounded_rect,
			layout = wibox.container.background,
			opacity = 0,
		}
		ui.dropdowns:add_at(ui.dropdown, {x=dpi(400)-dpi(160)-dpi(6),y=0})

		local popup_timed = rubato.timed {
			duration = 0.225,
			subscribed = function(pos)
				ui.dropdown.opacity = pos
				ui.dropdown:emit_signal("widget::redraw_needed")

				-- only hide away when opacity is zero
				if pos == 0 then
					ui.dropdowns:move_widget(ui.dropdown, {x=-dpi(160), y=0})
				end
			end
		}
		function ui.dropdown:popup(client, position)
			self.client = client or self.client
			if position then ui.dropdowns:move_widget(self, {x=dpi(400)-dpi(160)-dpi(6), y=position}) end
			popup_timed.target = 1

			minimize.bg = (color.color{hex="#444956"} + "0.05l").hex
			minimize.item_timer.position = 1
			minimize.item_timer._props.target = 1

		end
		function ui.dropdown:unpopup() popup_timed.target = 0 end

		ui.dropdown:connect_signal("mouse::enter", function() ui.dropdown:popup() end)
		ui.dropdown:connect_signal("mouse::leave", function() ui.dropdown:unpopup() end)

	end,
	create_tasklist = function(ui)
		local layout = recycler(function() return ui:create_tasklist_item() end, {
			pady = 6,
			padx = 2,
			spacing = 8,
		})

		client.connect_signal("tagged", function(client)
			if not table.index(ui.screen.selected_tag:clients(), client) then return end
			layout:add(client)
		end)
		client.connect_signal("untagged", function(client)
			if table.index(ui.screen.selected_tag:clients(), client) then return end
			layout:remove(layout:get_by_args(client))
		end)
		ui.screen:connect_signal("tag::history::update", function(screen)
			layout:set_children(table.unpack(screen.selected_tag:clients()))

		end)

		return layout
	end,

	create_taglist = function(ui)
		local ti = {} --inverse taglist
		local layout = wibox.layout.manual()
		layout.forced_width = dpi(14)

		for i, tag in ipairs(ui.screen.tags) do
			ti[tag] = i --add to inverse taglist

			local text = wibox.widget {
				text = "",
				align = "center",
				widget = wibox.widget.textbox
			}
			local w = wibox.widget {
				text,
				bg = "#444956",
				forced_width = dpi(6),
				forced_height = dpi(30),
				shape = gears.shape.rounded_rect,
				widget = wibox.container.background
			}
			layout:add_at(w, {x=dpi(4), y=i*dpi(36)-dpi(30)})

			local populated_trans = color.transition(color.color{hex="#444956"}, color.color{hex="#444956"} + "0.2l")
			local populated_timed = rubato.timed {
				duration = 0.2,
				intro = 0.075,
				subscribed = function(pos) w.bg = populated_trans(pos).hex end
			}
			client.connect_signal("tagged", function() populated_timed.target = math.min(#tag:clients(),1) end)
			client.connect_signal("untagged", function() populated_timed.target = math.min(#tag:clients(),1) end)
			tag:connect_signal("property::urgent", function()
				if awful.tag.getproperty(tag, "urgent") then text.text = "!"
				else text.text = "" end
			end)

		end

		local w = wibox.widget {
			wibox.widget {},
			bg = "#489568",
			forced_width = dpi(8),
			forced_height = dpi(30),
			shape = gears.shape.rounded_rect,
			widget = wibox.container.background
		}
		layout:add_at(w, {x=0, y=0})
		local pos_timed = rubato.timed {
			pos = 1,
			duration = 0.3,
			intro = 0.1,
			debug = true,
			subscribed = function(pos) layout:move_widget(w, {x=dpi(3), y=pos*dpi(36)-dpi(30)}) end
		}
		local pos_hover_trans = color.transition(color.color{hex="#489568"}, color.color{hex="#489568"} + "0.06l")
		local pos_hover_timed = rubato.timed {
			duration = 0.2,
			intro = 0.075,
			subscribed = function(pos) w.bg = pos_hover_trans(pos).hex end
		}
		ui.screen:connect_signal("tag::history::update", function()
			pos_timed.target = ti[ui.screen.selected_tag]
			pos_hover_timed.target = 0
		end)
		w:connect_signal("mouse::enter", function() pos_hover_timed.target = 1 end)
		w:connect_signal("mouse::leave", function() pos_hover_timed.target = 0 end)

		return layout
	end,

	widgets = {
		create_device_info_widget = function(icon, id)
			local w = {
				{	{	image = icon,
						forced_width = dpi(20),
						forced_height = dpi(20),
						widget = wibox.widget.imagebox },
					{	{	{	max_value = 1,
								value = 0.5,
								shape = gears.shape.rounded_bar,
								bar_shape = gears.shape.rounded_bar,
								background_color = "#363a44",
								widget = wibox.widget.progressbar,
								id = id },
							direction = "east",
							--this value doesn't actually matter as long as it's low
							--for some reason the progress bar will fill no matter what,
							--hence the margin layout
							forced_width = 0,
							widget = wibox.container.rotate },
						strategy = "exact",
						left = dpi(4),
						right = dpi(4),
						top = dpi(8),
						widget = wibox.container.margin },
					layout = wibox.layout.align.vertical },
				top = dpi(8),
				bottom = dpi(8),
				left = dpi(8),
				widget = wibox.container.margin
			}
			return w
		end,
		create_device_setting_slider = function(icon_path, id)
			local w = {
				{
					nil,
					{
						{
							color_bar = color.color {hex="#363a44"},
							color_bar_active = color.color {hex="#444956"} + "0.3l",
							lw_margins = 0,
							forced_height = dpi(24),
							widget = slider,
							id = id
						},
						right = dpi(10),
						widget = wibox.container.margin
					},
					{
						image = icon_path,
						forced_height = dpi(20),
						forced_width = dpi(20),
						widget = wibox.widget.imagebox,
					},
					layout = wibox.layout.align.horizontal
				},
				widget = wibox.container.background
			}
			return w
		end,
		create_toggle_button = function(icon, func, init)
			local trans = color.transition(color.color {hex="#1f2228"}, color.color {hex="#489568"})
			local state = rubato.timed {duration=0.2, pos=init}
			local hover = rubato.timed {duration=0.2}
			local w = wibox.widget {
				{
					{
						forced_width = dpi(20),
						forced_height = dpi(20),
						image = icon,
						widget = wibox.widget.imagebox
					},
					widget = wibox.container.place
				},
				buttons = awful.button({}, 1, function() state.target = (state.target + 1) % 2; func(state.target) end),
				forced_height = dpi(60),
				bg = (color.color {hex="#363a44"} - "0.1l").hex,
				shape = gears.shape.rounded_rect,
				widget = wibox.container.background
			}
			local function update_color() w.bg = (trans(state.pos) + ("%fl"):format(hover.pos * (state.pos + 1) / 2 * 3)).hex; w:emit_signal("widget::redraw_needed") end
			w:connect_signal("mouse::enter", function() hover.target = 0.01 end)
			w:connect_signal("mouse::leave", function() hover.target = 0 end)
			state:subscribe(update_color)
			hover:subscribe(update_color)
			return w
		end,
		create_music_widget = function()
			local w = wibox.widget {
				{
					{
						{
							image = images.giraffe,
							forced_width = dpi(100),
							forced_height = dpi(100),
							widget = wibox.widget.imagebox,
							id = "image"
						},
						margins = dpi(8),
						shape = gears.shape.rounded_rect,
						bg = "#fff999",
						layout = coolwidget.margin.background.container
					},
					{
						{
							{
								text = "no song title",
								font = "Sans Bold 12",
								widget = wibox.widget.textbox,
								id = "name",
							},
							{
								text = "no song author",
								font = "Sans 10",
								widget = wibox.widget.textbox,
								id = "author",
							},
							spacing = dpi(5),
							layout = wibox.layout.fixed.vertical
						},
						{
							{
								text = "no player",
								font = "Sans 10",
								widget = wibox.widget.textbox,
								id = "player"
							},
							{
								{
									image = images.skip_prev,
									forced_width = dpi(30),
									forced_height = dpi(30),
									widget = wibox.widget.imagebox,
									buttons = awful.button({}, 1, function() awful.spawn("playerctl prev") end),
									id = "skipback"
								},
								{
									forced_width = dpi(30),
									forced_height = dpi(30),
									widget = require "lib.awesome-widgets.icons.playpause",
									id = "playpause"
								},
								{
									image = images.skip_next,
									forced_width = dpi(30),
									forced_height = dpi(30),
									widget = wibox.widget.imagebox,
									buttons = awful.button({}, 1, function() awful.spawn("playerctl next") end),
									id = "skipforwards"
								},
								layout = wibox.layout.fixed.horizontal
							},
							expand = "neither",
							right = dpi(8),
							layout = coolwidget.margin.align.horizontal
						},
						top = dpi(8),
						bottom = dpi(8),
						expand = "expfirst",
						layout = coolwidget.margin.align.vertical
					},
					layout = wibox.layout.align.horizontal
				},
				{
					forced_height = dpi(24),
					color_bar = color.color {hex="#262930"},
					color_bar_active = color.color {hex="#aaaaaa"},
					widget = slider,
					id = "slider"
				},
				shape = gears.shape.rounded_rect,
				bg = "#1f2228",
				bottom = dpi(12),
				top = dpi(8),
				layout = coolwidget.margin.background.fixed.vertical
			}

			local image = w:get_children_by_id("image")[1]
			local name = w:get_children_by_id("name")[1]
			local author = w:get_children_by_id("author")[1]
			local player = w:get_children_by_id("player")[1]
			local playpause = w:get_children_by_id("playpause")[1]
			local slider = w:get_children_by_id("slider")[1]

			local player_text = ""
			local time_text = ""
			local length = 0

			playpause.buttons = awful.button({}, 1, function()
				playpause:set((playpause:get() + 1) % 2)
				awful.spawn("playerctl play-pause")
			end)

			local function set_playpause_status() awful.spawn.with_line_callback("playerctl status", {stdout=function(out) playpause:set(out == "Paused" and 1 or 0) end}) end
			set_playpause_status()

			playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, new, player_name)
				image.image = gears.surface.load_uncached(album_path)
				name.text = title or "no song title"
				author.text = artist or "no song artist"

				player_text = player_name or "no player"
				player.text = time_text.." ".. player_text

				set_playpause_status()
				w:emit_signal("widget::redraw_needed")
			end)

			playerctl:connect_signal("no_players", function()
				image:set_image(images.giraffe)
				name.text = "no song title"
				author.text = "no song artist"

				player_text = "no player"
				time_text = "0:00 / 0:00"
				player.text = time_text.." ".. player_text

				slider:set(0)
				set_playpause_status()
				w:emit_signal("widget::redraw_needed")
			end)

			playerctl:connect_signal("position", function(_, interval_sec, length_sec)
				length = length_sec --for dragging
				time_text = string.format("%d:%02d / %d:%02d", math.floor(interval_sec / 60), interval_sec % 60, math.floor(length_sec / 60), length_sec % 60)
				player.text = time_text.." ".. player_text

				--if not manually dragging the slider then don't move it
				if not slider:is_doing_mouse_things() then slider:set(interval_sec / length_sec) end
			end)

			slider:connect_signal("slider::ended_mouse_things", function(_, pos)
				awful.spawn(("playerctl position %d"):format(math.floor(pos * length)))
			end)


			return w
		end,

		create_notification_item = function(_, layout)
			--[[	image title 			category appicon
					|    | message
					|____| button button button button button 		]]
			local w
			w = wibox.widget {
				{
					{
						{
							{
								image = images.drag,
								forced_width = dpi(80),
								forced_height = dpi(80),
								widget = wibox.widget.imagebox,
								id = "image"
							},
							halign = "center",
							layout = wibox.container.place
						},
						{
							{
								image = images.drag,
								widget = wibox.widget.imagebox,
								forced_height = dpi(18),
								forced_width = dpi(18),
								id = "category"
							},
							{
								image = images.drag,
								widget = wibox.widget.imagebox,
								forced_height = dpi(18),
								forced_width = dpi(18),
								id = "app_icon"
							},
							spacing = dpi(5),
							valign = "bottom",
							halign = "left",
							layout = coolwidget.place.fixed.horizontal
						},
						layout = wibox.layout.stack
					},
					width = dpi(80),
					height = dpi(80),
					right = dpi(8),
					strategy = "exact",
					shape = gears.shape.rounded_rect,
					bg = "#262930",
					layout = coolwidget.margin.constraint.background.container,
					id = "image_container"
				},
				{
					{
						{
							text = "title",
							widget = wibox.widget.textbox,
							font = "Sans Bold 12",
							id = "title"
						},
						{
							text = "message",
							widget = wibox.widget.textbox,
							font = "Sans 10",
							id = "message",
						},
						{
							spacing = dpi(5),
							widget = wibox.layout.flex.horizontal,
							id = "actions"
						},
						spacing = dpi(5),
						--set to explast if you need to
						layout = coolwidget.align.vertical,
						id = "main_container"
					},
					{
						{
							image = images.close,
							widget = wibox.widget.imagebox,
							forced_height = dpi(24),
							forced_width = dpi(24),
							buttons = awful.button({}, 1, function() layout:remove(w) end),
							id = "close",
						},
						halign = "right",
						valign = "top",
						layout = wibox.container.place

					},
					layout = wibox.layout.stack,
					id = "main"
				},
				bg = "#363a44",
				shape = gears.shape.rounded_rect,
				margins = dpi(8),
				forced_width = dpi(380),
				expand = "explast",
				layout = coolwidget.background.margin.align.horizontal
			}
			local title = w:get_children_by_id("title")[1]
			local message = w:get_children_by_id("message")[1]
			local actions = w:get_children_by_id("actions")[1]
			local app_icon = w:get_children_by_id("app_icon")[1]
			local category = w:get_children_by_id("category")[1]
			local close = w:get_children_by_id("close")[1]
			local image = w:get_children_by_id("image")[1]
			local image_container = w:get_children_by_id("image_container")[1]
			local main = w:get_children_by_id("main")[1]

			local close_trans = color.transition(color.color {hex="#ffffff"}, color.color {hex="#ff6973"}, color.transition.RGB)
			local close_timed = rubato.timed {
				duration = 0.2,
				intro = 0.3,
				prop_intro = true,
				subscribed = function(pos) close:set_image(gears.color.recolor_image(images.close, close_trans(pos).hex)) end
			}
			close:connect_signal("mouse::enter", function() close_timed.target = 1 end)
			close:connect_signal("mouse::leave", function() close_timed.target = 0 end)

			function w:populate(notif)
				--urgency	string		The notification urgency level.
				--font		string?		Notification font.
				--app_name	string		The application name specified by the notification.
				--app_icon	string?		The icon provided in the app_icon field of the DBus notification.
				title.text = notif.title
				message.text = notif.message

				w:set_children { notif.icon and image_container, main }
				image.image = notif.icon

				app_icon.image = get_icon(TAGLIST_ICON_THEME, "128x128/apps/"..notif.app_name..".svg")

				if not notif.category then category.image = nil; category.forced_width = 0
				elseif notif.category:sub(1, 2) == "im" then category.image = get_icon("Papirus-Dark", "symbolic/actions/chat-new-message-symbolic.svg")
				elseif notif.category:sub(1, 5) == "email" then category.image = get_icon("Papirus-Dark", "symbolic/actions/chat-mail-message-new-symbolic.svg")
				elseif notif.category:sub(1, 6) == "device" then category.image = get_icon("Papirus-Dark", "symbolic/devices/drive-harddisk-usb-symbolic.svg")
				elseif notif.category:sub(1, 7) == "network" then category.image = get_icon("Papirus-Dark", "symbolic/status/network-transmit-receive-symbolic.svg")
				elseif notif.category:sub(1, 8) == "presence" then category.image = nil
				elseif notif.category:sub(1, 8) == "transfer" then category.image = get_icon("Papirus-Dark", "symbolic/places/folder-download-symbolic.svg")
				end

				res = {}
				for _,action in pairs(notif.actions or nil) do
					local w2 = wibox.widget {
						{
							text = action.name,
							widget = wibox.widget.textbox,
						},
						shape = gears.shape.rounded_rect,
						bg = "#262930",
						margins = dpi(8),
						buttons = awful.button({}, 1, function() action:invoke(notif); if not notif.resident then layout:remove(w) end end),
						layout = coolwidget.background.margin.container
					}
					local color_trans = color.transition(color.color {hex="#262930"}, color.color {hex="#262930"} + "0.03l")
					local color_timed = rubato.timed {
						duration = 0.15,
						intro = 0.3,
						prop_intro = true,
						subscribed = function(pos) w2.bg = color_trans(pos).hex; w2:emit_signal("widget::redraw_needed") end,
					}
					w2:connect_signal("mouse::enter", function() color_timed.target = 1 end)
					w2:connect_signal("mouse::leave", function() color_timed.target = 0 end)

					table.insert(res, w2)
				end
				actions:set_children(res)

				--reet close timed
				close_timed.pos = 0
				close_timed.target = 0
				close_timed:fire(0)
				w:emit_signal("widget::redraw_needed")
			end

			return w
		end,
		create_notification_center = function(widgets)
			local layout
			layout = recycler(function() return widgets:create_notification_item(layout) end, {
				padx = 0,
				pady = 8,
				spacing = 8,
				orientation = recycler.UP
			})
			--local layout = recycler(function() local w = wibox.widget.textbox(); function w:populate(notif) w.text = notif.title end; return w end)

			naughty.connect_signal("added", function(notif) layout:add(notif) end)

			return layout
			--return wibox.widget.textbox("hi")
			--return require "not_center"
		end,
	},
	tallcontainer_timed = nil,
	create_info_widgets = function(ui)
		local w = wibox.widget {
			{
				{
					{
						ui.widgets.create_device_info_widget(get_icon("Papirus", "128x128/devices/battery.svg"), "battery"),
						ui.widgets.create_device_info_widget(get_icon("Papirus", "128x128/devices/cpu.svg"), "cpu"),
						ui.widgets.create_device_info_widget(get_icon("Papirus", "128x128/devices/device_mem.svg"), "ram"),
						ui.widgets.create_device_info_widget(get_icon("Papirus", "128x128/devices/drive-multidisk.svg"), "disk"),
						ui.widgets.create_device_info_widget(get_icon("Papirus", "symbolic/status/sensors-temperature-symbolic.svg"), "temp"),
						strategy = "exact",
						height = dpi(80),
						widget = coolwidget.constraint.fixed.horizontal
					},
					{
						text = os.date("%a %b\n")..tonumber(os.date("%m")).."/"..tonumber(os.date("%d"))..os.date("/%Y\n%p"),
						font = "Libre Sans 13",
						align = "right",
						forced_height = 0,
						widget = wibox.widget.textbox,
						--this has to have an ID because I have to fade it out becuase
						--for whatever reason it doesn't want to ellipsize for the life
						--of it. Similarly, forced_height isn't constraining it exactly
						--so it's just set to zero.
						id = "date"
					},
					strategy = "exact",
					expand = "neither",
					id = "container",
					widget = coolwidget.constraint.align.horizontal,
				},
				{
					{
						format = "%I\n%M\n%S",
						font = "Libre Sans 13",
						align = "right",
						refresh = 1,
						widget = wibox.widget.textclock
					},
					left = dpi(11),
					--setting top and bottom here sets the height because, as
					--per usual, forced_height and forced_width do nothing
					top = dpi(16),
					bottom = dpi(16),
					widget = wibox.container.margin
				},
				layout = wibox.layout.fixed.horizontal
			},
			{
				{
					ui.widgets.create_device_setting_slider(icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg", "volume"),
					ui.widgets.create_device_setting_slider(icon_directories["Papirus-Dark"].."/symbolic/status/display-brightness-high-symbolic.svg", "brightness"),
					{
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/network-wireless-signal-excellent-symbolic.svg", function() end),
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg", function() end),
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/night-light-symbolic.svg", function() end),
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/16x16/actions/games-config-theme.svg", function() end),
						spacing = dpi(10),
						top = dpi(4),
						widget = coolwidget.margin.flex.horizontal
					},
					{
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/bluetooth-active-symbolic.svg", function() end),
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/16x16/devices/display.svg", function() end),
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/radio-checked-symbolic.svg", function() end),
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/16x16/devices/camera.svg", function() end),
						spacing = dpi(10),
						top = dpi(4),
						widget = coolwidget.margin.flex.horizontal
					},
					layout = wibox.layout.fixed.vertical
				},
				ui.widgets:create_notification_center(),
				ui.widgets:create_music_widget(),
				left = dpi(12),
				right = dpi(12),
				strategy = "exact",
				id = "tallcontainer",
				widget = coolwidget.constraint.margin.align.vertical
			},
			margins = dpi(8),
			bg = "#262930",
			shape = gears.shape.rounded_rect,
			widget = coolwidget.margin.background.align.vertical
		}

		local container = w:get_children_by_id("container")[1]
		local tallcontainer = w:get_children_by_id("tallcontainer")[1]

		ui.sidebar_timed:subscribe(function(pos) container.width = pos * dpi(340) end)
		tallcontainer.height = 0
		ui.tallcontainer_timed = rubato.timed {
			duration = 0.6,
			prop_intro = true,
			intro = 0.4,
			subscribed = function(pos)
				print(pos)
				tallcontainer.height = pos * ui.screen.geometry.height - dpi(120)
				tallcontainer.forced_height = pos * ui.screen.geometry.height - dpi(120)
				w:emit_signal("widget::layout_changed")
			end
		}

		--slider widgets
		local volume = w:get_children_by_id("volume")[1]
		local brightness = w:get_children_by_id("brightness")[1]
		awesome.connect_signal("signal::volume", function(pos) if not volume:is_doing_mouse_things() and pos then volume:set(pos / 100) end end)
		volume:connect_signal("slider::moved", function(_, pos) if volume:is_doing_mouse_things() then awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ "..math.floor(pos * 100).."%") end end)
		awful.spawn.easy_async_with_shell('brightnessctl | grep -Po "[0-9]+%" | sed -n "s/\\([0-9]\\+\\)%/\\1/p"', function(out) brightness:hard_set(out/100) end)
		brightness:connect_signal("slider::moved", function(_, pos) awful.spawn("brightnessctl s "..math.floor(pos * 100).."%") end)

		--progressbars
		local battery = w:get_children_by_id("battery")[1]
		local cpu = w:get_children_by_id("cpu")[1]
		local ram = w:get_children_by_id("ram")[1]
		local disk = w:get_children_by_id("disk")[1]
		local temp = w:get_children_by_id("temp")[1]

		local progressbar_trans = color.transition(color.color {hex="#7cff9b"}, color.color {hex="#ff6973"}, color.transition.HSLR)
		local battery_timed = rubato.timed { duration = 0.1, easing = rubato.easing.zero, subscribed = function(pos) battery.value = 0.22 + 0.77 * pos; battery.color = progressbar_trans(1-pos).hex end }
		local cpu_timed = rubato.timed { duration = 0.1, easing = rubato.easing.zero, subscribed = function(pos) cpu.value = 0.22 + 0.77 * pos; cpu.color = progressbar_trans(pos).hex end }
		local ram_timed = rubato.timed { duration = 0.1, easing = rubato.easing.zero, subscribed = function(pos) ram.value = 0.22 + 0.77 * pos; ram.color = progressbar_trans(pos).hex end }
		local disk_timed = rubato.timed { duration = 0.1, easing = rubato.easing.zero, subscribed = function(pos) disk.value = 0.22 + 0.77 * pos; disk.color = progressbar_trans(pos).hex end }
		local temp_timed = rubato.timed { duration = 0.1, easing = rubato.easing.zero, subscribed = function(pos) temp.value = 0.22 + 0.77 * pos; temp.color = progressbar_trans(pos).hex end }
		awesome.connect_signal("signal::cpu", function(percent) cpu_timed.target = percent / 100 end)
		awesome.connect_signal("signal::ram", function(used, total) ram_timed.target = used / total end)
		awesome.connect_signal("signal::disk", function(used, total) disk_timed.target = used / total end)
		awesome.connect_signal("signal::battery", function(percent) battery_timed.target = percent / 100 end)
		awesome.connect_signal("signal::temp", function(temp) temp_timed.target = (temp-30) / 70 end)

		--date
		local date = w:get_children_by_id("date")[1]
		ui.sidebar_timed:subscribe(function(pos) date.opacity = math.max(0, pos - 0.5) * 2 end)

		return w
	end,

	--UNFINISHED
	sidebar = nil,
	sidebar_timed = nil,
	homepage = nil, --the main screen
	dropdowns = nil, --1 z-index above the screen
	not_info_widgets = nil,
	create_sidebar = function(ui)
		ui.homepage = wibox.layout.manual()
		ui.dropdowns = wibox.layout.manual()
		ui.sidebar_timed = rubato.timed {
			duration = 0.35,
			prop_intro = true,
			intro = 0.4,
			pos = 0,
		}
		ui.not_info_widgets = wibox.widget {
			ui:create_taglist(),
			ui:create_tasklist(),
			layout = wibox.layout.align.horizontal,
		}
		ui.sidebar = awful.popup {
			widget={
				--ui.homepage,
				ui.not_info_widgets,
				ui.dropdowns,
				{
					nil,
					nil,
					ui:create_info_widgets(),
					layout = wibox.layout.align.vertical
				},
				layout = wibox.layout.stack

			},
			bg = "#363a44",
			maximum_height = ui.screen.geometry.height,
			maximum_width = dpi(60),
			ontop = false,
			screen = ui.screen,
		}
		ui.sidebar:struts {left = dpi(60)}
		ui.sidebar_timed:subscribe(function(pos)
			ui.sidebar.width = pos * dpi(340) + dpi(60)
			ui.sidebar:set_maximum_width(ui.sidebar.width)
			ui.sidebar.ontop = pos ~= 0
		end)
	end
}

-- does screen stuff
awful.screen.connect_for_each_screen(function(screen)
	for i=1,9 do awful.tag.add(tostring(i), { layout=awful.layout.suit.tile }) end
	screen.tags[1]:view_only()

	--wallpaper and giraffe
	gears.wallpaper.set("#2e323a")
	awful.popup {
		widget = wibox.widget.imagebox(images.giraffe),
		maximum_height = dpi(400),
		maximum_width = dpi(400),
		bg = "#00000000",
		x = screen.geometry.width - dpi(400),
		y = screen.geometry.height - dpi(400),
		screen = screen
	}

	--create screen
	ui:create(screen)

	--sidebar opening logic
	local sidebar_state = 0
	ui.tallcontainer_timed:subscribe(function(pos, time)
		if ui.not_info_widgets then ui.not_info_widgets.opacity = (1 - pos) end
		if ui.tallcontainer_timed.target == 0 and time == 0.6 and sidebar_state == 0 then ui.sidebar_timed.target = 0 end
	end)
	ui.sidebar_timed:subscribe(function(_, time)
		if ui.sidebar_timed.target == 1 and time == 0.35 then
			if sidebar_state == 2 then ui.tallcontainer_timed.target = 1 end
			if sidebar_state == 0 then ui.sidebar_timed.target = 0 end
		end
	end)
	globalkeys = gears.table.join(globalkeys, awful.key({"Mod4"}, "Tab", function()
		sidebar_state = (sidebar_state + 1) % 3
		if sidebar_state == 1 then ui.sidebar_timed.target = 1 end
		if sidebar_state == 2 and not ui.sidebar_timed.running then ui.tallcontainer_timed.target = 1 end
		if sidebar_state == 0 then ui.tallcontainer_timed.target = 0 end
	end))
end)

root.keys(globalkeys)
