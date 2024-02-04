--big imports
local wibox = require "wibox"
local awful = require "awful"
local gears = require "gears"
local naughty = require"naughty"
local dpi = require "beautiful.xresources".apply_dpi
local cairo = require "lgi".cairo

--./ stuff
local images = require "images"
local iconutils = require "iconutils"

--lib stuff
local color = require "lib.color"
local rubato = require "lib.rubato"
local coolwidget = require "lib.awesome-widgets".coolwidget
local recycler = require "lib.awesome-widgets".recycler
local slider = require "lib.awesome-widgets".slider
-- local playerctl = require "lib.bling.signal.playerctl".lib()
local bluetooth = require "lib.bluetooth"
--local wifi = require "lib.network"

--returning table
local ui = {}

--vars used everywhere
local screen
local sidebar_timed
ui.sidebar_state = 0

--useful table function
function table.index(table, element)
	for k,v in pairs(table) do if element == v then return k end end
	return false
end
function table.tostring(tbl) print(tbl); for k,v in pairs(tbl) do print(k, v) end end

--tasklist stuff
local tasklist_dropdown
local function create_tasklist_dropdown_item(text, image, func)
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
end
local function create_tasklist_dropdown()
	local layout = wibox.layout.manual()

	local minimize = create_tasklist_dropdown_item("Minimize", images.minimize, function() tasklist_dropdown.client.minimized = not tasklist_dropdown.client.minimized end)
	local close = create_tasklist_dropdown_item("Close", images.close, function() tasklist_dropdown.client:kill(); tasklist_dropdown:unpopup() end)
	local fclose = create_tasklist_dropdown_item("Force Close", images.fclose, function() awesome.kill(tasklist_dropdown.client.pid, 9); tasklist_dropdown:unpopup() end)

	minimize.shape = function(cr, width, height) return gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false) end
	fclose.shape = function(cr, width, height) return gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true) end

	tasklist_dropdown = wibox.widget {
		{
			minimize,
			close,
			fclose,
			layout = wibox.layout.fixed.vertical
		},
		bg = (color.color{hex="#444956"} + "0.03l").hex,
		shape = gears.shape.rounded_rect,
		layout = wibox.container.background,
		opacity = 0
	}
	layout:add_at(tasklist_dropdown, {x=-dpi(160),y=0})

	local popup_timed = rubato.timed {
		duration = 0.225,
		subscribed = function(pos, time)
			tasklist_dropdown.opacity = pos
			--tasklist_dropdown:emit_signal("widget::redraw_needed")

			-- only hide away when opacity is zero
			if pos == 0 and time == 0.225 then layout:move_widget(tasklist_dropdown, {x=-dpi(160), y=0}) end
		end
	}
	function tasklist_dropdown:popup(client, position)
		self.client = client or self.client
		if position then layout:move_widget(self, {x=dpi(400)-dpi(160)-dpi(6), y=position}) end
		popup_timed.target = 1

		minimize.bg = (color.color{hex="#444956"} + "0.05l").hex
		minimize.item_timer.position = 1
		minimize.item_timer._props.target = 1

	end
	function tasklist_dropdown:unpopup() popup_timed.target = 0 end

	tasklist_dropdown:connect_signal("mouse::enter", function() tasklist_dropdown:popup() end)
	tasklist_dropdown:connect_signal("mouse::leave", function() tasklist_dropdown:unpopup() end)

	return layout
