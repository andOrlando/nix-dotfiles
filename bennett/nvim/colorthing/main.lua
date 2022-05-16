local fn = vim.fn
local api = vim.api

local highlighter = require "vim.treesitter.highlighter"
local ts_utils = require "nvim-treesitter.ts_utils"

local utils = {}

--[[----------------------------
--     HIGHLIGHTING UTILS     --
----------------------------]]--

--- Gets treesitter highlighting at the cursor
-- Effectively the same as synstack but a little less accurate for some reason.
-- I don't understand treesitter and this was 99% just copied from treesitter
-- playground.
-- @returns a table containing the hlIDs of the highlights under the cursor
function utils:get_treesitter_hl()
	-- get necessary info
	local buf = vim.api.nvim_get_current_buf()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	row = row - 1

	-- get the highlighter for the current buffer
	local self = highlighter.active[buf]
	if not self then return {} end

	local matches = {}

	-- for each treesitter available do the following
	self.tree:for_each_tree(function(tstree, tree)
		if not tstree then return end

		local root = tstree:root()
		local root_start_row, _, root_end_row, _ = root:range()

		-- Only worry about trees within the line range
		if root_start_row > row or root_end_row < row then return end

		local query = self:get_query(tree:lang())
		if not query:query() then return end

		local iter = query:query():iter_captures(root, self.bufnr, row, row + 1)

		for capture, node, _ in iter do
			local hl = query.hl_cache[capture]

			if hl and ts_utils.is_in_node_range(node, row, col) then
				local c = query._query.captures[capture] -- name of the capture in the query
				if c ~= nil then

					-- check if there's a general hl available
					local general_hl = query:_get_hl_from_capture(capture)

					-- if so, we're going to return that instead
					if general_hl ~= hl then hl = fn.hlID(general_hl) end

					table.insert(matches, hl)
				end
			end
		end
	end, true)
	return matches
end

--- Gets information about a highlight group
-- Takes data both form synIDattr and edits
-- @returns A table with highlight information
function utils:get_values(hlID, edits, colors)
	local result = {
		guifg = fn.synIDattr(hlID, "#fg", "gui"),
		guibg = fn.synIDattr(hlID, "#bg", "gui"),
		guisp = fn.synIDattr(hlID, "#sp", "gui"),
		ctermfg = fn.synIDattr(hlID, "#fg", "cterm"),
		ctermbg = fn.synIDattr(hlID, "#bg", "cterm"),
		ctermsp = fn.synIDattr(hlID, "#sp", "cterm"),
		bold = fn.synIDattr(hlID, "bold", "gui"),
		italic = fn.synIDattr(hlID, "italic", "gui"),
		inverse = fn.synIDattr(hlID, "inverse", "gui"),
		standout = fn.synIDattr(hlID, "standout", "gui"),
		underline = fn.synIDattr(hlID, "underline", "gui"),
		undercurl = fn.synIDattr(hlID, "undercurl", "gui"),
		strikethrough = fn.synIDattr(hlID, "strikethrough", "gui"),
	}

	--check if it's already in colors
	for c, table in pairs(colors) do if table.uses[c] ~= nil then result.color = c end end

	--override values in edits, can also override color
	for k, v in pairs(edits) do result[k] = v end

	return result
end

--- Get the link chain of a highlight recursively
-- @param name The name of the initial highlight group
-- @return A table containing each highlight in reverse order
function utils:get_links_recursive(last_name, result)
	result = result or {}
	local output = api.nvim_exec("highlight "..last_name, true)
	local name = fn.substitute(
		fn.substitute(output, "\\n", " ", ""),
		".*Links to \\(\\S*\\) .*^", "\\1", "")

	-- if it doesn't give us anything, return
	if string.find(name, " ") ~= nil then return result end

	-- if it's cyclic, end
	for _, hlID in pairs(result) do if fn.hlID(name) == hlID then return end end

	-- otherwise add it to result and recurse
	table.insert(result, name)
	return self:get_links_recursive(name, result)
end

local colors = {}
local iter = 0
--- Get the highlight name from a table, and if it doesn't exist, make it
-- @param args The format data to do stuff with

