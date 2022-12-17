local gears = require("gears")
local awful = require("awful")
local vars = require("main.variables")
---@diagnostic disable-next-line: unused-local
local mymainmenu = require("deco.menu")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local mk = vars.modkey

globalkeys = gears.table.join(
	--- Utils
	awful.key({mk}, "s", hotkeys_popup.show_help,
		{description="Show Help", group="Utils"}),
	awful.key({}, "Print",
		function() awful.spawn("flameshot gui") end,
		{description="Screenshot", group="Utils"}),
	awful.key({mk}, "Return", function() awful.spawn(vars.terminal) end,
		{description="Open Terminal", group="Utils"}),
	awful.key({mk}, "p",
		function() awful.spawn("xset dpms force off") end,
		{description="Toggle max/min brigtness", group="Utils"}),


	--the old thing was awful.screen.focused().mypromptbox:run()
	awful.key({mk}, "d", function () os.execute("rofi -modi drun,run -show drun") end,
		{description="Open ROFI", group="Utils"}),

	awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%") end,
		{description="Increase Volume", group="Utils"}),
	awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%") end,
		{description="Decrease Volume", group="Utils"}),
	awful.key({}, "XF86AudioMute", function() awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end,
		{description="Mute Volume", group="Utils"}),


	--- State
	awful.key({mk, "Control"}, "r", awesome.restart,
		{description="Restart Awesome", group="State"}),
	awful.key({mk, "Shift"}, "e", awesome.quit,
		{description="Quit Awesome", group="State"}),

	--- Window Management
	awful.key({mk}, "j", function() awful.client.focus.byidx(1) end),
	awful.key({mk}, "k", function() awful.client.focus.byidx(-1) end),
	awful.key({mk, "Shift"}, "j", function() awful.client.swap.byidx(1) end),
	awful.key({mk, "Shift"}, "k", function() awful.client.swap.byidx(-1) end),
	awful.key({mk}, "u", awful.client.urgent.jumpto,
		{description="Jump to Urgent Client", group="Windows"}),
	awful.key({mk}, "Escape", awful.tag.history.restore,
		{description="Restore last Tag", group="Windows"}),
	awful.key({mk, "Shift"}, "j", function() awful.client.swap.byidx(1) end,
		{description="Increment Focus", group="Windows"}),
	awful.key({mk, "Shift"}, "k", function() awful.client.swap.byidx(-1) end,
		{description="Decrement Focus", group="Windows"}),

	--- Layout
	awful.key({mk}, "h", function() awful.tag.incmwfact(0.05) end,
		{description="Increase master client width", group="Layout"}),
	awful.key({mk}, "l", function() awful.tag.incmwfact(-0.05) end,
		{description="Decrease master client width", group="Layout"}),

	-- TODO: Figure out exactly what this actually does
	awful.key({mk, "Shift"}, "h", function() awful.tag.incnmaster(1, nil, true) end,
		{description="Increase number of master clients", group="Layout"}),
	awful.key({mk, "Shift"}, "l", function() awful.tag.incnmaster(-1, nil, true) end,
		{description="Decrease number of master clients", group="Layout"}),
	awful.key({mk, "Control"}, "h", function() awful.tag.incncol(1, nil, true) end,
		{description="Increase number of columns", group="Layout"}),
	awful.key({mk, "Control"}, "l", function() awful.tag.incncol(-1, nil, true) end,
		{description="Decrease number of columns", group="Layout"}),

	-- Client
	awful.key({mk, "Control"}, "n", function()
			local c = awful.client.restore()
			if c then c:emit_signal("request::activate", "key.unminimize", {raise=true}) end
		end,
		{description="Unminimize all clients", group="Client"})

	--- Bad ones that are useful to keep around
	--awful.key({mk}, "Left", awful.tag.viewprev)
	--awful.key({mk}, "Right", awful.tag.viewnext)
	--awful.key({mk}, "w", function() mymainmenu:show() end)
	--awful.key({mk, "Control"}, "j", function() awful.screen.focus_relative(1) end)
	--awful.key({mk, "Control"}, "k", function() awful.screen.focus_relative(-1) end)
	--awful.key({mk}, "Tab",
	--	function()
	--		awful.client.focus.history.previous()
	--		if client.focus then client.focus:raise() end
	--	end end,) --Goes back one client
	--awful.key({mk}, "space", function() awful.layout.inc(1) end)
	--awful.key({mk, "Shift"}, "space" function() awful.layout.inc(-1) end)

)