end
local function create_tasklist_item(layout)

	--placeholder textbox for finding text size
	local textsize = wibox.widget {
		font = "Liberation Sans 11", text = "Yy",
		widget = wibox.widget.textbox
	}:get_preferred_size_at_dpi(screen.dpi)

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
	sidebar_timed:subscribe(function(pos)
		if w.opacity == 0 then return end
		w.width = pos * dpi(340) + dpi(40)
	end)

	--animates background and everything that depends on it
	local bg_color = color.color {hex="#444956"}
	local bg_timed = rubato.timed { duration = 0.2, clamp_position = true }
	local drag_timed = rubato.timed { duration = 0.2, clamp_position = true }
	local focus_timed = rubato.timed { duration = 0.2, clamp_position = true }
	function update_colors()
		local focus_pos = math.abs(focus_timed.pos) == math.huge and 0 or focus_timed.pos
		w.bg = (bg_color + ("%fl"):format(focus_pos - bg_timed.pos)).hex
		drag_bg.bg = (bg_color + ("%fl"):format(drag_timed.pos + focus_pos - bg_timed.pos)).hex
		drag_bg:emit_signal("widget::redraw_needed")
	end
	bg_timed:subscribe(update_colors)
	drag_timed:subscribe(update_colors)
	focus_timed:subscribe(update_colors)

	--instantiates or destroys (sends to unused) a widget
	function w:populate(client)
		self.client = client
		text.text = client.name
		bg_timed.pos = client.minimized and 0.12 or 0
		bg_timed.target = bg_timed.pos
		focus_timed.pos = client.active and 0.06 or 0
		focus_timed.target = focus_timed.pos

		if client then icon:set_client(client) end
		client:connect_signal("property::name", function() text.text = client.name end)
		client:connect_signal("property::minimized", function() if client.minimized then bg_timed.target = 0.12 else bg_timed.target = 0 end end)
		client:connect_signal("property::active", function(c, active) if active then focus_timed.target = 0.06 else focus_timed.target = 0 end end)

		w.width = sidebar_timed.pos * dpi(340) + dpi(40)
	end

	local drag_timer = gears.timer {
		timeout = 0.8,
		single_shot = true,
		callback = function() tasklist_dropdown:popup(w.client, layout._private.wdata[w].y) end --TODO: add second item here to fix this
	}
	drag_bg:connect_signal("mouse::enter", function()
		drag_timed.target = 0.06
		drag_timer:start()
	end)
	drag_bg:connect_signal("mouse::leave", function()
		drag_timed.target = 0
		drag_timer:stop()
	end)

	return w
end
local function create_tasklist()
	local last_tag, layout
	layout = recycler(function() return create_tasklist_item(layout) end, {
		pady = 6,
		padx = 1.5,
		spacing = 8,
	})

	client.connect_signal("tagged", function(client)
		if not table.index(screen.selected_tag:clients(), client) then return end
		layout:add(client)
	end)
	client.connect_signal("untagged", function(client)
		if table.index(screen.selected_tag:clients(), client) then return end
		layout:remove(layout:get_by_id(client))
	end)
	screen:connect_signal("tag::history::update", function()
		if screen.selected_tag == last_tag then return end
		layout:set_children(table.unpack(screen.selected_tag:clients()))
		last_tag = screen.selected_tag
	end)

	return layout
end

--taglist stuff
local function create_taglist()
	local ti = {} --inverse taglist
	local layout = wibox.layout.manual()
	layout.forced_width = dpi(14)

	for i, tag in ipairs(screen.tags) do
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
		clamp_position = true,
		subscribed = function(pos) w.bg = pos_hover_trans(pos).hex end
	}
	screen:connect_signal("tag::history::update", function()
		pos_timed.target = ti[screen.selected_tag]
		pos_hover_timed.target = 0
	end)
	w:connect_signal("mouse::enter", function() pos_hover_timed.target = 1 end)
	w:connect_signal("mouse::leave", function() pos_hover_timed.target = 0 end)

	return layout
end

--tallcontainer stuff needed later
local everythingcontainer
local tallcontainer_timed
local notification_center
local small_boi --small notif center