function utils:get_hi_from_fmt(args)
	args.guifg = args.guifg or "NONE"
	args.guibg = args.guibg or "NONE"
	args.guisp = args.guisp or "NONE"
	args.ctermfg = args.ctermfg or "NONE"
	args.ctermbg = args.ctermbg or "NONE"
	args.ctermsp = args.ctermsp or "NONE"
	args.bold = args.bold or "0"
	args.italic = args.italic or "0"
	args.inverse = args.inverse or "0"
	args.standout = args.standout or "0"
	args.underline = args.underline or "0"
	args.undercurl = args.undercurl or "0"
	args.strikethrough = args.strikethrough or "0"

	local key = string.format("%s%s%s%s%s%s%s%s%s%s%s%s%s",
		args.guifg, args.guibg, args.guisp,
		args.ctermfg, args.ctermbg, args.ctermsp,
		args.bold, args.italic, args.inverse, args.standout,
		args.underline, args.undercurl, args.strikethrough)

	if colors[key] == nil then

		-- Construct gui string
		local gui = ""
		for _, k in pairs(
			{"bold", "italic", "inverse", "standout",
			"underline", "undercurl", "strikethrough"})
			do

			gui = gui..(args[k] == "1" and args[k].."," or "")
		end

		-- Create the highlight
		vim.cmd("highlight cth"..iter..
			" guifg="..args.guifg..
			" guibg="..args.guibg..
			" guisp="..args.guisp..
			" ctermfg="..args.ctermfg..
			" ctermbg="..args.ctermbg..
			" ctermsp="..args.ctermsp..
			" gui="..(gui ~= "" and gui or "NONE")
		)

		colors[key] = "cth"..iter
		iter = iter + 1

	else return colors[key] end

end

--[[----------------------------
--       BUFFER UTILS         --
----------------------------]]--

--- Buffer options
-- I don't know what all of these do, it was mostly copied from NvimTree
-- TODO: have modifiable as false and just set it to true when redrawing
-- that can be done with this: vim.bo[bufnr].modifiable = true/false
local bufopts = {
	swapfile = false,
    buftype = 'nofile',
    modifiable = true,
    filetype = 'colorthing',
    bufhidden = 'hide'
}

local kbopts = {noremap=true, silent=true, noawait=true}

--- The buffer number which is set when calling create_buffer
-- TODO: Store with other useful values
-- TODO: Make it not assumed in create_window or write_current_thing

--- Creates the window to put the buffer in
-- Creates a window to the right side with width 50
-- TODO: Make this stuff configurable with options
-- TODO: remove line numbers (this is actually important)
-- TODO: make its size fixed
-- @param the bufnr of the colorthing
function utils:create_window(bufnr)
	api.nvim_command("vsp")
	api.nvim_command("wincmd L")
	api.nvim_command("vertical resize 50")

	local winid = fn.win_getid()

	vim.w[winid].number = false

	vim.cmd("buffer "..bufnr)

	-- TODO: remove this, just call redraw
	fn.setbufline(bufnr, 1, "heyo")

end

--- Create a new buffer
-- Creates a new colorthing buffer with the buffer options and keybinds defined
-- in the above tables.
-- TODO: Ensure that there is only ever one buffer (by buffer name probably?)
-- @return bufnr
function utils:create_buffer(ui)
	local bufnr = api.nvim_create_buf(false, false)
	--api.nvim_buf_set_name(bufnr, "colorthing")

	-- set base buffer options
	for k, v in pairs(bufopts) do vim.bo[bufnr][k] = v end

	-- make keybinds for buffer
	local keybinds = {
		["<cr>"] = ui.keybind_event("enter"),
		["<tab>"] = ui.keybind_event("tab"),
		["<up>"] = ui.keybind_event("up"),
		["<down>"] = ui.keybind_event("down"),
		["q"] = ui.keybind_event("q"),
		["k"] = ui.keybind_event("up"),
		["j"] = ui.keybind_event("down"),
	}

	-- set keybinds for buffer
	for k, v in pairs(keybinds) do api.nvim_buf_set_keymap(bufnr, "n", k, v, kbopts) end

	return bufnr

end

--[[----------------------------
       GENERAL UTILS
----------------------------]]--

--- Recursively compares tables
function utils:compare_tables(t1, t2)
	--check that everything in t1 is in t2
	for k, _ in pairs(t1) do
		--If they're both tables recurse
		if type(t1[k]) == "table" and type(t2[k]) == "table" then
			if not utils:compare_tables(t1[k], t2[k]) then return false end

		--Otherwise just compare
		elseif t1[k] ~= t2[k] then return false end
	end

	--check for keys in t2 that aren't in t1
	for k, _ in pairs(t2) do if t1[k] == nil then return false end end

	-- If it didn't already return false then we're good
	return true
end

--- This is a test function
--[[function _G.write_current_thing()
	local hl = utils:get_treesitter_hl()
	fn.setbufline(bufnr, 1, hl[1])
	vim.cmd "hi thisisacolor guifg=#ffffff"
	vim.api.nvim_buf_add_highlight(bufnr, -1, "thisisacolor", 0, 0, 1)
end]]

--create_buffer()
--create_window()

