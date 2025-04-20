-- Minimal init.lua for Raspberry Pi Zero 2W
-- Optimized for distraction-free writing with AI assistance

-- Basic settings for performance
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable unnecessary features to save resources
vim.g.loaded_gzip = 0
vim.g.loaded_zip = 0
vim.g.loaded_zipPlugin = 0
vim.g.loaded_tar = 0
vim.g.loaded_tarPlugin = 0
vim.g.loaded_getscript = 0
vim.g.loaded_getscriptPlugin = 0
vim.g.loaded_vimball = 0
vim.g.loaded_vimballPlugin = 0
vim.g.loaded_2html_plugin = 0
vim.g.loaded_matchit = 0
vim.g.loaded_matchparen = 0
vim.g.loaded_logiPat = 0
vim.g.loaded_rrhelper = 0
vim.g.loaded_netrw = 0
vim.g.loaded_netrwPlugin = 0
vim.g.loaded_netrwSettings = 0
vim.g.loaded_netrwFileHandlers = 0

-- Bootstrap lazy.nvim (minimal package manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options optimized for low-resource environment
vim.opt.number = true                 -- Show line numbers 
vim.opt.relativenumber = false        -- Disable relative numbers (saves processing)
vim.opt.mouse = "a"                   -- Enable mouse (if available)
vim.opt.clipboard = ""                -- Don't use system clipboard (saves resources)
vim.opt.expandtab = true              -- Use spaces instead of tabs
vim.opt.tabstop = 2                   -- 2 spaces per tab (smaller indents for limited width)
vim.opt.shiftwidth = 2                -- Same as tabstop
vim.opt.softtabstop = 2               -- Same as tabstop
vim.opt.smartindent = true            -- Smart indenting
vim.opt.wrap = true                   -- Enable line wrapping (essential for small screen)
vim.opt.linebreak = true              -- Break lines at word boundaries
vim.opt.incsearch = true              -- Incremental search
vim.opt.hlsearch = true               -- Highlight search results
vim.opt.ignorecase = true             -- Case-insensitive search
vim.opt.smartcase = true              -- Case-sensitive when uppercase present
vim.opt.splitbelow = true             -- Open new split below
vim.opt.splitright = true             -- Open new split to the right
vim.opt.hidden = true                 -- Allow hidden buffers
vim.opt.termguicolors = false         -- Disable true colors (not needed in console)
vim.opt.scrolloff = 5                 -- Keep 5 lines visible when scrolling
vim.opt.signcolumn = "no"             -- Hide sign column to save space
vim.opt.showmode = true               -- Show current mode
vim.opt.ruler = true                  -- Show ruler
vim.opt.laststatus = 1                -- Only show status line if more than one window
vim.opt.cmdheight = 1                 -- Command line height
vim.opt.shortmess = "aoOtTIcF"        -- Shorten messages to avoid 'press enter' prompts
vim.opt.writebackup = false           -- Disable backup files (saves resources)
vim.opt.backup = false                -- Disable backup
vim.opt.swapfile = false              -- Disable swapfile
vim.opt.updatetime = 1000             -- Update time (adjust if needed)
vim.opt.redrawtime = 1000             -- Reduce time for redrawing the display
vim.opt.showcmd = false               -- Don't show partial commands (saves resources)
vim.opt.showmatch = false             -- Don't highlight matching brackets (saves resources)
vim.opt.wildmenu = true               -- Command-line completion
vim.opt.wildmode = "list:longest,full" -- Wildmenu behavior

-- Performance optimizations (improved for better syntax highlighting)
vim.opt.maxmempattern = 2000          -- Increased for better syntax highlighting
vim.opt.lazyredraw = true             -- Do not redraw screen during macros (save CPU)
vim.opt.synmaxcol = 200               -- Increased for wider syntax highlighting
vim.opt.regexpengine = 0              -- Auto-select regex engine for better reliability
vim.opt.report = 9999                 -- Don't report on line changes (saves messages)
vim.opt.cursorline = false            -- Disable cursor line (saves rendering)
vim.opt.viewoptions = ""              -- Don't save/restore options, folds, etc.
vim.opt.belloff = "all"               -- Disable all bells

-- Global variables
vim.g.markdown_template_applied = 0
vim.g.template_dir = vim.fn.expand('~/.config/nvim/templates')

-- Define minimal plugins
require("lazy").setup({
  -- Improved Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate markdown lua",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "markdown", "markdown_inline", "lua" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        sync_install = false,
      })
      
      -- Force syntax refresh when cursor stops moving
      vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
        pattern = "*.md",
        callback = function()
          vim.cmd("syntax sync fromstart")
        end,
      })
    end,
  },

  -- Minimal console-friendly colorscheme
  {
    "srcery-colors/srcery-vim",
    priority = 1000,
    config = function()
      vim.g.srcery_transparent_background = 1
      vim.cmd([[colorscheme srcery]])
    end,
  },

  -- Markdown writing support (lightweight plugin)
  {
    "preservim/vim-markdown",
    ft = "markdown",
    init = function()
      vim.g.vim_markdown_folding_disabled = 1      -- Disable folding (save resources)
      vim.g.vim_markdown_frontmatter = 1           -- Support frontmatter
      vim.g.vim_markdown_conceal = 0               -- Disable syntax concealing
      vim.g.vim_markdown_conceal_code_blocks = 0   -- Don't conceal code blocks
      vim.g.vim_markdown_follow_anchor = 0         -- Don't follow anchors (save resources)
      vim.g.vim_markdown_no_extensions_in_markdown = 0 -- Use extensions in links
    end,
  },

  -- Basic pairs and text manipulation
  {
    "jiangmiao/auto-pairs",
    event = "InsertEnter",
  },

  -- Avante.nvim for AI assistance (kept as it's a core requirement)
  {
    "yetone/avante.nvim",
    event = "VeryLazy", -- Load after startup
    build = "make BUILD_TARGET=arm", -- Build for ARM
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      provider = "claude",
      
      -- Claude specific configuration
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-7-sonnet-latest", -- Claude 3.7 Sonnet
        timeout = 120000, -- Increased timeout for slower device
        temperature = 0,
        max_tokens = 4096, -- Reduced for less memory usage
      },
      
      -- Simplified behavior settings
      behaviour = {
        auto_set_highlight_group = false, -- Disable highlighting
        auto_apply_diff_after_generation = false,
        enable_token_counting = false, -- Disable token counting to save resources
        enable_cursor_planning_mode = true,
        enable_claude_text_editor_tool_mode = true,
        enable_rag = false, -- Disable RAG to save resources
      },
      
      mappings = {
        ask = "<leader>aa",
        edit = "<leader>ae",
        refresh = "<leader>ar",
        diff = {
          ours = "co",
          theirs = "ct",
          both = "cb",
          next = "]x",
          prev = "[x",
        },
        submit = {
          normal = "<CR>",
          insert = "<C-s>",
        },
      },
    },
  },
})

