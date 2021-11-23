local opt = vim.opt
local g = vim.g
local fn = vim.fn

opt.termguicolors = true
opt.smartindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.cursorline = true
opt.number = true
opt.filetype = "on"

g.material_theme_style = "palenight"
vim.cmd "colorscheme material"

opt.viminfo = ""
opt.viminfofile = "NONE"

dofile("/etc/nixos/config/nvim/lua/treesitter.lua")
dofile("/etc/nixos/config/nvim/lua/lsp.lua")
dofile("/etc/nixos/config/nvim/lua/plugins.lua")

--other settings
--fold text
function _G.fold_text_fn()
	return string.format("%s {%d} ",
		--line without extraneous brackets
		fn.substitute(fn.getline(vim.v.foldstart),
		[[\v( *[[^[]\] *)|^ *[[]\] *| *[[]\] *$|]]..
		[[( *\([^\(]*\) *)|^ *[\(\)] *| *[\(\)] *$|]]..
		[[( *\{[^\{]*\} *)|^ *[\{\}] *| *[\{\}] *$]],
		"\\1\\2\\3", "g"),

		--number of lines in fold
		vim.v.foldend - vim.v.foldstart + 1)
end
opt.foldtext = "v:lua.fold_text_fn()"

--tabline
function _G.tabline_fn()
	local tabs = ""
	local ctab = fn.tabpagenr() --current tab
	for i=1, fn.tabpagenr("$") do
		local buflist = fn.tabpagebuflist(i)
		local bufnr = buflist[fn.tabpagewinnr(i)]
		local bufname = fn.bufname(bufnr)
		local buftype = fn.getbufvar(bufnr, "&buftype")

		--see :h buftype
		if buftype == "help" then bufname = fn.fnamemodify(bufname, ':t:r')
		elseif buftype == "quickfix" then bufname = "quickfix"
		elseif buftype ==  "nofile" then bufname = bufname --todo: fix
		elseif bufname == "" then bufname = "[No Name]"
		else bufname = fn.fnamemodify(bufname, ":~:.") end

		local tabtext = string.format("%s▌ %s%s :%d %s",
			i == ctab and "%#TabLineSel#" or "", --selected start
			fn.getbufvar(bufnr, "&modified") ~= 0 and "*" or "", --modified
			bufname, --name of buffer shortened
			#buflist, --number of buffers
			i == ctab and " %#TabLine#" or "") --selected end

		--append current tab
		tabs = tabs..tabtext
	end

	return "tabs: "..tabs
end
opt.tabline = "%!v:lua.tabline_fn()"

