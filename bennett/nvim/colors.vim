let s:n = ["NONE", "NONE", "NONE"]
let s:em = {
	\"b": "bold",
	\"i": "italic",
	\"in": "inverse",
	\"s": "standout",
	\"ul": "underline",
	\"uc": "undercurl",
	\"st": "strikethrough"
\}

function s:HL(group, ...)
	"args: fg, bg, gui, guisp, base
	let l:fg = s:n
	let l:bg = s:n
	let l:sp = s:n
	let l:gui = s:n

	" check if there's a base given
	if a:0 == 5
		let l:hlID = hlID(a:5)
		let l:fg = [
			\synIDattr(l:hlID, "fg", "GUI"), 
			\synIDattr(l:hlID, "fg", "cterm"), 
			\synIDattr(l:hlID, "fg", "cterm")
		\]
		let l:bg = [
			\synIDattr(l:hlID, "bg", "GUI"), 
			\synIDattr(l:hlID, "bg", "cterm"), 
			\synIDattr(l:hlID, "bg", "cterm")
		\]
		let l:sp = [
			\synIDattr(l:hlID, "sp", "GUI"), 
			\synIDattr(l:hlID, "sp", "cterm"), 
			\synIDattr(l:hlID, "sp", "cterm")
		\]
		let l:gui = join(filter([
			\synIDattr(l:hlID, s:em.b) ? s:em.b : ""
			\synIDattr(l:hlID, s:em.i) ? s:em.i : ""
			\synIDattr(l:hlID, s:em.s) ? s:em.s : ""
			\synIDattr(l:hlID, s:em.in) ? s:em.in : ""
			\synIDattr(l:hlID, s:em.ul) ? s:em.ul : ""
			\synIDattr(l:hlID, s:em.uc) ? s:em.uc : ""
			\synIDattr(l:hlID, s:em.st) ? s:em.st : ""
		\], 'v:val != ""'), ",")
	endif
	
	" override base's values
	let l:fg = a:0 >= 1 && a:1 != s:n ? a:1 : l:fg
	let l:bg = a:0 >= 2 && a:2 != s:n ? a:2 : l:bg
	let l:sp = a:0 >= 4 && a:4 != s:n ? a:4 : l:sp
	let l:gui = a:0 >= 3 && a:3 != s:n ? type(a:3) == 3 ? join(a:3, ",") : a:3

	" do mod 8 if 8-color
	if &t_Co <= 8
		let l:fg[2] %= 8
		let l:bg[2] %= 8
		let l:sp[2] %= 8
	endif

	" do highlighting
	execute("hi".
		\" guifg=".l:fg[0].
		\" guibg=".l:bg[0].
		\" ctermfg=".l:fg[1+(&t_Co <= 16)].
		\" ctermbg=".l:bg[1+(&t_Co <= 16)].
		\" gui=".l:gui.
		\" cterm=".l:gui.
		\" guisp=".l:guisp
	\)

endfunction


" it goes darker, dark, normal, light, lighter
" first is 24 bit, second is 256-color, third is 16-color
" 8-color is made to be so in the highlight function (just does % 8)
let s:black = {
	\"dr":	["#3e3f40", 0, 0],
	\"d":	["#4b4c4d", 0, 0],
	\"n":	["#505252", 0, 8],
	\"l":	["#5e6061", 0, 8],
	\"lr":	["#7e7f80", 0, 8]}
let s:red = {
	\"dr":	["#bf062b",  88, 1],
	\"d":	["#c73247", 160, 1],
	\"n":	["#e95678", 161, 9],
	\"l":	["#ff91a2", 198, 9],
	\"lr":	["#ffb5c6", 255, 9]}
let s:green = {
	\"dr":	["#1b7a46",  22,  2],
	\"d":	["#29ba61",  29,  2],
	\"n":	["#50eb80",  48, 10],
	\"l":	["#81f7a6",  49, 10],
	\"lr":	["#c9f2d6", 255, 10]}