--[[local rubato = require 'lib.rubato'
local scratchpad = require 'lib.bling.module.scratchpad'
local chat_anim = {
    y = rubato.timed {
        pos = 1090,
        rate = 120,
        easing = rubato.quadratic,
        intro = 0.1,
        duration = 0.3,
        awestore_compat = true
    }
}

local chat_scratch = scratchpad:new{
    command = 'kitty --class="chat"',
    -- command = "Discord",
    rule = {
        class = "chat"
        --    class = "discord"
    },
    sticky = false,
    autoclose = false,
    floating = true,
    geometry = {x = 460, y = 90, height = 900, width = 1000},
    reapply = true,
    rubato = chat_anim
}
]]

--awesome.connect_signal("scratch::chat", function() chat_scratch:toggle() end)

clientkeys = gears.table.join(
	awful.key({mk}, "f", function(c) c.fullscreen = not c.fullscreen; c:raise() end,
		{description="Toggle focused client fullscreen", group="Client"}),

	awful.key({mk, "Shift"}, "q", function(c) c:kill() end,
		{description="Kill focused client", group="Client"}),

	awful.key({mk}, "space", awful.client.floating.toggle,
		{description="Toggle focused cleint floating", group="Client"})
)

globalkeys = gears.table.join(globalkeys,

	awful.key({ vars.modkey }, "x",
			  function ()
				  awful.prompt.run {
					prompt	   = "Run Lua code: ",
					textbox	  = awful.screen.focused().mypromptbox.widget,
					exe_callback = awful.util.eval,
					history_path = awful.util.get_cache_dir() .. "/history_eval"
		}
			  end,
			  {description = "lua execute prompt", group = "awesome"}),
	-- Menubar
	--awful.key({ vars.modkey }, "p", function() menubar.show() end,
	--		  {description = "show the menubar", group = "launcher"}),

	awful.key({mk, "Shift"}, "s", function() chat_scratch:toggle() end,
		{description = "do scratchpad", group="debug"})
)

clientkeys = gears.table.join(clientkeys,


	awful.key({ vars.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
			  {description = "move to master", group = "client"}),
	awful.key({ vars.modkey, }, "o",	  function (c) c:move_to_screen()			   end,
			  {description = "move to screen", group = "client"}),
	awful.key({ vars.modkey, }, "t",	  function (c) c.ontop = not c.ontop			end,
			  {description = "toggle keep on top", group = "client"}),
	awful.key({ vars.modkey, }, "n",
		function (c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end ,
		{description = "minimize", group = "client"}),
	awful.key({ vars.modkey, }, "m",
		function (c)
			c.maximized = not c.maximized
			c:raise()
		end ,
		{description = "(un)maximize", group = "client"}),
	awful.key({ vars.modkey, "Control" }, "m",
		function (c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end ,
		{description = "(un)maximize vertically", group = "client"}),
	awful.key({ vars.modkey, "Shift"   }, "m",
		function (c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end ,
		{description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		-- View tag only.
		awful.key({ vars.modkey }, "#" .. i + 9,
				  function ()
						local screen = awful.screen.focused()
						local tag = screen.tags[i]
						if tag then
						   tag:view_only()
						end
				  end,
				  {description = "view tag #"..i, group = "tag"}),
		-- Toggle tag display.
		awful.key({ vars.modkey, "Control" }, "#" .. i + 9,
				  function ()
					  local screen = awful.screen.focused()
					  local tag = screen.tags[i]
					  if tag then
						 awful.tag.viewtoggle(tag)
					  end
				  end,
				  {description = "toggle tag #" .. i, group = "tag"}),
		-- Move client to tag.
		awful.key({ vars.modkey, "Shift" }, "#" .. i + 9,
				  function ()
					  if client.focus then
						  local tag = client.focus.screen.tags[i]
						  if tag then
							  client.focus:move_to_tag(tag)
						  end
					 end
				  end,
				  {description = "move focused client to tag #"..i, group = "tag"}),
		-- Toggle tag on focused client.
		awful.key({ vars.modkey, "Control", "Shift" }, "#" .. i + 9,
				  function ()
					  if client.focus then
						  local tag = client.focus.screen.tags[i]
						  if tag then
							  client.focus:toggle_tag(tag)
						  end
					  end
				  end,
				  {description = "toggle focused client on tag #" .. i, group = "tag"})
	)
end

clientbuttons = gears.table.join(
	awful.button({ }, 1, function (c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
	end),
	awful.button({ vars.modkey }, 1, function (c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.move(c)
	end),
	awful.button({ vars.modkey }, 3, function (c)
		c:emit_signal("request::activate", "mouse_click", {raise = true})
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}
