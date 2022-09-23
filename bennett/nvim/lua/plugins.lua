local g = vim.g
local opt = vim.opt
local binds = require "binds"

--Treesitter stuff
require("nvim-treesitter.configs").setup {
	ensure_installed = "all",
	highlight = {
		enable = true
	}
}

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"

--comment-nvim https://github.com/numToStr/Comment.nvim
require("Comment").setup()

--nvim cmp https://github.com/hrsh7th/nvim-cmp
local cmp = require "cmp"
cmp.setup {
	enabled = function()
		-- disable completion in telescope
        if vim.bo.filetype == "TelescopePrompt" then return false end

        -- disable completion in comments
        local context = require('cmp.config.context')

        -- keep command mode completion enabled when cursor is in a comment
        if vim.api.nvim_get_mode().mode == 'c' then return true
		else return not context.in_treesitter_capture('comment') and not context.in_syntax_group('Comment') end
	end,
	window = {
        completion = {
            winhighlight = 'Normal:Pmenu,FloatBorder:CmpCompletionBorder,CursorLine:PmenuSel,Search:None',
            --col_offset = -4, -- why won't this work?
            side_padding = 0,
        },
    },
	completion = { completeopt = "menuone,noselect", keyword_length = 1 },
	formatting = {
		format = function(entry, vim_item)
			local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
            local strings = vim.split(kind.kind, '%s', { trimempty = true })

            kind.kind = " "..strings[1].." "
            kind.menu = "["..strings[2].."]"

            return kind
		end
	},
	mapping = binds.cmp,
	--snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
	sources = {
		{ name = "nvim_lsp", priority = 1 },
		{ name = "buffer" },
		{ name = "path" },
	},
	experimental = { ghost_text = true },
}

--auto-pairs
require "nvim-autopairs".setup { disable_filetype = { 'telescope', 'vim' } }

--Chadtree stuff https://github.com/ms-jpq/chadtree
vim.g.chadtree_settings = {
    xdg = true,
	keymap = { tertiary = {"<C-T>"}, },
    view = {
        width = 32,
        window_options = {
            number = false,
            relativenumber = false,
            wrap = false,
        }
    },
    theme = {
        text_colour_set = 'env',
        icon_colour_set = 'none',
        discrete_colour_map = {
            black          = "#2b3339",
            red            = "#e67e80",
            green          = "#a7c080",
            yellow         = "#dbbc7f",
            blue           = "#7fbbb3",
            magenta        = "#d699b6",
            cyan           = "#83c092",
            white          = "#d3c6aa",

            bright_black   = "#607279",
            bright_red     = "#e67e80",
            bright_green   = "#a7c080",
            bright_yellow  = "#dbbc7f",
            bright_blue    = "#7fbbb3",
            bright_magenta = "#d699b6",
            bright_cyan    = "#83c092",
            bright_white   = "#d3c6aa",
        }
    }
}

--dashboard
local dashboard = require "dashboard"
dashboard.custom_center = {
    { icon = '  ', desc = 'New File                        ', shortcut = 'SPC N f', action = 'DashboardNewFile', },
    { icon = '  ', desc = 'Bookmarks                       ', shortcut = 'SPC f b', action = 'Telescope marks', },
    { icon = '  ', desc = 'Browse Files                    ', shortcut = 'SPC f f', action = 'Telescope find_files', },
    { icon = '  ', desc = 'Recent Files                    ', shortcut = 'SPC f r', action = 'Telescope oldfiles', },
    { icon = '  ', desc = 'Find Word                       ', shortcut = 'SPC f w', action = 'Telescope live_grep', },
}

dashboard.custom_footer = {
    '',
    '[ neovim ]',
}