-- Helper functions
-- Format tags function
local function format_tags(tags_string)
  local trimmed = vim.fn.trim(tags_string)
  if trimmed == "" then
    return "[[]]"
  end
  
  local tags = vim.split(trimmed, ",")
  local formatted_tags = {}
  
  for _, tag in ipairs(tags) do
    local trimmed_tag = vim.fn.trim(tag)
    if trimmed_tag ~= "" then
      table.insert(formatted_tags, "[[" .. trimmed_tag .. "]]")
    end
  end
  
  return table.concat(formatted_tags, ", ")
end

-- Prompt for tags function
local function prompt_for_tags()
  local tags_input = vim.fn.input("Tags (separated by comma): ")
  return format_tags(tags_input)
end

-- Apply template function
local function apply_template(template, title)
  local template_path = vim.g.template_dir .. "/" .. template
  if vim.fn.filereadable(template_path) == 1 then
    -- Make sure we're at the start of the file
    vim.cmd("normal! gg")
    
    -- Read template file at the top of the buffer
    vim.cmd("0read " .. template_path)
    
    -- Get the title - either from the argument or the filename
    local file_title = title or vim.fn.expand("%:t:r")
    
    -- Prompt for tags
    local formatted_tags = prompt_for_tags()
    
    -- Expand common variables
    vim.cmd([[silent! %s/{{date}}/\=strftime('%Y-%m-%d')/ge]])
    vim.cmd([[silent! %s/{{title}}/]] .. vim.fn.escape(file_title, "/") .. [[/ge]])
    vim.cmd([[silent! %s/{{tags}}/]] .. vim.fn.escape(formatted_tags, "/") .. [[/ge]])
    
    -- Position cursor at the cursor marker if it exists, otherwise at the end of file
    if vim.fn.search("{{cursor}}", "w") > 0 then
      -- Replace the marker with an empty string
      vim.cmd([[s/{{cursor}}//e]])
      -- Enter insert mode
      vim.cmd("startinsert")
    else
      -- Position cursor at the end of the file and enter insert mode
      vim.cmd("normal! G")
      vim.cmd("startinsert")
    end
    
    -- Mark as modified to ensure save works properly
    vim.opt.modified = true
  else
    print("Template not found: " .. template_path)
  end
end

-- Sanitize filename function
local function sanitize_filename(title)
  local sanitized = title:gsub("[^a-zA-Z0-9]", "_")
  return string.lower(sanitized)
end

-- Create and edit function
local function create_and_edit(file)
  local dir = vim.fn.fnamemodify(file, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
  vim.cmd("edit " .. file)
end

-- New markdown file function
local function new_markdown_file()
  local original_title = vim.fn.input("New Markdown file title: ")
  if original_title == "" then
    print("Cancelled")
    return
  end
  
  -- Create sanitized filename
  local filename = sanitize_filename(original_title) .. ".md"
  
  -- Set the global flag to prevent autocommand from applying template
  vim.g.markdown_template_applied = 1
  
  -- Create and edit the file
  create_and_edit(filename)
  
  -- Apply template with original title, not the filename
  apply_template("skeleton.md", original_title)
  
  -- Reset the flag for future file creations
  vim.defer_fn(function()
    vim.g.markdown_template_applied = 0
  end, 100)
end

-- Simple file finder function (replacement for Telescope)
local function find_files()
  local command = "find . -type f -name '*.md' | sort"
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()
  
  local files = {}
  for file in string.gmatch(result, "[^\n]+") do
    table.insert(files, file:sub(3)) -- Remove the './' prefix
  end
  
  -- Print files with numbers
  print("Markdown files:")
  for i, file in ipairs(files) do
    print(i .. ": " .. file)
  end
  
  -- Prompt for selection
  local selection = tonumber(vim.fn.input("Select file (number): "))
  if selection and files[selection] then
    vim.cmd("edit " .. files[selection])
  end
end

-- Add function to force syntax resync
local function force_syntax_resync()
  vim.cmd("syntax sync fromstart")
end

-- Map key for manual syntax refresh
vim.keymap.set("n", "<leader>sr", force_syntax_resync, {silent = true, desc = "Refresh syntax highlighting"})

-- Syntax highlighting refresh on file open and when idle
vim.api.nvim_create_autocmd({"BufReadPost", "BufWritePost"}, {
  pattern = "*.md",
  callback = force_syntax_resync
})

-- Additional keymaps
-- Basic navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Quick commands
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", {silent = true}) -- Clear search
vim.keymap.set("n", "<leader>w", ":w<CR>", {silent = true})         -- Quick save
vim.keymap.set("n", "<leader>q", ":q<CR>", {silent = true})         -- Quick quit

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", {silent = true})
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", {silent = true})
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", {silent = true})

-- File navigation (simple alternatives to Telescope)
vim.keymap.set("n", "<leader>ff", find_files, {silent = true, desc = "Find markdown files"})
vim.keymap.set("n", "<leader>fb", ":ls<CR>:b ", {desc = "List buffers"})

-- Template application
vim.keymap.set("n", "<leader>t", ":Template skeleton.md<CR>", {silent = true})
vim.keymap.set("n", "<leader>n", ":NewMarkdown<CR>", {silent = true})

-- Add user commands for templates
vim.api.nvim_create_user_command("Template", function(opts)
  apply_template(opts.args)
end, {nargs = 1, complete = "file"})

vim.api.nvim_create_user_command("NewMarkdown", function()
  new_markdown_file()
end, {})

-- Set up essential autocommands
local autocmd = vim.api.nvim_create_autocmd

-- Remember last cursor position (minimal version)
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 1 and line <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end,
})

-- Markdown-specific settings
autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Basic settings for markdown
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 80
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = "> "
    
    -- Minimal formatting options
    vim.opt_local.formatoptions = "tqn"
    
    -- Add markdown-specific mappings
    vim.keymap.set("i", ";l", "[]()<Left><Left><Left>", {buffer = true})
    vim.keymap.set("i", ";w", "[[]]<Left><Left>", {buffer = true})
    
    -- Add mapping to format current paragraph
    vim.keymap.set("n", "<leader>gq", "gqip", {buffer = true})
  end,
})