let s:yellow = {
	\"dr":	["#e0ac00",  94,  3],
	\"d":	["#f7d22d", 184,  3],
	\"n":	["#fdfd5f", 190, 11],
	\"l":	["#f8ff91", 227, 11],
	\"lr":	["#fbffc2", 255, 11]}
let s:blue = {
	\"dr":	["#324185",  18,  4],
	\"d":	["#495cb3",  56,  4],
	\"n":	["#6e82db",  57,  4],
	\"l":	["#9faff5",  33, 12],
	\"lr":	["#cbd3f7", 111, 12]}
let s:purple = {
	\"dr":	["#8168ab",  54,  5],
	\"d":	["#ad96eb",  92, 13],
	\"n":	["#dd8ee8", 129, 13],
	\"l":	["#ff87d3", 199, 13],
	\"lr":	["#ffb5df", 219, 13]
\}
let s:cyan = {
	\"dr":	["#1ea89f",  30,  6],
	\"d":	["#24bfb5",  37,  6],
	\"n":	["#57d1de",  44, 14],
	\"l":	["#79e2ed",  51, 14],
	\"lr":	["#bdf9ff", 255, 14]}
let s:white = {
	\"dr":	["#8e9494", 245,  7],
	\"d":	["#bbbdbd", 250,  7],
	\"n":	["#cacccc", 252,  7],
	\"l":	["#e1e3e3", 254, 15],
	\"lr":	["#f5fbfc", 255, 15]}
let s:orange = {
	\"dr":	["#fc3b00", 166,  3],
	\"d":	["#fc5f21", 208,  3],
	\"n":	["#fc7642", 214,  3],
	\"l":	["#fcb06d", 215, 11],
	\"lr":	["#fcca9f", 255, 11]}

" some commonly used variables are kept track of 
let s:bg = s:black.dr
let s:fg = s:white.n
let s:comment = s:white.dr

" set terminal colors for neovim
if has("nvim")
	let g:terminal_color_0 = s:black.dr[0]
	let g:terminal_color_1 = s:red.dr[0]
	let g:terminal_color_2 = s:green.dr[0]
	let g:terminal_color_3 = s:yellow.dr[0]
	let g:terminal_color_4 = s:blue.dr[0]
	let g:terminal_color_5 = s:purple.dr[0]
	let g:terminal_color_6 = s:cyan.dr[0]
	let g:terminal_color_7 = s:white.dr[0]
	let g:terminal_color_8 = s:black.n[0]
	let g:terminal_color_9 = s:red.n[0]
	let g:terminal_color_10 = s:green.n[0]
	let g:terminal_color_11 = s:yellow.n[0]
	let g:terminal_color_12 = s:blue.n[0]
	let g:terminal_color_13 = s:purple.n[0]
	let g:terminal_color_14 = s:cyan.n[0]
	let g:terminal_color_15 = s:white.n[0]
endif

call s:HL("CursorLine", s:n, s:black.d)
call s:HL("Cursor", s:n, s:n, s:em.in)
call s:HL("Directory", s:blue.n, s:n, s:em.b)
call s:HL("DiffAdd", s:green.d)
call s:HL("DiffChange", s:yellow.d)
call s:HL("DiffDelete", s:red.d)
call s:HL("DiffText", s:n, s:n)
call s:HL("EndOfBuffer", s:n, s:black.d)
"
call s:HL("ErrorMsg", s:red.n, s:n, s:em.b)
call s:HL("VertSplit", s:black.l, s:black.l)
call s:HL("Folded", s:white.d, s:none, s:em.b)
call s:HL("SignColumn", s:bg, s:bg)

call s:HL("Search", s:bg, s:orange.l)
hi! link Search IncSearch
hi! link Search Substitute
call s:HL("Substitute", s:bg, s:yellow.l)

call s:HL("LineNr", s:bg.d)
call s:HL("CursorLineNr", s:bg.n, s:n, s:em.b)
call s:HL("MatchParen", s:cyan.n, s:n, s:em.b)
call s:HL("Normal", s:fg, s:bg)

hi! link Normal NormalFloat

