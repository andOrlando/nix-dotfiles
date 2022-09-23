local GLib = require "lgi".GLib
local cairo = require "lgi".cairo
local gears = require "gears"

M = {}
TAGLIST_ICON_THEME="Papirus"

--searches through likely directories for the theme folder in question
--this works on nixos so it'll probably work on just about anything
M.icon_directories = setmetatable({}, {
	__index=function(self, value)
		if rawget(self, value) then return rawget(self, value) end

		local dir = GLib.build_filenamev({GLib.get_home_dir(), ".icons"}).."/"..value
		if gears.filesystem.dir_readable(dir) then rawset(self, value, dir); return dir end

		dir = GLib.build_filenamev({GLib.get_user_data_dir(), "icons"}).."/"..value
		if gears.filesystem.dir_readable(dir) then rawset(self, value, dir); return dir end

		for _,v in ipairs(GLib.get_system_data_dirs()) do
			dir = GLib.build_filenamev({v, "icons"}).."/"..value
			if gears.filesystem.dir_readable(dir) then rawset(self, value, dir); return dir end
		end
	end
})
function M.get_icon(name, path)
	local icon_path = M.icon_directories[name].."/"..path
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

function M.set_client_icon(client)
	local icon = M.get_icon(TAGLIST_ICON_THEME, "128x128/apps/"..string.lower(client.class)..".svg")
	if icon then client.icon = icon._native end
end

return M