--big boi widget stuff
local big_bluetooth_widget
local bluetooth_timed = rubato.timed {}
local function create_bluetooth_item()
	--[[
	icon name				lock icon for trust
	[un]pair [dis]connec
	]]
	local w = wibox.widget {
		{
			{
				{
					widget = wibox.widget.imagebox,
					forced_width = dpi(12),
					forced_height = dpi(12),
					id = "icon"
				},
				{
					widget = wibox.widget.textbox,
					forced_height = dpi(12),
					id = "name"
				},
				layout = coolwidget.fixed.horizontal
			},
			{
				widget = wibox.widget.imagebox,
				forced_height = dpi(12),
				forced_width = dpi(12),
				id = "trust"
			},
			expand = "neither",
			layout = coolwidget.align.horizontal
		},
		{
			{
				{
					widget = wibox.widget.textbox,
					id = "pair"
				},
				forced_height = dpi(16),
				layout = coolwidget.background.constraint.place.container,
				id = "pairbg"
			},
			{
				{
					widget = wibox.widget.textbox,
					id = "connect"
				},
				forced_height = dpi(16),
				layout = coolwidget.background.constraint.place.container,
				id = "connectbg"
			},
			spacing = 8,
			layout = wibox.layout.fixed.horizontal
		},
		forced_height = dpi(60),
		shape = gears.shape.rounded_rect,
		bg = "#000000",
		margins = dpi(8),
		forced_width = dpi(368),
		layout = coolwidget.background.margin.fixed.vertical
	}


	local name = w:get_children_by_id("name")[1]
	local icon = w:get_children_by_id("icon")[1]
	local trust = w:get_children_by_id("trust")[1]
	local pair = w:get_children_by_id("pair")[1]
	local pairbg= w:get_children_by_id("pairbg")[1]
	local connect = w:get_children_by_id("connect")[1]
	local connectbg = w:get_children_by_id("connectbg")[1]

	function w:populate(device)
		name.text = device.Name
		--print(device.Icon) --TODO: actually get correct icon location
		icon.image = iconutils.get_icon("Papirus-Dark", "128x128/devices/"..device.Icon..".svg")
		trust.image = device.Trusted and images.lock or images.giraffe

		pair.text = device.Paired and "Unpair" or "Pair"
		connect.text = device.Connected and "Disconnect" or "Connect"

		pairbg.buttons = {awful.button({}, 1, function() if device.Paired then device:CancelPairingAsync() else device:Pair() end end)}
		connectbg.buttons = {awful.button({}, 1, function() if device.Connected then device:DisconnectAsync() else device:ConnectAsync() end end)}

		--[[
		device:Set("org.bluez.Device1", "Trusted", lgi.GLib.Variant("b", not is_trusted))
		device.Trusted = {signature = "b", value = not is_trusted}
		]]
	end

	return w
end
local function create_big_bluetooth_widget()
	local bt_recycler = recycler(create_bluetooth_item, {
		--props go here
		debug = true
	})

	--prevent duplicates and add bluetooth thingy by id
	bluetooth:connect_signal("new_device", function(_, device, path) --[[print("device added")]] if not bt_recycler:get_by_id(path) then bt_recycler:add(device, {id=path}) end end)

	bluetooth:connect_signal("device_updated", function(_, device, path) --[[print("device updated")]] bt_recycler:get_by_id(path):populate(device) end)
	bluetooth:connect_signal("device_removed", function(_, device, path) --[[print("device removed")]] bt_recycler:remove_by_id(path) end)

	bluetooth:connect_signal("state", function(_, ison) --[[print(ison)]] end)

	big_bluetooth_widget = wibox.widget {
		{
			{
				text = "Bluetooth",
				widget = wibox.widget.textbox
			},
			nil,
			{
				text = "close",
				buttons = awful.button({}, 1, function() end),
				widget = wibox.widget.textbox,
				id = "close"
			},
			layout = wibox.layout.align.horizontal,
		},
		bt_recycler,
		layout = wibox.layout.align.vertical
	}

	bluetooth_timed:subscribe(function(pos) big_bluetooth_widget.opacity = pos end)
	local close_button = big_bluetooth_widget:get_children_by_id("close")[1]
	close_button.add_button(awful.button({}, 1, function() bluetooth_timed.target = 0 end))

	return big_bluetooth_widget
end
local function create_big_wifi_widget() end
local function create_big_audio_widget() end

--actual tallcontainer code
local function create_device_info_widget(icon, id)
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
end
local function create_device_setting_slider(icon_path, id)
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
end
local function create_toggle_button(icon, id)
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
		--buttons = awful.button({}, 1, function() state.target = (state.target + 1) % 2; func(state.target) end),
		forced_height = dpi(60),
		bg = (color.color {hex="#363a44"} - "0.1l").hex,
		shape = gears.shape.rounded_rect,
		widget = wibox.container.background,
		id = id
	}
	local trans = color.transition(color.color {hex="#1f2228"}, color.color {hex="#489568"})
	local hover = rubato.timed {duration=0.2, clamp_position=true}
	function update_color() w.bg = (trans(w.state.pos) + ("%fl"):format(hover.pos * (w.state.pos + 1) / 2 * 3)).hex; w:emit_signal("widget::redraw_needed") end

	--let me set state
	w.state = rubato.timed {duration=0.2, clamp_position=true}

	w:connect_signal("mouse::enter", function() hover.target = 0.01 end)
	w:connect_signal("mouse::leave", function() hover.target = 0 end)
	w.state:subscribe(update_color)
	hover:subscribe(update_color)
	return w