--gitsigns
require"gitsigns".setup({
	signs = {
		add = { hl = 'GitSignsAdd', text = '┃', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
		change = { hl = 'GitSignsChange', text = '┃', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
		delete = { hl = 'GitSignsDelete', text = '_', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
		topdelete = { hl = 'GitSignsDelete', text = '‾', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
		changedelete = { hl = 'GitSignsChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
	},
	signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
	numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
	linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
	word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`

	--keymaps = keymap.gitsigns_mappings,
	watch_gitdir = {
		interval = 1000,
		follow_files = true,
	},
	attach_to_untracked = true,
	current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
		delay = 1000,
	},
	current_line_blame_formatter_opts = { relative_time = false },
	sign_priority = 6,
	update_debounce = 100,
	status_formatter = nil, -- Use default
	max_file_length = 40000,
	preview_config = {
		-- Options passed to nvim_open_win
		border = 'single',
		style = 'minimal',
		relative = 'cursor',
		row = 0,
		col = 1,
	},
	yadm = { enable = false, },
})

--hexokinase
g.Hexokinase_highlighters = { 'backgroundfull' }
g.Hexokinase_optInPatterns = { 'full_hex', 'triple_hex', 'rgb', 'rgba', 'hsl', 'hsla' }

--hop
require"hop".setup({ keys = 'etovxqpdygfblzhckisuran', term_seq_bias = 0.5 })

--lspkind
require"lspkind".init({
    mode = 'symbol_text',
    preset = 'default',
    symbol_map = {
        Text          = "",
        Method        = "",
        Function      = "",
        Constructor   = "",
        Field         = "",
        Variable      = "",
        Class         = "ﴯ",
        Interface     = "",
        Module        = "",
        Property      = "ﰠ",
        Unit          = "塞",
        Value         = "",
        Enum          = "",
        Keyword       = "",
        Snippet       = "",
        Color         = "",
        File          = "",
        Reference     = "",
        Folder        = "",
        EnumMember    = "",
        Constant      = "",
        Struct        = "פּ",
        Event         = "",
        Operator      = "",
        TypeParameter = ""
    },
})

--notify TODO: maybe remove, it's on thin ice--see how well it does
local notify = require('notify')
notify.setup {
    timeout = 1600,
    stages = 'slide',
    icons = {
        ERROR = '',
        WARN  = '',
        INFO  = '',
        DEBUG = '',
        TRACE = '✎',
    },
    max_height = 5,
    max_width = 80,
    minimum_width = 16,
    --render = 'minimal',
    fps = 75,
}

vim.notify = notify

--comment
require "nvim_comment".setup {
    marker_padding = true,
    comment_empty = false,
    create_mappings = false,
    line_mapping = 'gcc',
    operator_mapping = 'gc',
    hook = nil,
}

--presence for discord
require("presence"):setup {
    -- General options
    auto_update = true,
    neovim_image_text = "vim but cooler", --image hover text
    main_image = "file",
    --client_id = "793271441293967371", --your discord client id?
    debounce_timeout = 10,
    enable_line_number = false,
    blacklist = {},
    buttons = true,
    file_assets = {},

    -- Rich Presence text options
    editing_text = "Editing %s",
    file_explorer_text = "Browsing %s",
    git_commit_text = "Committing changes",
    plugin_manager_text = "Managing plugins",
    reading_text = "Reading %s",
    workspace_text = "Working on %s",
    line_number_text = "Line %s out of %s",
}

--telescope
require('telescope').setup({
	defaults = {
		prompt_prefix = '=> ',
		selection_caret = '-> ',
		entry_prefix = '   ',
		borderchars = { '━', '┃', '━', '┃', '┏', '┓', '┛', '┗' },
		sorting_strategy = "descending",
	},
	extensions = {
		fzf = {
			fuzzy = true,
			override_genearic_sorter = false,
			override_file_sorter = true,
			case_mode = 'smart_case',
		},
	},
})
require('telescope').load_extension('fzf')

-- ignore files that are larger than a certain size
-- TODO: concatenate with above
--[[local previewers = require('telescope.previewers')
local new_maker = function(filepath, bufnr, opts)
	opts = opts or {}

	filepath = vim.fn.expand(filepath)
	vim.loop.fs_stat(filepath, function(_, stat)
		if not stat then
			return
		end
		if stat.size > 100000 then
			return
		else
			previewers.buffer_previewer_maker(filepath, bufnr, opts)
		end
	end)
end

require('telescope').setup({
	defaults = {
		buffer_previewer_maker = new_maker,
	},
})]]


--lsp_signature https://github.com/ray-x/lsp_signature.nvim
--require("lsp_signature").setup {}

--copilot
--vim.api.nvim_set_keymap("i", "<c-l>", "copilot#Accept()", {silent=true, script=true, expr=true})
--g.copilot_no_tab_map = true --fix tab map thing

--lspsaga
--[[local saga = require 'lspsaga'
saga.init_lsp_saga {border_style="none"}

vim.api.nvim_set_keymap("n", "ca", "<cmd>lua require('lspsaga.codeaction').code_action()<cr>", {noremap=true, silent=true})]]