-- Template for new markdown files
autocmd("BufNewFile", {
  pattern = "*.md",
  callback = function()
    if vim.g.markdown_template_applied == 0 then
      apply_template("skeleton.md")
    end
  end,
})

-- Simple status line (minimal)
vim.opt.statusline = "%f %m%r%h%w%=%l,%c %P"

-- Console-specific optimizations for highlighting
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- Ensure good contrast in console environment
    vim.cmd([[
      highlight Normal ctermbg=NONE ctermfg=white
      highlight NonText ctermbg=NONE
      highlight LineNr ctermfg=gray
      highlight StatusLine ctermfg=white ctermbg=blue
      highlight StatusLineNC ctermfg=gray ctermbg=black
      highlight VertSplit ctermfg=gray ctermbg=black
      
      " Markdown-specific highlights
      highlight markdownHeadingDelimiter ctermfg=yellow cterm=bold
      highlight markdownH1 ctermfg=yellow cterm=bold
      highlight markdownH2 ctermfg=yellow
      highlight markdownH3 ctermfg=yellow
      highlight markdownLinkText ctermfg=cyan
      highlight markdownUrl ctermfg=blue
      highlight markdownCode ctermfg=green
      highlight markdownCodeBlock ctermfg=green
      highlight markdownBlockquote ctermfg=magenta
    ]])
  end
})