end
local function create_music_widget()
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
							buttons = awful.button({}, 1, function() awful.spawn("playerctl previous") end),
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

	--[[playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, new, player_name)
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
	end)]]

	slider:connect_signal("slider::ended_mouse_things", function(_, pos)
		awful.spawn(("playerctl position %d"):format(math.floor(pos * length)))
	end)


	return w
end
local function create_notification_item(smallboi)
	--[[ NOTIFICATION SCHEMATIC
	image title 			category appicon
	|    | message
	|____| button button button button button 	]]

	--okay so here's how small_boi works:
	--I have a second notification center to the right at the bottom of my screen
	--it's like the preliminary notification center--stuff gets thrown there first
	--because you can't actually see when notifications initially happen in the
	--normal notif center. Notifs on bottom right time out. If you close them they
	--should also close in the notif center and vice versa
	--w is widget (obv) args is the argument passed to populate, timer is the death timer
	local w, args, timer
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
					buttons = awful.button({}, 1, function()
						small_boi:remove_by_id(args)
						notification_center:remove_by_id(args)
					end),
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
		--forced_width = small_boi and dpi(280) or dpi(380),
		forced_width = smallboi and dpi(280) or dpi(380),
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
		args = notif --for weird removal stuff
		if timer then timer:stop() end --stop timer if it exists
		title.text = notif.title
		message.text = notif.message

		w:set_children { notif.icon and image_container, main }
		image.image = notif.icon

		app_icon.image = iconutils.get_icon("Papirus-Dark", "128x128/apps/"..notif.app_name..".svg")

		if not notif.category then category.image = nil; category.forced_width = 0
		elseif notif.category:sub(1, 2) == "im" then category.image = iconutils.get_icon("Papirus-Dark", "symbolic/actions/chat-new-message-symbolic.svg")
		elseif notif.category:sub(1, 5) == "email" then category.image = iconutils.get_icon("Papirus-Dark", "symbolic/actions/chat-mail-message-new-symbolic.svg")
		elseif notif.category:sub(1, 6) == "device" then category.image = iconutils.get_icon("Papirus-Dark", "symbolic/devices/drive-harddisk-usb-symbolic.svg")
		elseif notif.category:sub(1, 7) == "network" then category.image = iconutils.get_icon("Papirus-Dark", "symbolic/status/network-transmit-receive-symbolic.svg")
		elseif notif.category:sub(1, 8) == "presence" then category.image = nil
		elseif notif.category:sub(1, 8) == "transfer" then category.image = iconutils.get_icon("Papirus-Dark", "symbolic/places/folder-download-symbolic.svg")
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
				buttons = awful.button({}, 1, function() action:invoke(notif); if not notif.resident then small_boi:remove_by_id(notif); notification_center:remove_by_id(notif) end end),
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

		--death timer for small boi
		if smallboi then
			timer = gears.timer {
				timeout = 5,
				single_shot = true,
				callback = function() small_boi:remove_by_id(notif, {fadedist=dpi(240), scalex=1, scaley=0, fadeamt=0}) end --TODO: add second item here to fix this
			}
			timer:start()
		end

		--reset close timed
		close_timed.pos = 0
		close_timed.target = 0
		close_timed:fire(0)
		w:emit_signal("widget::redraw_needed")
	end

	return w
end
local function create_notification_center()
	notification_center = recycler(create_notification_item, {
		padx = 0,
		pady = 8,
		spacing = 8,
		orientation = recycler.UP
	})
	--local layout = recycler(function() local w = wibox.widget.textbox(); function w:populate(notif) w.text = notif.title end; return w end)

	naughty.connect_signal("added", function(notif) notification_center:add(notif) end)

	return notification_center
	--return wibox.widget.textbox("hi")
	--return require "not_center"
