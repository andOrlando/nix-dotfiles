--[[
Reads and writes colorscheme files and attatches it to current instance of
color window

]]

local file = {}

--- Create a new colorscheme
-- If you want to save edits to a new file you can do so. Will also commit all
-- changes in edits
-- @param name The name of the file to be created
function file:create_file()
	-- create headers and highlighting function
	-- define colors
	-- define values
end

--- Update a colorscheme
-- Takes all changes in `edits` and commits them to the colorscheme that's
-- currently being edited
-- @see edits
function file:update_file(colors, edits)
	-- ensure that there is a file being worked on
	-- ensure that the colorscheme is a generated one
	-- go through all edits and commit them to the colorscheme (regex prolly)
end

--- Loads colorscheme but also updates file.colors
-- In some cases the location of the file might not be in the right folder. If
-- so, allows loading of files from alternate locations
-- @param dir The directory of the vimscript file to be sourced
function file:load_file(dir)
	--check that it's generated
	--set colorscheme
	--add colors to file.colors
end



return file