-- Define custom colors specifically for 16-color terminals
vim.cmd([[
  " Base console colorscheme tweaks for 16 color terminals
  highlight Normal ctermbg=NONE ctermfg=white
  highlight NonText ctermbg=NONE
  highlight LineNr ctermfg=gray
  highlight StatusLine ctermfg=white ctermbg=blue
  highlight StatusLineNC ctermfg=gray ctermbg=black
  highlight VertSplit ctermfg=gray ctermbg=black
  
  " Markdown-specific highlights
  highlight markdownHeadingDelimiter ctermfg=yellow cterm=bold
  highlight markdownH1 ctermfg=yellow cterm=bold
  highlight markdownH2 ctermfg=yellow
  highlight markdownH3 ctermfg=yellow
  highlight markdownLinkText ctermfg=cyan
  highlight markdownUrl ctermfg=blue
  highlight markdownCode ctermfg=green
  highlight markdownCodeBlock ctermfg=green
  highlight markdownBlockquote ctermfg=magenta
]])

-- Load Zettelkasten features
local ok1, zettelkasten = pcall(require, 'zettelkasten')
if not ok1 then
  vim.notify("Could not load zettelkasten module", vim.log.levels.WARN)
end

-- Load AI enhancement features
local ok2, ai_enhance = pcall(require, 'ai_enhance')
if not ok2 then
  vim.notify("Could not load ai_enhance module", vim.log.levels.WARN)
end

print("Minimal Neovim configuration loaded for Raspberry Pi Zero 2W")
