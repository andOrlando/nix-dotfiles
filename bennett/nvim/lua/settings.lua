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
vim.g.mapleader = "\\"

g.material_theme_style = "palenight"
vim.cmd "colorscheme material"

opt.viminfo = ""
opt.viminfofile = "NONE"

dofile("/etc/nixos/bennett/nvim/lua/lsp.lua")
dofile("/etc/nixos/bennett/nvim/lua/plugins.lua")
--dofile("/etc/nixos/bennett/nvim/lua/colorthing/colorthing.lua")

--other settings
--nice tab bindings
local dog 
for i=1,9 do vim.api.nvim_set_keymap("n", "\\"..i, "<cmd>tabnext "..i.."<cr>", {noremap=true,silent=true}) end

--lsp message
vim.diagnostic.config({
	underline = { severity = vim.diagnostic.severity.ERROR },
	virtual_text = false
})

local signs = { Error = " ", Warn = " ", Hint = "->", Information = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

--fold text
local charmap = {["("]="...)",["["]="...]",['{']="...}"}
function _G.fold_text_fn()

	--fix indent, replace all matched brackets in the line with spaces
	local line = fn.getline(vim.v.foldstart):gsub('\t', string.rep(" ", opt.tabstop:get()))
	local sans_brackets = fn.substitute(line,
		[[\v\(([^\(^\)]{-})\)|\[([^\]^\[]{-})\]|\{([^{^}]{-})\}]], " \\1\\2\\3 ", "g")

	--find index of first unmatched bracket
	local iter, index = {}, #line
	sans_brackets:gsub(".", function(c) table.insert(iter, c) end)
	for i,c in pairs(iter) do if ("({["):find(c,1,true) then index = i; break end end

	--do line until unmatched bracket, do (...), do number
	local l = string.format("%s%s ", line:sub(0, index), charmap[line:sub(index,index)] or "")
	local r = string.format("[%d]", vim.v.foldend - vim.v.foldstart + 1)
	local m = string.rep("·", fn.winwidth(0)-fn.getwininfo(fn.win_getid())[1].textoff-#l-#r)
	return l..m..r
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
		elseif buftype ==  "nofile" then bufname = "[Empty]" --todo: fix
		elseif bufname == "" then bufname = "[No Name]"
		else bufname = fn.fnamemodify(bufname, ":~:.") end

		local tabtext = string.format("%s %s%s%s %s",
			i == ctab and "%#TabLineSel#" or "", --selected start
			fn.getbufvar(bufnr, "&modified") ~= 0 and "*" or "", --modified
			bufname, --name of buffer shortened
			#buflist > 1 and "+"..(#buflist-1) or "", --number of buffers
			i == ctab and "%#TabLine#" or "") --selected end

		--append current tab
		tabs = tabs..tabtext
	end

	return "tabs: "..tabs
end
opt.tabline = "%!v:lua.tabline_fn()"

--statusline
