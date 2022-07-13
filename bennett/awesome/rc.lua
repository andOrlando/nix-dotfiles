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

--libraries
local rubato = require "lib.rubato"
local color = require "lib.color"
local slider = require "lib.awesome-widgets.slider"
local coolwidget = require "lib.awesome-widgets.coolwidget"

--load other important stuff
require "awful.hotkeys_popup"
require "awful.hotkeys_popup.keys"
require "awful.autofocus"

require "lib.volume"
require("lib.playerctl").enable { backend = "playerctl_lib" }
require "lib.deviceinfo"
--require "lib.battery"

require "binding.bindings_key"

-- error handling
if awesome.startup_errors then naughty.notify({
	preset = naughty.config.presets.critical,
	title = "Oops, there were errors during startup!",
	text = awesome.startup_errors })
end

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

--if cpu is at like 98% then make rubato instant
awesome.connect_signal("signal::cpu", function(percent) RUBATO_MANAGER.timed.override.instant = percent > 95 end)

-- does some more stuff
awesome.register_xproperty("WM_CLASS", "string") --picom stuff?
awful.spawn.with_shell "if [ ! $(pgrep picom) ]; then picom; fi"
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
local function determine_icon_dir(theme_name)
    local dir = GLib.build_filenamev({GLib.get_home_dir(), ".icons"}).."/"..theme_name
	if gears.filesystem.dir_readable(dir) then return dir end

    dir = GLib.build_filenamev({GLib.get_user_data_dir(), "icons"}).."/"..theme_name
	if gears.filesystem.dir_readable(dir) then return dir end

    for _,v in ipairs(GLib.get_system_data_dirs()) do
        dir = GLib.build_filenamev({v, "icons"}).."/"..theme_name
		if gears.filesystem.dir_readable(dir) then return dir end
    end
