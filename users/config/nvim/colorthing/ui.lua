
local fn = vim.fn
local api = vim.api
local utils = require "utils"

local HIGHLIGHT = 0

local ui = {}

--- table containing new states of all edited colors
ui.edits = {}

--- table containing all custom colors for quick access
-- this does not contain new colors as to know which have been edited. each
-- color must have a unique name and will be stored in the table with said
-- name
ui.colors = {}

--- Table containing colors it's currently editing
ui.editing = {}

--[[--------------------------
        GENERAL LOGIC
--------------------------]]--
local vars = {
	state = HIGHLIGHT,
	hl = 0,
	bufnr = 0,
}

--- Redraws screen
function ui:redraw()
	if vars.state == HIGHLIGHT then self:hlRedraw()
	end
end

--- How to redraw when the cursor moves
-- only redraw highlight screen and even then only redraw if the highlight
-- group changes.
function ui:cursor_moved()
	--check if color changes and if so, update
	local hl = utils:get_treesitter_hl()
	if utils:compare_tables(ui.editing, hl) then return end
	ui.editing = hl


	if vars.state == HIGHLIGHT then self:hlRedraw() end
end

--- Adds an edit to table based off values
-- @param hlID The hlID of the highlight group to be edited
-- @param args The edits to make to the color. The allowable fields are shown
-- in utils:get_values and also the `color` field.
function ui:make_edit(hlID, args)
	for k, v in pairs(args) do ui.edits[hlID][k] = v end
end

--- Rerouts keybind events
function ui:keybind_event(keybind)
	if vars.screen == HIGHLIGHT then ui.hlkeys[keybind]()
	end
end

--- Redraws the scren from a specified point
function ui:draw(table, linenr)
	--this will keep track of the current line
	--line numbers start from 1
	linenr = linenr or 1

	for _, line in pairs(table) do
		--this will keep track of the string given to setbufline
		local line_text = ""

		--this will keep track of all the areas that need to be highlighted
		--1: highlight name 2: startx 3: endx 4: y
		--line numbers start from 1
		local highlights = {}

		for _, s in pairs(line) do
			local fmt = {}
			--unpacks s if it's not a string into its string and its formatting
			if type(s) ~= "string" then fmt = s[2]; s = s[1] end

			--gets the highlight from fmt and adds it to the highlight table
			--TODO: make sure it works
			local hi = utils:get_hi_from_fmt(fmt)
			highlights.insert({hi, #line_text, #line_text + #s})

			--finally, adds the text to be written
			line_text = line_text .. s
		end

		--Writes line to buffer
		fn.setbufline(ui.bufnr, linenr, line_text)

		--highlights line
		for _, hi in pairs(highlights) do
			api.nvim_buf_add_highlight(ui.bufnr, -1, hi[1], hi[2], hi[3], linenr)
		end

		--increments line number
		linenr = linenr + 1
	end
end

--[[--------------------------
      HIGHLIGHT SCREEN

is called when it first opens
gotta be able to completely redraw from scratch
gotta be able to draw certain parts
--------------------------]]--

--- Constants for highlight screen
local FG = 0
--local BG = 1
--local SP = 2

--- Variables to keep track of for the highlight screen
-- @field coloredit Which color value is currently being edited
-- @field row The currently selected row
-- @field col The currently selected column
ui.hlvars = {
	coloredit = FG,
	row = 0, col = 0,
	editing_index = 1,
}

--- Loads the current color
function ui:hlRedraw()
	local draw = {}

	--create tabthing as header
	--TODO: do highlights
	local header = ""
	for _, v in pairs(ui.editing) do header = header..v.." " end
	table.insert(draw, header)

	--create highlighty thing
	--get the correct bg and fg
	local color = ui.editing[ui.hlvars.editing_index]
	table.insert(draw, {"fg: "..color.guifg.." ", utils.get_hi_from_fmt {guibg=color.guifg}})
	table.insert(draw, {"bg: "..color.guibg.." ", utils.get_hi_from_fmt {guibg=color.guibg}})

	ui:draw()
end

ui.hlkeys = {
	enter = function() end,
	up = function() end,
	down = function() end,
	q = function() end,
	s_enter = function() end,
	s_up = function() end,
	s_down = function() end
}

--[[--------------------------
         COLOR SCREEN
--------------------------]]--

-- Will be used to save and retrieve colors
-- Will look through file to find both named and unnamed colors


--[[--------------------------
         SAVE SCREEN
--------------------------]]--

-- Will effectively be a glorified edit screen, may not even be strictly necessary


--[[--------------------------
         EDIT SCREEN
--------------------------]]--

-- Will be used for all editable values, will somehow have to communicate back
-- the result to any screen at any point

--[[--------------------------
        LINKS SCREEN
--------------------------]]--

-- Search thorugh all available highlights for links
-- Cache all available highlights so it doesn't load it each time

--[[--------------------------
         HELP SCREEN
--------------------------]]--

-- shows keybinds


return ui
