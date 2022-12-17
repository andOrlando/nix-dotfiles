---@diagnostic disable: undefined-global
print("reloading")
pcall(require, "luarocks.loader")
require "lib.rubato.timed"

--load libraries
local awful = require "awful"
local beautiful = require "beautiful"
local naughty = require "naughty"
local wibox = require "wibox"
local gears = require "gears"
local images = require "images"
local dpi = beautiful.xresources.apply_dpi
naughty.notify {text="reloaded config"}

-- error handling before I load handwritten libraries lol
-- can't trust myself lol
local in_error = false
if awesome.startup_errors then naughty.notify({
	preset = naughty.config.presets.critical,
	title = "Oops, there were errors during startup!",
	text = awesome.startup_errors }) end
awesome.connect_signal("debug::error", function (err)
	-- Make sure we don't go into an endless error loop
	if in_error then return end
	in_error = true

	naughty.notify({ preset = naughty.config.presets.critical,
		title = "Oops, an error happened!",
		text = tostring(err) })
	in_error = false
end)

--libraries
local rubato = require "lib.rubato"
local color = require "lib.color"
local iconutils = require "iconutils"

--load other important stuff
require "awful.hotkeys_popup"
require "awful.hotkeys_popup.keys"
require "awful.autofocus"

require "lib.deviceinfo"
--require "lib.battery"

local globalkeys, clientkeys, clientbuttons = table.unpack(require "binding.bindings_key")

--set dpi
--awful.screen.set_auto_dpi_enabled( true )
-- beautiful.xresources.set_dpi(
-- naughty.notify{text=tostring(dpi(1))}

--if cpu is at like 95% then make rubato instant
awesome.connect_signal("signal::cpu", function(percent) RUBATO_MANAGER.timed.override.instant = percent > 95 end)

-- does some more stuff
awesome.register_xproperty("WM_CLASS", "string") --picom stuff?
awful.spawn.with_shell "sh -c \"if [ ! $(pgrep picom) ]; then picom; fi\""
beautiful.init({
	hotkeys_border_width = 0,
	hotkeys_label_fg = "#000000",
	useless_gap = 15,
	gap_single_client = true,
})

--shut naughty up
naughty.connect_signal("request::display", function() end)

--TODO: make its own file
--do rules
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
	iconutils.set_client_icon(client)
	local editing = false
	client:connect_signal("property::icon", function()
		if editing then return end
		editing = true; iconutils.set_client_icon(client); editing = false
	end)
end)
client.connect_signal("mouse::enter", function(c) c:emit_signal("request::activate", "mouse_enter", {raise = false}) end)

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
	ui = require"ui"
	ui:create(screen)

	globalkeys = gears.table.join(globalkeys, awful.key({"Mod4"}, "Tab", function()
		ui.sidebar_state = (ui.sidebar_state + 1) % 3
		ui:update_sidebar()
	end))

end)

--testing popup
local function test(screen)
	local r_timed = rubato.timed {duration=0.4}
	local g_timed = rubato.timed {duration=0.4}
	local b_timed = rubato.timed {duration=0.4}


	function make_test_button(c)
		local w = wibox.container.background(wibox.widget.textbox(c), c)

		r_timed:subscribe(function() w.bg = "#"..color.utils.rgba_to_hex {math.max(r_timed.pos, 0), math.max(g_timed.pos, 0), math.max(b_timed.pos, 0)} end)
		g_timed:subscribe(function() w.bg = "#"..color.utils.rgba_to_hex {math.max(r_timed.pos, 0), math.max(g_timed.pos, 0), math.max(b_timed.pos, 0)} end)
		b_timed:subscribe(function() w.bg = "#"..color.utils.rgba_to_hex {math.max(r_timed.pos, 0), math.max(g_timed.pos, 0), math.max(b_timed.pos, 0)} end)

		w:connect_signal("mouse::enter", function() r_timed.target, g_timed.target, b_timed.target = color.utils.hex_to_rgba(c) end)
		return w
	end

	---@diagnostic disable-next-line: redefined-local
	local test = awful.popup {
		widget = {
			make_test_button("#ff0000"),
			make_test_button("#00ff00"),
			make_test_button("#0000ff"),
			spacing = dpi(10),
			layout = wibox.layout.fixed.horizontal
		},
		bg = "#000000",
		maximum_height = dpi(300),
		minimum_height = dpi(300),
		maximum_width = dpi(300),
		minimum_width = dpi(300),
		x = 400,
		y = 400,
		ontop = true,
		screen = screen,
		opacity = 0
	}

	globalkeys = gears.table.join(globalkeys, awful.key({"Mod4", "Alt"}, "0", function() test.opacity = (test.opacity + 1) % 2 end))

end
--awful.screen.connect_for_each_screen(test)

root.keys(globalkeys)


