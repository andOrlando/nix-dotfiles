-- allow for storing preset colors
-- allow for good hsl editing
-- open up buffer
-- write to and read from colorscheme file
--
-- +------------------------------+
-- | TSComment TSWarning TSNote > |
-- | #hexcol||||||||||||||||||||| |
-- |                              |
-- | fg bg sp                     |
-- | Independant (add color?)     |
-- | R 015         H 270          |
-- | G 128         S 0.21         |
-- | B 223         L 0.58         |
-- | 16c 0         256c 38        |
-- |                              |
-- | You are editing a color!     |
-- | Press `y` if this is okay    |
-- |                              |
-- | Links to:                    |
-- | + Warning                    |
-- |                              |
-- | Gui                          |
-- | + Bold                       |
-- | + Italic                     |
-- | + Underline                  |
-- | + Inverse                    |
-- | + Standout                   |
-- | + Undercurl                  |
-- | + Strikethrough              |
-- |                              |
-- | + Cleared                    |
-- |                              |
-- |                              |
--
-- allow both link and values, allow to delete values, allow to clear
-- syntax sync fromstart
-- nvim_buf_add_highlight()

-- start/stop when user calls ToggleColorThing
-- open/close when user calls OpenColorThing

package.path = package.path..";/etc/nixos/bennett/nvim/colorthing/?.lua"

local ui = require "ui"
local utils = require "utils"

-- Set up global function for cursor movement
_G.colorthing_cursor_moved = ui:cursor_moved()

vim.cmd "command ColorthingStart call v:lua.colorthing_start()"

function _G.colorthing_start()
	--create buffer
	ui.bufnr = utils:create_buffer(ui)

	--set up autocommand for movement
	vim.cmd "au! CursorMoved * call v:lua.colorthing_cursor_moved()"

	--open highlight file?
end

function _G.colorthing_stop()
	--stop autocommand
	--destroy buffer
	--close all windows
end

function _G.colorthing_open()
	--open window
end

function _G.colorthing_close()
	--close window
end

