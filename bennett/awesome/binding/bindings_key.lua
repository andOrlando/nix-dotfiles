local gears = require("gears")
local awful = require("awful")
local vars = require("main.variables")
---@diagnostic disable-next-line: unused-local
local mymainmenu = require("deco.menu")
local hotkeys_popup = require("awful.hotkeys_popup")
local naughty = require "naughty"
require("awful.hotkeys_popup.keys")

local mk = vars.modkey

local globalkeys = gears.table.join(
	--- Utils
	awful.key({mk}, "s", hotkeys_popup.show_help,
		{description="Show Help", group="aWM: Utils"}),
	awful.key({}, "Print",
		function() awful.spawn("flameshot gui") end,
		{description="Screenshot", group="aWM: Utils"}),
	awful.key({mk}, "Return", function() awful.spawn(vars.terminal) end,
		{description="Open Terminal", group="aWM: Utils"}),
	awful.key({mk}, "p",
		function() awful.spawn("xset dpms force off") end,
		{description="Screen Off", group="aWM: Utils"}),


	--the old thing was awful.screen.focused().mypromptbox:run()
	awful.key({mk}, "d", function () os.execute("rofi -modi drun,run -show drun") end,
		{description="Open ROFI", group="aWM: Utils"}),

	awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%") end,
		{description="Increase Volume", group="aWM: Utils"}),
	awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%") end,
		{description="Decrease Volume", group="aWM: Utils"}),
	awful.key({}, "XF86AudioMute", function() awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end,
		{description="Mute Volume", group="aWM: Utils"}),
	awful.key({mk}, "Tab", function() end,
		{description="Open Sidebar", group="aWM: Utils"}),

	--- State
	awful.key({mk, "Control"}, "r", awesome.restart,
		{description="Restart Awesome", group="aWM: State"}),
	awful.key({mk, "Shift"}, "e", awesome.quit,
		{description="Quit Awesome", group="aWM: State"}),

	--- Window Management
	awful.key({mk}, "j", function() awful.client.focus.byidx(1) end),
	awful.key({mk}, "k", function() awful.client.focus.byidx(-1) end),
	awful.key({mk, "Shift"}, "j", function() awful.client.swap.byidx(1) end),
	awful.key({mk, "Shift"}, "k", function() awful.client.swap.byidx(-1) end),
	awful.key({mk}, "u", awful.client.urgent.jumpto,
		{description="Jump to Urgent Client", group="aWM: Windows"}),
	awful.key({mk}, "Escape", awful.tag.history.restore,
		{description="Restore last Tag", group="aWM: Windows"}),
	awful.key({mk, "Shift"}, "j", function() awful.client.swap.byidx(1) end,
		{description="Increment Focus", group="aWM: Windows"}),
	awful.key({mk, "Shift"}, "k", function() awful.client.swap.byidx(-1) end,
		{description="Decrement Focus", group="aWM: Windows"}),

	--- Layout
	awful.key({mk}, "h", function() awful.tag.incmwfact(0.05) end,
		{description="Increase master client width", group="aWM: Layout"}),
	awful.key({mk}, "l", function() awful.tag.incmwfact(-0.05) end,
		{description="Decrease master client width", group="aWM: Layout"}),

	-- TODO: Figure out exactly what this actually does
	awful.key({mk, "Shift"}, "h", function() awful.tag.incnmaster(1, nil, true) end,
		{description="Increase number of master clients", group="aWM: Layout"}),
	awful.key({mk, "Shift"}, "l", function() awful.tag.incnmaster(-1, nil, true) end,
		{description="Decrease number of master clients", group="aWM: Layout"}),
	awful.key({mk, "Control"}, "h", function() awful.tag.incncol(1, nil, true) end,
		{description="Increase number of columns", group="aWM: Layout"}),
	awful.key({mk, "Control"}, "l", function() awful.tag.incncol(-1, nil, true) end,
		{description="Decrease number of columns", group="aWM: Layout"}),

	-- Client
	awful.key({mk, "Control"}, "n", function()
			local c = awful.client.restore()
			if c then c:emit_signal("request::activate", "key.unminimize", {raise=true}) end
		end,
		{description="Unminimize all clients", group="aWM: Client"})

	--- Bad ones that are useful to keep around
	--awful.key({mk}, "Left", awful.tag.viewprev)
	--awful.key({mk}, "Right", awful.tag.viewnext)
	--awful.key({mk}, "w", function() mymainmenu:show() end)
	--awful.key({mk, "Control"}, "j", function() awful.screen.focus_relative(1) end)
	--awful.key({mk, "Control"}, "k", function() awful.screen.focus_relative(-1) end)
	--awful.key({mk}, "space", function() awful.layout.inc(1) end)
	--awful.key({mk, "Shift"}, "space" function() awful.layout.inc(-1) end)

)

globalkeys = gears.table.join(globalkeys,
	-- debugging
	awful.key({mk}, "w", function() naughty.notification {title="dog1",
		text="this is some notification txext lorem ipsum dolor sit amet heyoooooo in the jungle the mighty jungle the lion sleeps tonight awimboweh awimboweh",
		category="device",
		icon=require"images".giraffe,
		app_name="discord",
		actions={naughty.action{name="Option 1"}, naughty.action{name="Option 2"}}
	} end)
)

local clientkeys = gears.table.join(
	awful.key({mk}, "f", function(c) c.fullscreen = not c.fullscreen; c:raise() end,
		{description="Toggle focused client fullscreen", group="aWM: Client"}),
	awful.key({mk}, "m", function (c) c.maximized = not c.maximized c:raise() end,
		{description = "Toggle focused client maximized", group="aWM: Client"}),
	awful.key({mk, "Control"}, "m", function(c) c.maximized_vertical = not c.maximized_vertical c:raise() end,
		{description = "Toggle focused client maximized vertically", group="aWM: Client"}),
	awful.key({mk, "Shift"}, "m", function(c) c.maximized_horizontal = not c.maximized_horizontal c:raise() end,
		{description = "Toggle focused client maximized horizontally", group="aWM: Client"}),

	awful.key({mk}, "space", awful.client.floating.toggle,
		{description="Toggle focused cleint floating", group="aWM: Client"}),
	awful.key({mk}, "t", function (c) c.ontop = not c.ontop	end,
		{description = "Toggle pinned", group="aWM: Client"}),

	awful.key({mk, "Shift"}, "q", function(c) c:kill() end,
		{description="Kill focused client", group="aWM: Client"}),
	awful.key({mk}, "n", function(c) c.minimized = true end,
		{description = "Toggle focused client minimize", group="aWM: Client"})

)

-- This presupposes there being 9 tags
for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		awful.key({mk}, "#"..i+9, function() awful.screen.focused().tags[i]:view_only() end,
			{description = "View tag "..i, group="aWM: Tag"}),
		awful.key({mk, "Shift"}, "#"..i+9, function() if client.focus then client.focus:move_to_tag(client.focus.screen.tags[i]) end end,
			{description = "Move focused client to tag "..i, group="aWM: Tag"})
	)
end

local clientbuttons = gears.table.join(
	awful.button({}, 1, function(c) c:emit_signal("request::activate", "mouse_click", {raise = true}) end),
	awful.button({mk}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.move(c)
	end),
	awful.button({mk}, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.resize(c)
	end)
)

return { globalkeys, clientkeys, clientbuttons }