end
local function create_info_widgets()

	--toggle buttons
	--these have to be made beforehand cuz awesome is weird

	local wifi = create_toggle_button(iconutils.icon_directories["Papirus-Dark"].."/symbolic/status/network-wireless-signal-excellent-symbolic.svg")
	local bluetooth = create_toggle_button(iconutils.icon_directories["Papirus-Dark"].."/symbolic/status/bluetooth-active-symbolic.svg")

	local mute = create_toggle_button(iconutils.icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg")
	local bluelight = create_toggle_button(iconutils.icon_directories["Papirus-Dark"].."/symbolic/status/night-light-symbolic.svg")
	local theme = create_toggle_button(iconutils.icon_directories["Papirus-Dark"].."/16x16/actions/games-config-theme.svg")
	local screenoff = create_toggle_button(iconutils.icon_directories["Papirus-Dark"].."/16x16/devices/display.svg")
	local screenrecord = create_toggle_button(iconutils.icon_directories["Papirus-Dark"].."/symbolic/status/radio-checked-symbolic.svg")
	local screenshot = create_toggle_button(iconutils.icon_directories["Papirus-Dark"].."/16x16/devices/camera.svg")

	screenrecord:add_button(awful.button({}, 1, function()
		screenrecord.state.target = (screenrecord.state.target + 1) % 2;
	end))

	screenshot:add_button(awful.button({}, 1, function()
		if screenshot.state.status then return end
		(gears.timer {timeout=1.2, single_shot=true, callback=function() awful.spawn("flameshot gui") end}):start()
		screenshot.state.target = 1;
		ui.sidebar_state = 0
		ui:update_sidebar()
	end))
	screenshot.state:subscribe(function(pos) if pos == 1 then screenshot.state.target = 0 end end)

	screenoff:add_button(awful.button({}, 1, function()
		if screenoff.state.status then return end
		(gears.timer {timeout=0.6, single_shot=true, callback=function() awful.spawn("xset dpms force off") end}):start()
		screenoff.state.target = 1;
	end))
	screenoff.state:subscribe(function(pos) if pos == 1 then screenoff.state.target = 0 end end)


	local w = wibox.widget {
		-- {
			{
				{
					{
						create_device_info_widget(iconutils.get_icon("Papirus", "128x128/devices/battery.svg"), "battery"),
						create_device_info_widget(iconutils.get_icon("Papirus", "128x128/devices/cpu.svg"), "cpu"),
						create_device_info_widget(iconutils.get_icon("Papirus", "128x128/devices/device_mem.svg"), "ram"),
						create_device_info_widget(iconutils.get_icon("Papirus", "128x128/devices/drive-multidisk.svg"), "disk"),
						create_device_info_widget(iconutils.get_icon("Papirus", "symbolic/status/sensors-temperature-symbolic.svg"), "temp"),
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
					create_device_setting_slider(iconutils.icon_directories["Papirus-Dark"].."/symbolic/status/audio-volume-high-symbolic.svg", "volume"),
					create_device_setting_slider(iconutils.icon_directories["Papirus-Dark"].."/symbolic/status/display-brightness-high-symbolic.svg", "brightness"),
					{
						wifi,
						mute,
						bluelight,
						theme,
						spacing = dpi(10),
						top = dpi(4),
						widget = coolwidget.margin.flex.horizontal
					},
					{
						bluetooth,
						screenoff,
						screenrecord,
						screenshot,
						spacing = dpi(10),
						top = dpi(4),
						widget = coolwidget.margin.flex.horizontal
					},
					layout = wibox.layout.fixed.vertical
				},
				create_notification_center(),
				create_music_widget(),
				left = dpi(12),
				right = dpi(12),
				strategy = "exact",
				id = "tallcontainer",
				widget = coolwidget.margin.constraint.align.vertical
			},
			-- widget = wibox.layout.align.vertical,
			-- id = "everythingcontainer"
			--TODO: fix this
		-- },
		-- create_big_bluetooth_widget(),
		margins = dpi(8),
		bg = "#262930",
		shape = gears.shape.rounded_rect,
		widget = coolwidget.margin.background.align.vertical,
	}

	-- everythingcontainer = w:get_children_by_id("everythingcontainer")[1]
	local container = w:get_children_by_id("container")[1]
	local tallcontainer = w:get_children_by_id("tallcontainer")[1]

	-- bluetooth_timed:subscribe(function(pos) everythingcontainer.opacity = 1 - pos end)
	bluetooth:add_button(awful.button({}, 1, function() bluetooth_timed.target = 1 end))

	sidebar_timed:subscribe(function(pos) container.width = pos * dpi(340) end)
	tallcontainer.height = 0
	tallcontainer_timed = rubato.timed {
		duration = 0.6,
		prop_intro = true,
		intro = 0.4,
		subscribed = function(pos)
			tallcontainer.height = pos * screen.geometry.height - dpi(120)
			tallcontainer.forced_height = pos * screen.geometry.height - dpi(120)
			w:emit_signal("widget::layout_changed")
		end
	}

	--slider widgets
	local volume = w:get_children_by_id("volume")[1]
	local brightness = w:get_children_by_id("brightness")[1]
	awesome.connect_signal("signal::volume", function(pos) if not volume:is_doing_mouse_things() and pos then volume:set(pos / 100) end end)
	volume:connect_signal("slider::moved", function(_, pos) if volume:is_doing_mouse_things() then awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ "..math.floor(pos * 100).."%") end end)
	awful.spawn.easy_async_with_shell('brightnessctl | grep -Po "[0-9]+%" | sed -n "s/\\([0-9]\\+\\)%/\\1/p"', function(out) brightness:hard_set(out/100) end)
	brightness:connect_signal("slider::moved", function(_, pos) if brightness.is_doing_mouse_things() then awful.spawn("brightnessctl s "..math.floor(pos * 100).."%") end end)

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
	-- awesome.connect_signal("signal::battery", function(percent) battery_timed.target = percent / 100 end)
	-- awesome.connect_signal("signal::temp", function(value) temp_timed.target = value / 100 end)


	--date
	local date = w:get_children_by_id("date")[1]
	sidebar_timed:subscribe(function(pos) date.opacity = math.max(0, pos - 0.5) * 2 end)

	return w
end

--everything stuff
local function create_mini_notification_center()
	small_boi = recycler(function() return create_notification_item(true) end, {})--{scaley=0, orientation=recycler.UP, debug=true})

	naughty.connect_signal("added", function(notif) small_boi:add(notif) end)

	local popup = awful.popup {
		widget = {
			small_boi,
			layout = wibox.layout.fixed.horizontal
		},
		bg = "#ff000000",
		maximum_height = screen.geometry.height,
		maximum_width = dpi(300),
		minimum_width = dpi(300),
		placement = function(d) return awful.placement.top_left(d, {margins={left=dpi(60)}}) end,
		x = dpi(60),
		ontop = true,
		screen = screen
	}
end
local function create_sidebar()
	sidebar_timed = rubato.timed {
		duration = 0.35,
		prop_intro = true,
		intro = 0.4,
		pos = 0,
	}

	local not_info_widgets = wibox.widget {
		create_taglist(),
		create_tasklist(),
		layout = wibox.layout.align.horizontal,
	}
	sidebar = awful.popup {
		widget={
			not_info_widgets,
			create_tasklist_dropdown(),
			{
				nil,
				nil,
				create_info_widgets(),
				layout = wibox.layout.align.vertical
			},
			layout = wibox.layout.stack

		},
		bg = "#363a44",
		maximum_height = screen.geometry.height,
		maximum_width = dpi(60),
		ontop = false,
		screen = screen,
	}
	sidebar:struts {left = dpi(60)}

	--do sidebar animation on sidebar_timed
	sidebar_timed:subscribe(function(pos)
		sidebar.width = pos * dpi(340) + dpi(60)
		sidebar:set_maximum_width(sidebar.width)
		sidebar.ontop = pos ~= 0
	end)

	--do chain setting stuff
	--I mean it works ig
	tallcontainer_timed:subscribe(function(pos, time)
		if not_info_widgets then not_info_widgets.opacity = (1 - pos) end
		if tallcontainer_timed.target == 0 and time == 0.6 and ui.sidebar_state == 0 then sidebar_timed.target = 0 end
	end)
	sidebar_timed:subscribe(function(_, time)
		if sidebar_timed.target == 1 and time == 0.35 then
			if ui.sidebar_state == 2 then tallcontainer_timed.target = 1 end
			if ui.sidebar_state == 0 then sidebar_timed.target = 0 end
		end
	end)

end
function ui:update_sidebar()
	if self.sidebar_state == 1 then sidebar_timed.target = 1; small_boi:set_children() end
	if self.sidebar_state == 2 and not sidebar_timed.running then tallcontainer_timed.target = 1 end
	if self.sidebar_state == 0 then tallcontainer_timed.target = 0 end
end
function ui:create(s)
	screen = s
	create_mini_notification_center()
	create_sidebar()
end

return ui