end

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
		ui:create_tasklist()
		ui:create_tasklist_dropdown()
		ui:create_taglist()
	end,

	unused = {},
	dropdown = nil,
	request_tasklist_item = function(ui, client)
		local widget
		if #ui.unused == 0 then --if there are no items, create one
			widget = ui:create_tasklist_item()
			ui.homepage:add_at(widget, {x=0,y=0})
		else widget = table.remove(ui.unused, 1) end --otherwise pop from unused
		widget:create(client) --set display values for widget
		return widget
	end,
	create_tasklist_item = function(ui)
		--these values are used for redrawing since both modify position
		local position, inout = 0, 0

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
			if inout == 0 then return end
			w.width = pos * dpi(340) + dpi(40)
		end)

		--redraws the widget
		function w:redraw()
			self.opacity = inout
			ui.homepage:move_widget(self, {x=dpi(15), y=position - (1-inout) * dpi(8)})
			ui.homepage:emit_signal("widget::redraw_needed")
		end

		--rubato timers for position and inout aniamtions respectively
		local position_timed = rubato.timed {
			duration = 0.3,
			intro = 0.3,
			prop_intro = true,
			subscribed = function(pos) position = pos; w:redraw() end
		}
		local inout_timed = rubato.timed {
			duration = 0.1,
			intro = 0.3,
			prop_intro = true,
			subscribed = function(pos) inout = pos; w:redraw() end
		}

		--animates in and out
		--also has to update width when showing
		function w:show()
			inout_timed.target = 1
			self.width = dpi(40) + dpi(340) * ui.sidebar_timed.pos
		end
		function w:hide() inout_timed.target = 0 end

		--instantiates or destroys (sends to unused) a widget
		function w:create(client)
			self.client = client
			table.remove_element(ui.unused, self)

			text.text = client.name
			if client then icon:set_client(client) end
			client:connect_signal("property::name", function() text.text = client.name end)
			client:connect_signal("property::minimized", function() end)

			self:show()
		end
		function w:destroy()
			inout_timed.target = 0
			table.insert(ui.unused, self)
		end

		--either moves with animation or without to target
		function w:move(y) position_timed.target = y end
		function w:set(y)
			position_timed.pos = y
			ui.homepage:move_widget(self, {x=10, y=y})
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

		--mousegrabber for hover thing
		--drag.buttons = awful.button({}, 1, function()
		--	naughty.notify {text="heyo"}
		--end)

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
					ui.sidebar_lock["dropdown"] = false
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

			ui.sidebar_lock["dropdown"] = true
		end
		function ui.dropdown:unpopup()
			popup_timed.target = 0

			ui.sidebar_lock["dropdown"] = false
		end

		ui.dropdown:connect_signal("mouse::enter", function() ui.dropdown:popup() end)
		ui.dropdown:connect_signal("mouse::leave", function() ui.dropdown:unpopup() end)

	end,
	create_tasklist = function(ui)
		local tasklist_indices = {} --a table containing tags as keys and tables as values
		local last_tag = ui.screen.selected_tag --the tag selected before the current one

		--generate tables for tasklist_indices
		for _, tag in pairs(ui.screen.tags) do tasklist_indices[tag] = {} end

		--called when a client is changed or moved (tagged/untagged)
		local function update_tasklist()
			local tag = ui.screen.selected_tag --ease of use
			local clients = tag:clients() --ease of use

			--remove old clients
			for _, widget in pairs(tasklist_indices[tag]) do
				if not table.index(clients, widget.client) then
					widget:destroy()
					table.remove_element(tasklist_indices[tag], widget)
			end end

			--add new clients
			for _,client in pairs(clients) do
				if not table.index(table.map(tasklist_indices[tag],
						function(w) return w.client end), client) then

					local w = ui:request_tasklist_item(client)
					table.insert(tasklist_indices[tag], w)
					w:set(table.index(tasklist_indices[tag], w) * dpi(46) - dpi(42))
			end end

			--update widget position
			for _,widget in pairs(tasklist_indices[tag]) do
				widget:move(table.index(tasklist_indices[tag], widget) * dpi(46) - dpi(42)) end
		end

		--TODO: remove old old widgets (last_last_tag kinda thing)
		local function switch_tag()
			local tag = ui.screen.selected_tag --ease of use
			--hitting <mod-1> <mod-1> triggers the singal
			if tag == last_tag then return end

			for _,w in pairs(tasklist_indices[last_tag]) do w:hide() end
			for _,w in pairs(tasklist_indices[tag]) do w:show() end
			update_tasklist()

			last_tag = tag
		end

		client.connect_signal("tagged", update_tasklist)
		client.connect_signal("untagged", update_tasklist)
		ui.screen:connect_signal("tag::history::update", switch_tag)

	end,

	create_taglist = function(ui)
		local ti = {} --inverse taglist

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
			ui.homepage:add_at(w, {x=dpi(4), y=i*dpi(36)-dpi(30)})

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
		ui.homepage:add_at(w, {x=0, y=0})
		local pos_timed = rubato.timed {
			pos = 1,
			duration = 0.3,
			intro = 0.1,
			subscribed = function(pos) ui.homepage:move_widget(w, {x=dpi(3), y=pos*dpi(36)-dpi(30)}) end
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
		create_device_setting_slider = function(icon_path)
			local device_slider = slider {
				color_bar = color.color {hex="#363a44"},
				color_bar_active = color.color {hex="#444956"} + "0.3l",
				--color_handle = color.color {hex=""},
				lw_margins = 0,
				forced_height = dpi(24),
			}
			local w = {
				{
					nil,
					{
						device_slider,
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
		create_toggle_button = function(icon)
			local w = {
				{
					{
						forced_width = dpi(20),
						forced_height = dpi(20),
						image = icon,
						widget = wibox.widget.imagebox
					},
					widget = wibox.container.place
				},
				forced_height = dpi(60),
				bg = (color.color {hex="#363a44"} - "0.1l").hex,
				shape = gears.shape.rounded_rect,
				widget = wibox.container.background
			}
			return w
		end,
		create_music_widget = function()
			local w = {

			}
			return w
		end,

		unused = {},
		panel = nil,
		request_notification_item = function(self, notification)
			local widget
			if #self.unused == 0 then --if there are no items, create one
				widget = self:create_notification_item()
				self.panel:add_at(widget, {x=0,y=0})
			else widget = table.remove(self.unused, 1) end --otherwise pop from unused
			widget:create(notification)
			return widget
		end,
		create_notification_item = function(widgets)
			--[[	image title 			category appicon
					|    | message
					|____| button button button button button 		]]
			local position, inout = 0, 0

			local w = wibox.widget {
				{
					{
						image = images.drag,
						widget = wibox.widget.imagebox,
						id = "image"
					},
					width = dpi(100),
					height = dpi(100),
					right = dpi(5),
					strategy = "exact",
					shape = gears.shape.rounded_rect,
					layout = coolwidget.margin.constraint.background.container,
					id = "image_container"
				},
				{
					{
						{
							text = "title",
							widget = wibox.widget.textbox,
							id = "title"
						},
						{
							text = "message",
							widget = wibox.widget.textbox,
							id = "message",
						},
						{
							spacing = dpi(5),
							widget = coolwidget.flex.horizontal,
							id = "actions"
						},
						spacing = dpi(5),
						--set to explast if you need to
						layout = coolwidget.align.vertical,
						id = "main_container"
					},
					{
						{
							image = images.drag,
							widget = wibox.widget.imagebox,
							id = "category"
						},
						{
							image = images.drag,
							widget = wibox.widget.imagebox,
							id = "app_icon"
						},
						spacing = dpi(5),
						valign = "left",
						halign = "top",
						layout = coolwidget.place.fixed.horizontal
					},
					layout = wibox.layout.stack,
					id = "main"
				},
				bg = "#000000",
				shape = gears.shape.rounded_rect,
				margins = dpi(4),
				expand = "explast",
				layout = coolwidget.background.margin.align.horizontal
			}
			local title = w:get_children_by_id("title")[1]
			local message = w:get_children_by_id("message")[1]
			local app_icon = w:get_children_by_id("app_icon")[1]
			local category = w:get_children_by_id("category")[1]
			local image = w:get_children_by_id("image")[1]
			local image_container = w:get_children_by_id("image_container")[1]
			local main = w:get_children_by_id("main")[1]

			--rubato timers for position and inout aniamtions respectively
			local position_timed = rubato.timed {
				duration = 0.3,
				intro = 0.3,
				prop_intro = true,
				subscribed = function(pos) position = pos; w:redraw() end
			}
			local inout_timed = rubato.timed {
				duration = 0.1,
				intro = 0.3,
				prop_intro = true,
				subscribed = function(pos) inout = pos; w:redraw() end
			}

			function w:create(notif)
				--urgency	string		The notification urgency level.
				--font		string?		Notification font.
				--app_name	string		The application name specified by the notification.
				--app_icon	string?		The icon provided in the app_icon field of the DBus notification.
				title.text = notif.title
				message.text = notif.message

				w:set_widgets { notif.image and image_container, main }
				image.image = notif.image

				app_icon.image = get_icon(TAGLIST_ICON_THEME, "128x128/apps/"..notif.app_name..".svg")

				if not notif.category then category.image = nil
				elseif category:sub(1, 2) == "im" then category.image = get_icon("Papirus-Dark", "symbolic/actions/chat-new-message-symbolic.svg")
				elseif category:sub(1, 5) == "email" then category.image = get_icon("Papirus-Dark", "symbolic/actions/chat-mail-message-new-symbolic.svg")
				elseif category:sub(1, 6) == "device" then category.image = get_icon("Papirus-Dark", "symbolic/devices/drive-harddisk-usb-symbolic.svg")
				elseif category:sub(1, 7) == "network" then category.image = get_icon("Papirus-Dark", "symbolic/status/network-transmit-receive-symbolic.svg")
				elseif category:sub(1, 8) == "presence" then category.image = nil
				elseif category:sub(1, 8) == "transfer" then category.image = get_icon("Papirus-Dark", "symbolic/places/folder-download-symbolic.svg")
				end

				naughty.notify {text=table:tostringdeep(notif.actions or {})}
			end
			function w:destroy()
				inout_timed.target = 0
				table.insert(widgets.unused, self)
			end
			function w:show()
				inout_timed.target = 1
			end
			function w:hide()
				inout_timed.target = 0
			end
			function w:move() end
			function w:set() end
			function w:redraw() end

			return w
		end,
		create_notification_center = function(self)
			self.panel = wibox.layout.manual

			naughty.connect_signal("added", function(notif)
				
			end)



		end,
	},
	create_info_widgets = function(ui)
		--[[ STRUCTURE
		bat cpu ram disk                      date time
		| | | | | | | |                       |  | |  |
		| | | | | | | |                       |  | |  |
		|_| |_| |_| |_|                       |__| |__|

		volume------------------------------------------
		brightness--------------------------------------

		wifi		mute		bluelight	theme
		|		  | |		  | |		  | |		  |
		|_________| |_________| |_________| |_________|

		bluetooth	screenoff 	record		screenshot
		|		  | |		  | |		  | |		  |
		|_________| |_________| |_________| |_________|



		notifs


		musicicon								title
		|		|								author
		|		|
		|_______| seek---------------- back play pause

		--]]
		local w = wibox.widget {
			{
				{
					{
						ui.widgets.create_device_info_widget(get_icon("Papirus", "128x128/devices/battery.svg"), "battery"),
						ui.widgets.create_device_info_widget(get_icon("Papirus", "128x128/devices/cpu.svg"), "cpu"),
						ui.widgets.create_device_info_widget(get_icon("Papirus", "128x128/devices/device_mem.svg"), "ram"),
						ui.widgets.create_device_info_widget(get_icon("Papirus", "128x128/devices/drive-multidisk.svg"), "disk"),
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
					ui.widgets.create_device_setting_slider(icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg"),
					ui.widgets.create_device_setting_slider(icon_directories["Papirus-Dark"].."/symbolic/status/display-brightness-high-symbolic.svg"),
					{
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg"),
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg"),
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg"),
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg"),
						spacing = dpi(10),
						top = dpi(4),
						widget = coolwidget.margin.flex.horizontal
					},
					{
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg"),
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg"),
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg"),
						ui.widgets.create_toggle_button(icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg"),
						spacing = dpi(10),
						top = dpi(4),
						widget = coolwidget.margin.flex.horizontal
					},
					layout = wibox.layout.fixed.vertical
				},
				wibox.widget.textbox("notifications"),
				{
					wibox.widget.textbox("music"),
					bg = "#ff0000",
					widget = wibox.container.background
				},
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
		naughty.notify {text="hi8"}

		local container = w:get_children_by_id("container")[1]
		local tallcontainer = w:get_children_by_id("tallcontainer")[1]
		local battery = w:get_children_by_id("battery")[1]
		local cpu = w:get_children_by_id("cpu")[1]
		local ram = w:get_children_by_id("ram")[1]
		local disk = w:get_children_by_id("disk")[1]
		local date = w:get_children_by_id("date")[1]

		ui.sidebar_timed:subscribe(function(pos) container.width = pos * dpi(340) end)
		tallcontainer.height = dpi(840)
		--tallcontainer.height = 0

		local progressbar_trans = color.transition(color.color {hex="#7cff9b"}, color.color {hex="#ff6973"}, color.transition.HSLR)
		local battery_timed = rubato.timed {
			duration = 0.1,
			easing = rubato.easing.zero,
			subscribed = function(pos) battery.value = 0.22 + 0.77 * pos; battery.color = progressbar_trans(1-pos).hex end
		}
		local cpu_timed = rubato.timed {
			duration = 0.1,
			easing = rubato.easing.zero,
			subscribed = function(pos) cpu.value = 0.22 + 0.77 * pos; cpu.color = progressbar_trans(pos).hex end
		}
		local ram_timed = rubato.timed {
			duration = 0.1,
			easing = rubato.easing.zero,
			subscribed = function(pos) ram.value = 0.22 + 0.77 * pos; ram.color = progressbar_trans(pos).hex end
		}
		local disk_timed = rubato.timed {
			duration = 0.1,
			easing = rubato.easing.zero,
			subscribed = function(pos) disk.value = 0.22 + 0.77 * pos; disk.color = progressbar_trans(pos).hex end
		}
		awesome.connect_signal("signal::cpu", function(percent) cpu_timed.target = percent / 100 end)
		awesome.connect_signal("signal::ram", function(used, total) ram_timed.target = used / total end)
		awesome.connect_signal("signal::disk", function(used, total) disk_timed.target = used / total end)
		awesome.connect_signal("signal::battery", function(percent) battery_timed.target = percent / 100 end)

		ui.sidebar_timed:subscribe(function(pos) date.opacity = math.max(0, pos - 0.5) * 2 end)

		return w
		--[[return wibox.widget {
			wibox.widget.textbox("hi1"),
			wibox.widget.textbox("hi2"),
			wibox.widget.textbox("hi3"),
			bg = "#000000",
			margins = dpi(8),
			layout = coolwidget.background.margin.align.horizontal
		}]]
	end,

	--UNFINISHED
	sidebar = nil,
	sidebar_timed = nil,
	homepage = nil, --the main screen
	dropdowns = nil, --1 z-index above the screen
	sidebar_lock = {
		is_open = function(self)
			for k,v in pairs(self) do
				if k ~= "is_open" and v then return false end
			end
			return true
		end
	},
	create_sidebar = function(ui)
		ui.homepage = wibox.layout.manual()
		ui.dropdowns = wibox.layout.manual()
		ui.sidebar_timed = rubato.timed {
			duration = 0.35,
			prop_intro = true,
			intro = 0.4,
			pos = 0,
		}
		ui.sidebar = awful.popup {
			widget={
				ui.homepage,
				ui.dropdowns,
				{
					nil,
					nil,
					ui:create_info_widgets(),
					layout = wibox.layout.align.vertical
				},
				buttons = awful.button({}, 1, function() if ui.sidebar_lock:is_open() then ui.sidebar_timed.target=(ui.sidebar_timed.target+1)%2 end end),
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
	for i = 1, 9, 1 do
		awful.tag.add(tostring(i), { layout = awful.layout.suit.tile, })
	end
	gears.wallpaper.set("#2e323a")

	local giraffe = wibox.widget.imagebox(images.giraffe)

	awful.popup {
		widget = giraffe,
		--[[{
			image = images.giraffe,
			widget = wibox.widget.imagebox
		},]]
		maximum_height = dpi(400),
		maximum_width = dpi(400),
		bg = "#00000000",
		x = screen.geometry.width - dpi(400),
		y = screen.geometry.height - dpi(400),
		screen = screen
	}

	screen.tags[1]:view_only()

	ui:create(screen)
end)