call s:HL("Pmenu", s:fg, s:black.n)
call s:HL("PmenuSel", s:fg, s:green.d)
hi! link Pmenu PmenuSbar
call s:HL("PmenuThumb", s:black.n, s:green.dr)

call s:HL("SpecialKey", s:red.n, s:n, s:em.b)
call s:HL("SpellBad", s:n, s:n, s:em.ul, s:red.n)
call s:HL("SpellCap", s:n, s:n, s:em.ul, s:yellow.n)
call s:HL("SpellLocal", s:n, s:n, s:em.ul, s:red.l)
call s:HL("SpellRare", s:n, s:n, s:em.ul, s:blue.n)

call s:HL("TabLine", s:fg, s:black.n)
call s:HL("TabLineFill", s:fg, s:black.n)
call s:HL("TabLineSel", s:fg, s:black.l)

call s:HL("Title", s:blue.n, s:n, s:em.b)
call s:HL("Visual", s:fg, s:black.l)
hi! link Visual VisualNOS
call s:HL("WarningMsg", s:yellow.n, s:n, s:em.b)
call s:HL("Whitespace", s:fg, s:bg)


hi! link Comment gitcommitComment
call s:HL("gitcommitUntracked", s:red.l, s:n, s:em.i)
call s:HL("gitcommitDiscarded", s:red.n, s:n, s:em.i)
call s:HL("gitcommitSelected", s:green.n, s:n, s:em.i)
call s:HL("gitcommitUnmerged", s:green.n)
call s:HL("gitcommitBranch", s:purple.n)
call s:HL("gitcommitNoBranch", s:purple.n)
call s:HL("gitcommitDiscardedType", s:red.n)
call s:HL("gitcommitSelectedType", s:green.n)
call s:HL("gitcommitUntrackedFile", s:red.l)
call s:HL("gitcommitDiscardedFile", s:red.l)
call s:HL("gitcommitDiscardedArrow", s:red.n)
call s:HL("gitcommitSelectedFile", s:green.n)
call s:HL("gitcommitSelectedArrow", s:green.n)
call s:HL("gitcommitUnmergedFile", s:yellow.n)
call s:HL("gitcommitUnmergedArrow", s:yellow.n)
call s:HL("gitcommitSummary"),
call s:HL("gitcommitOverflow", bg = red )
call s:HL("gitcommitOnBranch"),
call s:HL("gitcommitHeader"),
call s:HL("gitcommitFile"),


"call s:HL("Conceal      ", fg = blue_light, gui = 'bold' )
"call s:HL("ModeMsg      "},
"call s:HL("MsgArea      "},
"call s:HL("MsgSeparator "},
"call s:HL("MoreMsg      "},
"call s:HL("NonText      ", fg = comment )
"call s:HL("Question     ", fg = violet )
"call s:HL("QuickFixLine ", fg = fg, bg = bg_light )
"call s:HL("StatusLine   ", fg = fg, bg = bg_light )
"call s:HL("StatusLineNC ", fg = comment )
"call s:HL("WildMenu    " gui = 'bold'}
"
"call s:HL("Comment        ", fg = comment )
"call s:HL("String         ", fg = fg_dark )
"call s:HL("Constant       ", fg = violet )
"call s:HL("Boolean        ", fg = blue_light, gui = 'bold')
"call s:HL("Character      ", fg = violet, gui = 'bold' )
"call s:HL("Number         ", fg = yellow )
"call s:HL("Float          ", fg = orange )
"
"call s:HL("Identifier     ", fg = purple )
"call s:HL("Function       ", fg = blue, gui = 'bold' )
"
"call s:HL("Statement      ", fg = cyan )
"call s:HL("Conditional    ", fg = cyan )
"call s:HL("Repeat         ", fg = cyan )
"call s:HL("Label          ", fg = cyan )
"call s:HL("Exception      ", fg = red_light )
"call s:HL("Operator       ", fg = cyan_light )
"call s:HL("Keyword        ", fg = violet, gui = 'bold')
"
"call s:HL("Include        ", fg = orange)
"call s:HL("Define         ", fg = orange )
"call s:HL("Macro          ", fg = orange )
"call s:HL("PreProc        ", fg = yellow )
"call s:HL("PreCondit      ", fg = yellow )
"
"call s:HL("Type           ", fg = yellow )
"call s:HL("StorageClass   ", fg = yellow )
"call s:HL("Structure      ", fg = yellow )
"call s:HL("Typedef        ", fg = yellow )
"
"call s:HL("Special        ", fg = blue )
"call s:HL("SpecialChar    "},
"call s:HL("Tag            ", fg = blue_light )
"call s:HL("SpecialComment ", fg = comment, gui = 'bold' )
"call s:HL("Debug          "},
"call s:HL("Delimiter      "},
"
"call s:HL("Ignore         "},
"call s:HL("Underlined     ", gui = 'underline' )
"call s:HL("Error          ", fg = red )
"call s:HL("Todo           ", fg = orange, gui = 'bold' )
""
"call s:HL("GitGutterAdd           ", fg = green )
"call s:HL("GitGutterChange        ", fg = yellow )
"call s:HL("GitGutterDelete        ", fg = red )
"call s:HL("GitGutterChangeDelete  ", fg = orange )
""
"call s:HL("diffAdded              ", fg = green )
"call s:HL("diffRemoved            ", fg = red )
""
""	TSError                = code_syntax.Error,
"call s:HL("TSPunctDelimiter       ", fg = fg )
"call s:HL("TSPunctBracket         ", fg = orange )
"call s:HL("TSPunctSpecial         ", fg = fg )
""	TSConstant             = code_syntax.Constant,
""	TSConstBuiltin         = code_syntax.Constant,
""	TSConstMacro           = code_syntax.Macro,
""	TSString               = code_syntax.String,
"call s:HL("TSStringRegex          ", fg = red_light )
"call s:HL("TSStringEscape         ", fg = red )
""	TSNumber               = code_syntax.Number,
""	TSFloat                = code_syntax.Float,
""	TSBoolean              = code_syntax.Boolean,
""	TSFunction             = code_syntax.Function,
""	TSFuncBuiltin          = override(code_syntax.Function, {gui="bold"}),
""	TSFuncMacro            = code_syntax.Macro, 
"call s:HL("TSParameter            ", fg = cyan )
"call s:HL("TSParameterReference   ", fg = cyan )
"call s:HL("TSMethod               ", fg = blue_light )
"call s:HL("TSField                ", fg = violet )
"call s:HL("TSProperty             ", fg = purple )
"call s:HL("TSConstructor          ", fg = violet, gui = 'underline' )
""	TSConditional          = code_syntax.Conditional,
""	TSRepeat               = code_syntax.Statement,
""	TSException            = code_syntax.Exception,
""	TSLabel                = code_syntax.Label,
""	TSOperator             = code_syntax.Operator,
""	TSKeyword              = code_syntax.Keyword,
""	TSKeywordFunction      = code_syntax.Function,
""	TSKeywordOperator      = code_syntax.Keyword,
""	TSType                 = code_syntax.Type,
""	TSTypeBuiltin          = code_syntax.Type,
""	TSStructure            = code_syntax.Structure,
""	TSInclude              = code_syntax.Include,
""	TSTag                  = code_syntax.Tag,
""	TSTagDelimiter         = code_syntax.Delimiter,
"call s:HL("-- TSAnnotation "},
"call s:HL("TSVariable ", fg = cyan )
"call s:HL("TSVariableBuiltin ", fg = cyan )
"call s:HL("-- TSDefinitionUsage "},
"call s:HL("-- TSDefinition "},
"call s:HL("-- TSCurrentScope                 "},
"call s:HL("-- TSText                 "},
"call s:HL("-- TSStrong               "},
"call s:HL("-- TSEmphasis             "},
"call s:HL("-- TSUnderline            "},
"call s:HL("-- TSTitle                "},
"call s:HL("-- TSLiteral              "},
"call s:HL("-- TSURI                  "},
""
"	"hi clear
"
""syntax reset
""set termguicolors
""let g:colors_name="colors"
"
""lua require 'colors'.setup()
