---- utilities ----

local function with(fn, args)
  return function() fn(unpack(args)) end
end

local function command(...)
  local out = vim.fn.system(...)
  return out:gsub("%s*$", ""), vim.v.shell_error
end

local function disable_text_edit_ui()
  vim.opt_local.cursorline = false
  vim.opt_local.number = false
  vim.opt_local.list = false
end

local function on_term_open()
  disable_text_edit_ui()
  vim.opt_local.winbar = nil
end

local function file_exists(filename)
  local fd = io.open(filename)
  if fd ~= nil then
    io.close(fd)
    return true
  else
    return false
  end
end

local border_style = "single"

local function float_window(winid, opts)
  opts = opts or {}
  local ui = vim.api.nvim_list_uis()[1]
  local win_width = opts.width or math.floor(ui.width / 1.5)
  local win_height = opts.height or math.floor(ui.height / 1.5)
  opts = vim.tbl_deep_extend("force", {
    relative = "editor",
    width = win_width,
    height = win_height,
    col = (ui.width / 2) - (win_width / 2),
    row = (ui.height / 2) - (win_height / 2),
    border = border_style,
  }, opts)
  local float = vim.api.nvim_open_win(vim.api.nvim_win_get_buf(winid), 1, opts)
  vim.api.nvim_win_close(winid, true)
  vim.cmd.wincmd("=")
  return float
end

local function list_flatmap(func, list)
  vim.validate { func = { func, "c" }, list = { list, "t" } }
  local rettab = {}
  for _, v in ipairs(list) do
    local mapped = func(v)
    if mapped then
      if type(mapped) == "table" then
        for _, e in ipairs(mapped) do
          table.insert(rettab, e)
        end
      else
        table.insert(rettab, mapped)
      end
    end
  end
  return rettab
end

local function set_local_tab_width(width)
  vim.opt_local.shiftwidth = width
  vim.opt_local.softtabstop = width
end

local function map(mode, lhs, rhs, desc, opts)
  local merged_opts = vim.tbl_deep_extend(
    "force",
    { noremap = true, silent = true, desc = desc },
    opts or {}
  )
  vim.keymap.set(mode, lhs, rhs, merged_opts)
end

local function nmap(lhs, rhs, desc, opts) map("n", lhs, rhs, desc, opts) end
local function vmap(lhs, rhs, desc, opts) map("v", lhs, rhs, desc, opts) end

local function in_git_repo()
  local _, stat = command { "git", "rev-parse", "--is-inside-work-tree" }
  return stat == 0
end

local function git_main_branch()
  if in_git_repo() then
    local out, _ = command "git branch | cut -c 3- | grep -E '^master$|^main$'"
    return out
  end
end

local function git_modified_files()
  if in_git_repo() then
    local out, _ = command { "git", "diff", "--name-only" }
    if out then
      return list_flatmap(
        function(f)
          if f ~= "" then
            return f
          end
        end,
        vim.split(out, "\n")
      )
    end
  end
  return {}
end

---- plugins ----

local plugins = {
  {
    "tinted-theming/tinted-vim",
    lazy = false,
  },
  {
    "kevinhwang91/nvim-ufo",
    event = "BufReadPost",
    dependencies = { "kevinhwang91/promise-async" }
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre"
  },
  {
    "mrjones2014/smart-splits.nvim",
    tag = "v1.3.0",
    event = "VeryLazy"
  },
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre"
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy"
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
  },
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-telescope/telescope-ui-select.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }
    }
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = function(_) vim.cmd.TSUpdate() end,
    event = "BufReadPost"
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost"
  },
  {
    "romainl/vim-qf",
    event = "VeryLazy"
  },
  {
    "ruifm/gitlinker.nvim",
    event = "VeryLazy"
  },
  {
    "scalameta/nvim-metals",
    ft = { "scala", "sbt" }
  },
  {
    "tamago324/lir.nvim",
  },
  {
    "tpope/vim-eunuch",
    cmd = { "Remove", "Delete", "Move", "Chmod", "Mkdir", "Rename", "SudoWrite" }
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" }
  },
  { "tpope/vim-repeat" },
  { "tpope/vim-rsi" },
  { "tpope/vim-surround" },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "samjwill/nvim-unception",
    event = "VeryLazy"
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "BufReadPre",
    opts = {},
  },
}

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(plugins, {
  lockfile = vim.env.NVIM_LOCKFILE or vim.fn.stdpath("config") .. "/lazy-lock.json",
  ui = {
    icons = {
      cmd = "",
      config = "",
      event = "",
      ft = "",
      init = "",
      keys = "",
      plugin = "",
      runtime = "",
      source = "",
      start = "",
      task = "",
      lazy = " ",
    },
  },
})

---- configuration ----

vim.opt.termguicolors = true
vim.opt.background = "dark"

local colorschemes = {
  "base16-rose-pine-dawn",
  "base16-shadesmear-light",
  "base16-terracotta",
  "base16-black-metal-burzum",
}

local current_colorscheme = 1
vim.cmd.colorscheme(colorschemes[1])

local function increment_colorscheme()
  current_colorscheme = current_colorscheme % #colorschemes + 1
  vim.cmd.colorscheme(colorschemes[current_colorscheme])
end

local function decrement_colorscheme()
  current_colorscheme = (current_colorscheme - 2) % #colorschemes + 1
  vim.cmd.colorscheme(colorschemes[current_colorscheme])
end

nmap("[C", decrement_colorscheme, "cycle colorscheme (previous)")
nmap("]C", increment_colorscheme, "cycle colorscheme (next)")

local init_augroup = vim.api.nvim_create_augroup("InitLua", { clear = true })

vim.g.mapleader = " "

vim.o.cmdheight = 1
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.foldcolumn = "0"
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.hidden = true
vim.o.ignorecase = false
vim.o.linebreak = true
vim.o.list = true
vim.o.mouse = "a"
vim.o.number = true
vim.o.scrolloff = 10
vim.o.shiftwidth = 4
vim.o.shortmess = "acFItosTW"
vim.o.showmode = false
vim.o.signcolumn = "auto"
vim.o.smartcase = true
vim.o.smarttab = true
vim.o.softtabstop = 4
vim.o.spelllang = "en_us"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.timeoutlen = 2000
vim.o.updatetime = 250
vim.o.wrap = false
vim.opt.listchars:append "nbsp:⋅"
vim.opt.listchars:append "tab:» "
vim.opt.listchars:append "trail:⋅"

if vim.fn.has "nvim-0.9" == 1 then
  vim.o.diffopt = "linematch:60"
  vim.o.exrc = true
end

local ft_overrides = {
  lua = with(set_local_tab_width, { 2 }),
  nix = with(set_local_tab_width, { 2 }),
  scala = with(set_local_tab_width, { 2 }),
  text = function() vim.opt_local.wrap = true end,
  markdown = function() vim.opt_local.wrap = true end,
  fugitive = disable_text_edit_ui,
  git = disable_text_edit_ui,
  lir = disable_text_edit_ui,
}

for ft, cfg in pairs(ft_overrides) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = ft,
    group = init_augroup,
    callback = cfg,
  })
end

nmap("<leader>L", vim.cmd.Lazy, "Manage plugins")

nmap("<esc>", "<cmd>noh|lclose|cclose<cr>")
map({ "n", "v" }, "H", "0")
map({ "n", "v" }, "L", "$")
nmap("<leader>y", "")
map("x", "<leader>p", [["_dP]])
map({ "n", "v" }, "<leader>y", [["+y]])
map({ "n", "v" }, "<leader>Y", [["+Y]])
nmap("J", "mzJ`z")
nmap("n", "nzz")
nmap("N", "Nzz")
nmap("<C-o>", "<C-o>zz")
nmap("<C-i>", "<C-i>zz")
nmap("gg", "ggzz")
nmap("G", "Gzz")
nmap("<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left><Left>]])

nmap(
  "<leader>ow",
  function() vim.opt_local.wrap = not vim.opt_local.wrap:get() end,
  "Toggle line wrap"
)

nmap("<leader>ov", function()
  if vim.tbl_contains(vim.opt_local.virtualedit:get(), "all") then
    vim.opt_local.virtualedit:remove "all"
  else
    vim.opt_local.virtualedit:append "all"
  end
end, "Toggle virtual editing")

for _, cmd in ipairs({
  "Q!",
  "Q",
  "QA!",
  "QA",
  "Qa!",
  "Qa",
  "W",
  "WA!",
  "WA",
  "WQ!",
  "WQ",
  "WQa!",
  "WQa",
  "Wa!",
  "Wa",
  "Wq!",
  "Wq",
  "WqA!",
  "WqA",
  "Wqa!",
  "Wqa",
  "qA!",
  "qA!",
  "qA",
  "wA!",
  "wA",
  "wQ!",
  "wQ",
  "wQA!",
  "wQA",
  "wQa!",
  "wQa",
  "wqA!",
  "wqA",
}) do
  vim.cmd.cnoreabbrev(cmd, cmd:lower())
end

if vim.fn.has "gui_running" > 0 then
  vim.o.guifont = "JetBrains Mono:h9"
end

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = init_augroup,
  callback = function(ctx)
    local dir = vim.fn.fnamemodify(ctx.file, ":p:h")
    vim.fn.mkdir(dir, "p")
  end,
})

vim.api.nvim_create_autocmd("BufReadPre", {
  group = init_augroup,
  callback = function(args)
    local size = vim.fn.getfsize(args.file)
    -- 1MB = 1024 * 1024
    local max_size = 1024 * 1024

    if size > max_size then
      vim.opt_local.undofile = false
      vim.opt_local.swapfile = false
      vim.opt_local.backup = false
      vim.opt_local.writebackup = false
      vim.opt_local.eventignore:append({ "FileType", "CursorHold", "CursorHoldI", "TextChanged", "TextChangedI" })
      vim.opt_local.bufhidden = "unload"
      vim.opt_local.buftype = "nowrite"
      vim.opt_local.syntax = ""
      vim.opt_local.foldenable = false
    end
  end,
})

nmap("<Backspace>", "<C-6>")
nmap("]b", "<cmd>bnext<cr>", "Next buffer")
nmap("[b", "<cmd>bprev<cr>", "Previous buffer")

local function buf_delete_keep_win()
  local curr = vim.api.nvim_get_current_buf()
  local alt = vim.fn.expand "#"
  if alt and alt ~= "" then
    vim.cmd "b#"
  else
    vim.cmd.bprev()
  end
  vim.api.nvim_buf_delete(curr, { force = true, unload = false })
end

nmap("<leader>bd", buf_delete_keep_win, "Delete buffer (keep window)")
nmap("<leader>bD", "<cmd>bdelete!<cr>", "Delete buffer")
nmap("<leader>bw", "<cmd>bwipeout!<cr>", "Wipeout buffer")
nmap("<leader>bn", "<cmd>new<cr>", "New buffer")
nmap("<leader>bs", function()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.cmd.split()
  vim.api.nvim_win_set_buf(0, bufnr)
end, "Open scratch file")

vim.api.nvim_create_autocmd("BufEnter", {
  group = init_augroup,
  callback = function()
    if vim.bo.buftype == "nofile" then disable_text_edit_ui() end
  end,
})

vim.api.nvim_create_autocmd({ "VimResized", "VimResume" }, {
  group = init_augroup,
  callback = function() vim.cmd.wincmd "=" end,
})

vim.api.nvim_create_user_command("Filter", function(opts)
  if vim.bo.buftype ~= "" then
    vim.notify("Not a file", vim.log.levels.ERROR)
    return
  end
  vim.cmd(string.format("%%!%s", opts.args))
end, { nargs = "+", complete = "shellcmd" })

vim.api.nvim_create_user_command("HexDump", function(_)
  if vim.bo.buftype ~= "" then
    vim.notify("Not a file", vim.log.levels.ERROR)
    return
  end
  local path = vim.api.nvim_buf_get_name(0)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd(string.format("r !xxd %s", path))
    vim.bo[bufnr].ft = "xxd"
    vim.bo[bufnr].modifiable = false
  end)
  vim.cmd.split()
  vim.api.nvim_win_set_buf(0, bufnr)
end, { nargs = 0 })

if vim.fn.executable "rg" == 1 then
  vim.o.grepprg = [[rg --vimgrep --no-heading]]
  vim.o.grepformat = [[%f:%l:%c:%m,%f:%l:%m]]
end

nmap(
  "<leader>*",
  function() vim.cmd(string.format([[grep '\b%s\b']], vim.fn.expand "<cword>")) end,
  "Grep word under cursor"
)

nmap(
  "<leader>/",
  function()
    require("telescope.builtin").live_grep {
      previewer = false,
      additional_args = { "-L" },
    }
  end,
  "Live grep"
)

nmap(
  "[d",
  with(vim.diagnostic.goto_prev, { { float = { border = border_style } } }),
  "Previous diagnostic"
)

nmap(
  "]d",
  with(vim.diagnostic.goto_next, { { float = { border = border_style } } }),
  "Next diagnostic"
)

nmap(
  "[e",
  with(vim.diagnostic.goto_prev, { { float = { border = border_style } } }),
  "Previous diagnostic"
)

nmap(
  "[e",
  with(
    vim.diagnostic.goto_prev,
    {
      {
        float = { border = border_style },
        severity = vim.diagnostic.severity.ERROR,
      },
    }
  ),
  "Next diagnostic"
)

nmap(
  "]e",
  with(
    vim.diagnostic.goto_next,
    {
      {
        float = { border = border_style },
        severity = vim.diagnostic.severity.ERROR,
      },
    }
  ),
  "Next diagnostic"
)

nmap("<leader>dc", vim.diagnostic.setqflist, "Diagnostics in quickfix list")
nmap(
  "<leader>df",
  with(require("telescope.builtin").diagnostics, { { previewer = false } }),
  "Find diagnostics"
)

vim.diagnostic.config {
  underline = true,
  virtual_text = false,
  severity_sort = true,
}

nmap(
  "<M-i>",
  function()
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = {
        "BufLeave",
        "CursorMoved",
        "InsertEnter",
        "FocusLost",
      },
      border = border_style,
      source = "always",
      scope = "cursor",
    })
  end,
  "Show diagnostic"
)

for _, type in ipairs { "Error", "Warn", "Hint", "Info" } do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = "", texthl = hl, numhl = hl })
end

vim.api.nvim_create_autocmd("BufReadPost", {
  group = init_augroup,
  callback = function()
    if vim.bo.filetype ~= "gitcommit" then
      local cursor_mark = vim.fn.line [['"]]
      if cursor_mark > 1 and cursor_mark <= vim.fn.line [[$]] then
        vim.cmd [[normal! g`"]]
      end
    end
  end,
})

vim.o.scrollback = 100000

map("t", "<C-[>", [[<C-\><C-n>]])
map("t", "<esc>", [[<C-\><C-n>]])
map("t", "<M-[>", "<esc>")

local cfg_shell = vim.env.NVIM_SHELL or ""

nmap(
  "<leader>tn",
  string.format("<cmd>terminal %s<cr>", cfg_shell),
  "New terminal"
)
nmap(
  "<leader>ts",
  string.format("<cmd>split|terminal %s<cr>", cfg_shell),
  "New terminal in split"
)
nmap(
  "<leader>tv",
  string.format("<cmd>vsplit|terminal %s<cr>", cfg_shell),
  "New terminal in vsplit"
)
nmap(
  "<leader>tt",
  string.format("<cmd>tabnew|terminal %s<cr>", cfg_shell),
  "New terminal in a tab"
)

vim.api.nvim_create_autocmd("TermOpen", {
  group = init_augroup,
  callback = on_term_open,
})

local function update_tmux_env()
  if not vim.env.TMUX then return end
  for _, line in
  pairs(vim.split(vim.fn.system { "tmux", "show-environment" }, "\n"))
  do
    local _, _, k, v = line:find "(.*)=(.*)"
    if k and v then vim.env[k] = v end
  end
end

vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  group = init_augroup,
  callback = update_tmux_env,
})


local function trim_trailing_whitespace()
  vim.cmd [[%s/\s\+$//e]]
end

vim.api.nvim_create_user_command("TrimWhitespace", trim_trailing_whitespace, { nargs = 0 })

local auto_trim_trailing_whitespace_enable = true

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    if auto_trim_trailing_whitespace_enable then
      trim_trailing_whitespace()
    end
  end,
})

vim.api.nvim_create_user_command(
  "AutoTrimWhitespaceEnable",
  function() auto_trim_trailing_whitespace_enable = true end,
  { nargs = 0 }
)

vim.api.nvim_create_user_command(
  "AutoTrimWhitespaceDisable",
  function() auto_trim_trailing_whitespace_enable = false end,
  { nargs = 0 }
)

vim.o.backup = false
vim.o.swapfile = false
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath "data" .. "/undodir"

if not vim.fn.isdirectory(vim.o.undodir) then
  vim.fn.mkdir(vim.o.undodir, 0700)
end

nmap("<C-w>t", "<cmd>tab split<cr>", "New tab")
nmap("]t", "<cmd>tabnext<cr>", "Next tab")
nmap("[t", "<cmd>tabprev<cr>", "Previous tab")
nmap("]T", "<cmd>tabmove +1<cr>", "Next tab")
nmap("[T", "<cmd>tabmove -1<cr>", "Previous tab")

for i = 0, 10 do
  nmap(string.format("<M-%d>", i), string.format("%dgt", i))
end

nmap("<C-q>", "<cmd>quit<cr>", "Close window")
nmap("<leader>Q", "<cmd>quitall<cr>", "Close all windows")

local function lsp_on_attach(client, bufnr)
  nmap(
    "<F2>",
    vim.lsp.buf.rename,
    "LSP: rename symbol under cursor",
    { buffer = bufnr }
  )
  nmap("K", vim.lsp.buf.hover, "LSP: hover actions", { buffer = bufnr })
  nmap("<C-c>", vim.lsp.buf.code_action, "LSP: code action", { buffer = bufnr })
  map({ "i", "n" }, "<C-s>", vim.lsp.buf.signature_help, "LSP: signature_help", { buffer = bufnr })

  nmap(
    "gd",
    require("telescope.builtin").lsp_definitions,
    "LSP: go to definition",
    { buffer = bufnr }
  )
  nmap(
    "gD",
    require("telescope.builtin").lsp_type_definitions,
    "LSP: go to type definition",
    { buffer = bufnr }
  )
  nmap("gr", require("telescope.builtin").lsp_references, "LSP: find references", { buffer = bufnr })
  nmap(
    "gI",
    require("telescope.builtin").lsp_implementations,
    "LSP: find implementations",
    { buffer = bufnr }
  )

  nmap(
    "gs",
    with(
      require("telescope.builtin").lsp_document_symbols,
      { { previewer = false, symbol_width = 60 } }
    ),
    "LSP: find document symbols",
    { buffer = bufnr }
  )

  nmap(
    "gS",
    with(
      require("telescope.builtin").lsp_dynamic_workspace_symbols,
      { { previewer = false } }
    ),
    "LSP: find workspace symbols",
    { buffer = bufnr }
  )

  vim.lsp.handlers["textDocument/hover"] =
      vim.lsp.with(vim.lsp.handlers.hover, { border = border_style })
  vim.lsp.handlers["textDocument/signatureHelp"] =
      vim.lsp.with(vim.lsp.handlers.signature_help, { border = border_style })

  local function fmt()
    vim.lsp.buf.format {
      async = false,
      id = client.id,
      bufnr = bufnr,
      timeout_ms = 10000,
    }
  end

  vim.api.nvim_buf_create_user_command(0, "LspFormat", fmt, { nargs = 0 })
  nmap("<leader>bf", fmt, "Format buffer", { buffer = bufnr })
end

local function mkline(sections, opts)
  opts = opts or {}
  return function(e)
    local l = table.concat(
      list_flatmap(function(section)
        return table.concat(
          list_flatmap(function(c)
            if type(c) == "function" then
              return c(e)
            end
            return c
          end, section),
          opts.separator or "  "
        )
      end, sections),
      "%="
    )
    return (opts.line_formatter or function(i) return i end)(l)
  end
end

local function component_diagnostics(winnr)
  local function count_diag(severity)
    return vim.tbl_count(vim.diagnostic.get(vim.api.nvim_win_get_buf(winnr), {
      severity = severity,
    }))
  end

  local errors = count_diag(vim.diagnostic.severity.ERROR)
  local warnings = count_diag(vim.diagnostic.severity.WARN)
  local sections = {}
  if errors > 0 then table.insert(sections, string.format("E:%d", errors)) end
  if warnings > 0 then
    table.insert(sections, string.format("W:%d", warnings))
  end
  if #sections > 0 then return table.concat(sections, ", ") end
end

local function component_git_head(_)
  local head = vim.g.gitsigns_head
  if head and head ~= "" then return head end
end

local function component_cwd(_) return vim.fn.getcwd() end

local function component_metals(_)
  local status = vim.g["metals_status"]
  if status and status ~= "" then return status end
end

STATUSLINE = mkline({
  {
    component_cwd,
  },
  {},
  {
    component_metals,
    component_git_head,
  },
})

WINBAR = mkline({
  {
    "%f %M%R%H%W",
    component_diagnostics,
  },
  {
    "%l,%c %p%%",
  },
})

vim.o.statusline = "%!luaeval('STATUSLINE(vim.g.statusline_winid)')"

vim.api.nvim_create_autocmd({ "VimEnter", "BufWinEnter" }, {
  group = init_augroup,
  callback = function()
    if vim.tbl_contains({ "", "nowrite" }, vim.bo.buftype) or vim.bo.filetype == "lir" then
      vim.opt_local.winbar = "%!luaeval('WINBAR(vim.g.statusline_winid)')"
    end
  end,
})

vim.o.laststatus = 3

vim.o.completeopt = "menu,menuone,noselect"

require("Comment").setup {
  toggler = {
    line = "gcc",
    block = "gCC",
  },
  opleader = {
    line = "gc",
    block = "gC",
  },
  mappings = {
    basic = true,
    extra = true,
  },
}

nmap(
  "<leader>f",
  with(
    require("telescope.builtin").find_files,
    { { follow = true, previewer = false } }
  ),
  "Find files"
)

nmap("<leader>go", function()
  vim.tbl_map(function(e) vim.cmd("edit " .. e) end, git_modified_files())
end, "Git: open modified files")

nmap(
  "<leader>gf",
  require("telescope.builtin").git_status,
  "Git: changed files"
)

nmap("<leader>gg", function()
  vim.cmd.Git()
  local float = float_window(vim.api.nvim_get_current_win())
  vim.api.nvim_create_autocmd("WinLeave", {
    once = true,
    group = init_augroup,
    callback = function()
      vim.api.nvim_win_close(float, true)
    end
  })
end, "Git: status")

nmap("<leader>gL", "<cmd>Git log -- %<cr>", "Git: log file")
nmap("<leader>gl", "<cmd>Git log<cr>", "Git: log")

nmap("<leader>gcc", "<cmd>Git commit<cr>", "Git: create commit")
nmap("<leader>gca", "<cmd>Git commit --amend<cr>", "Git: amend commit")
nmap(
  "<leader>gcL",
  require("telescope.builtin").git_bcommits,
  "Git: show commits for buffer"
)
nmap(
  "<leader>gcl",
  require("telescope.builtin").git_commits,
  "Git: show commits"
)

nmap(
  "<leader>gsm",
  function() return string.format("<cmd>Git switch %s<cr>", git_main_branch()) end,
  "Git: switch to main/master branch",
  { expr = true }
)

nmap("<leader>gss", require("telescope.builtin").git_branches, "Git: switch")
nmap("<leader>gs-", "<cmd>Git switch -<cr>", "Git: switch back")
nmap("<leader>gsc", function()
  vim.ui.input(
    { prompt = "New branch: " },
    function(input) vim.cmd(string.format("Git switch -c '%s'", input)) end
  )
end, "Git: switch to new branch")

nmap(
  "<leader>gSa",
  require("telescope.builtin").git_stash,
  "Git: select and apply stash"
)
nmap("<leader>gSs", "<cmd>Git stash save<cr>", "Git: save stash")
nmap("<leader>gSp", "<cmd>Git stash pop<cr>", "Git: pop stash")

nmap("<leader>gF", "<cmd>Git fetch<cr>", "Git: fetch")

nmap("<leader>gpp", "<cmd>Git push<cr>", "Git: push")
nmap(
  "<leader>gpf",
  "<cmd>Git push --force-with-lease<cr>",
  "Git: force push with lease"
)

nmap("<leader>gP", "<cmd>Git pull<cr>", "Git: pull")

require("gitsigns").setup {
  preview_config = {
    border = border_style,
  },
  on_attach = function(_)
    local gs = package.loaded.gitsigns

    nmap("<leader>gha", gs.stage_hunk, "Git: stage hunk")
    nmap("<leader>ghu", gs.undo_stage_hunk, "Git: undo stage hunk")
    nmap("<leader>ghr", gs.reset_hunk, "Git: restore hunk")
    vmap(
      "<leader>ga",
      function() gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
      "Git: stage visual selection"
    )

    vmap(
      "<leader>gr",
      function() gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
      "Git: restore visual selection"
    )
    nmap("<leader>gb", gs.blame_line, "Git: show line blame")

    nmap("<leader>ghp", gs.preview_hunk, "Git: preview hunk")
    nmap(
      "<leader>ghd",
      gs.toggle_deleted,
      "Git: toggle visibility of deleted hunks"
    )

    nmap(
      "<leader>ghc",
      function() gs.setqflist "all" end,
      "Git: load hunks into quickfix list"
    )

    nmap("<leader>gr", gs.reset_buffer, "Git: restore buffer")
    nmap("<leader>gu", gs.reset_buffer_index, "Git: unstage buffer")
    nmap("<leader>ga", gs.stage_buffer, "Git: stage buffer")

    nmap("<leader>gvp", function() gs.show "HEAD" end, "Git: open HEAD")

    nmap(
      "<leader>gvm",
      function() gs.show("origin/" .. git_main_branch()) end,
      "Git: open file on main/master branch"
    )

    nmap("<leader>gvr", function()
      vim.ui.input({ prompt = "Git ref: " }, function(ref)
        if ref ~= nil and ref ~= "" then
          local cmd = "Gitsigns show " .. ref
          vim.cmd(cmd)
          vim.fn.histadd("cmd", cmd)
        end
      end)
    end, "Git: view specific ref")

    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>")
    map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<cr>")

    nmap("]h", function()
      if vim.wo.diff then return "]c" end
      vim.schedule(function() gs.next_hunk() end)
      return "<Ignore>"
    end, "Git: next hunk", { expr = true })

    nmap("[h", function()
      if vim.wo.diff then return "[c" end
      vim.schedule(function() gs.prev_hunk() end)
      return "<Ignore>"
    end, "Git: previous hunk", { expr = true })

    nmap("<leader>gdd", function() gs.diffthis() end, "Git: diff against index")

    nmap(
      "<leader>gdp",
      function() gs.diffthis "HEAD~" end,
      "Git: diff against parent commit"
    )

    nmap(
      "<leader>gdm",
      function() gs.diffthis("origin/" .. git_main_branch()) end,
      "Git: diff against main/master branch"
    )

    nmap("<leader>gdr", function()
      vim.ui.input({ prompt = "Git ref: " }, function(ref)
        if ref ~= nil and ref ~= "" then
          local cmd = "Gitsigns diffthis " .. ref
          vim.cmd(cmd)
          vim.fn.histadd("cmd", cmd)
        end
      end)
    end, "Git: diff working-tree against specified ref")
  end,
}

require("gitlinker").setup { mappings = nil }

for _, mode in ipairs { "n", "v" } do
  map(
    mode,
    "<leader>gy",
    function()
      require("gitlinker").get_buf_range_url(mode, {
        action_callback = require("gitlinker.actions").copy_to_clipboard,
      })
    end,
    "Copy GitHub permalink to clipboard"
  )
end

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

nmap("<leader>e", "<cmd>edit .<cr>", "Browse files")
nmap("<leader>E", require("lir.float").init, "Browse files in float")
nmap("<C-w>e", "<cmd>split|edit .<cr>", "Browse files in a split")

nmap("-", function()
  if vim.bo.buftype == "terminal" then
    return "<cmd>edit .<cr>"
  else
    return "<cmd>edit %:p:h<cr>"
  end
end, "Browse files here", { expr = true })

nmap("<C-w>-", function()
  if vim.bo.buftype == "terminal" then
    return "<cmd>split|edit .<cr>"
  else
    return "<cmd>split|edit %:p:h<cr>"
  end
end, "Browse files here in a split", { expr = true })

require("lir").setup {
  show_hidden_files = true,
  devicons_enable = false,
  mappings = {
    ["cd"] = require("lir.actions").cd,
    ["<C-x>"] = require("lir.actions").split,
    ["<C-v>"] = require("lir.actions").vsplit,
    ["<C-t>"] = require("lir.actions").tabedit,
    ["h"] = require("lir.actions").up,
    ["l"] = require("lir.actions").edit,
    ["H"] = with(vim.cmd, { "edit ." }),
    ["~"] = with(vim.cmd, { "edit " .. vim.env.HOME }),
    ["-"] = require("lir.actions").up,
    ["q"] = require("lir.actions").quit,
    ["%"] = require("lir.actions").newfile,
    ["d"] = require("lir.actions").mkdir,
    ["r"] = require("lir.actions").rename,
    ["R"] = require("lir.actions").rename,
    ["<cr>"] = require("lir.actions").edit,
    ["Y"] = require("lir.actions").yank_path,
    ["."] = require("lir.actions").toggle_show_hidden,
    ["D"] = require("lir.actions").delete,
    ["y"] = require("lir.clipboard.actions").copy,
    ["x"] = require("lir.clipboard.actions").cut,
    ["p"] = require("lir.clipboard.actions").paste,
    ["<leader>f"] = function()
      require("telescope.builtin").find_files {
        cwd = require("lir").get_context().dir,
        follow = true,
        previewer = false,
      }
    end,
    ["<leader>/"] = function()
      require("telescope.builtin").live_grep {
        cwd = require("lir").get_context().dir,
        additional_args = { "-L" },
      }
    end,
    ["m"] = require("lir.mark.actions").toggle_mark,
    ["<Tab>"] = function()
      require("lir.mark.actions").toggle_mark()
      vim.cmd "normal! j"
    end,
    ["<S-Tab>"] = require("lir.mark.actions").toggle_mark,
  },
  float = {
    winblend = 0,
    curdir_window = {
      enable = false,
      highlight_dirname = false,
    },
  },
  hide_cursor = false,
}

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

local lsp_config = {
  on_attach = lsp_on_attach,
  flags = {
    debounce_text_changes = 1000,
  },
  capabilities = lsp_capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      runtime = {
        version = "LuaJIT",
        path = vim.split(package.path, ";"),
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
        },
      },
    },
  },
}

local lsp_servers = { "lua_ls", "clangd", "pyright", "rust_analyzer" }
for _, lsp in ipairs(lsp_servers) do
  require("lspconfig")[lsp].setup(lsp_config)
end

local metals_config =
    vim.tbl_deep_extend("force", require("metals").bare_config(), {
      on_attach = function(client, bufnr)
        lsp_on_attach(client, bufnr)
        nmap(
          "<leader>ms",
          "<cmd>MetalsGotoSuperMethod<cr>",
          "Go to super-method",
          { buffer = bufnr }
        )
        nmap(
          "<leader>mS",
          "<cmd>MetalsSuperMethodHierarchy<cr>",
          "Super-method hierarchy",
          { buffer = bufnr }
        )
        nmap(
          "<leader>mb",
          "<cmd>MetalsSwitchBsp<cr>",
          "Switch BSP",
          { buffer = bufnr }
        )
        nmap(
          "<leader>mr",
          "<cmd>MetalsRestartServer<cr>",
          "Restart server",
          { buffer = bufnr }
        )
        nmap(
          "<leader>mc",
          "<cmd>MetalsCompileCancel<cr>",
          "Cancel compilation",
          { buffer = bufnr }
        )
      end,
      settings = {
        superMethodLensesEnabled = false,
      },
      init_options = {
        statusBarProvider = "on",
      },
    })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt", "java" },
  callback = with(require("metals").initialize_or_attach, metals_config),
  group = init_augroup,
})

nmap("]q", "<Plug>(qf_qf_next)", "Next in quickfix list")
nmap("[q", "<Plug>(qf_qf_previous)", "Previous in quickfix list")
nmap("[Q", "<cmd>cfirst<cr>", "First in quickfix list")
nmap("]Q", "<cmd>clast<cr>", "Last in quickfix list")
nmap("<leader>c", "<Plug>(qf_qf_toggle)", "Toggle quickfix window")

nmap("]l", "<Plug>(qf_loc_next)", "Next in loclist")
nmap("[l", "<Plug>(qf_loc_previous)", "Previous in loclist")
nmap("[L", "<cmd>lfirst<cr>", "First in loclist")
nmap("]L", "<cmd>llast<cr>", "Last in loclist")
nmap("<leader>l", "<Plug>(qf_loc_toggle)", "Toggle loclist window")

require("telescope").setup {
  defaults = require("telescope.themes").get_ivy {
    mappings = {
      i = { ["<esc>"] = require("telescope.actions").close },
    },
    file_ignore_patterns = {
      ".git/",
      "%.pdf",
      "%.zip",
      "%.png",
      "%.svg",
      "%.jpg",
      "%.tar",
      "%.gz",
    },
    path_display = { truncate = 2 },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_ivy(),
    },
  },
}

require("telescope").load_extension "fzf"
require("telescope").load_extension "ui-select"

nmap("<F1>", require("telescope.builtin").help_tags, "Help tags")
nmap(
  "<leader><C-r>",
  require("telescope.builtin").command_history,
  "Command history"
)

nmap(
  "<leader>F",
  with(
    require("telescope.builtin").current_buffer_fuzzy_find,
    { { previewer = false, skip_empty_lines = true } }
  ),
  "Fuzzy search in buffer"
)

nmap("<C-p>", function()
  local mappings = vim.tbl_extend(
    "force",
    vim.api.nvim_get_keymap "n",
    vim.api.nvim_buf_get_keymap(0, "n")
  )
  local shown = {}
  for _, m in ipairs(mappings) do
    if m.desc then shown[m.lhs] = true end
  end
  require("telescope.builtin").keymaps {
    lhs_filter = function(m) return shown[m] end,
  }
end)

nmap(
  "<leader>bb",
  with(require("telescope.builtin").buffers, {
    {
      previewer = false,
      ignore_current_buffer = true,
      attach_mappings = function(_, m)
        m("i", "<C-q>", require("telescope.actions").delete_buffer)
        return true
      end,
    },
  }),
  "Open buffer"
)

local function buffer_has_large_file(bufnr)
  local is_large = vim.api.nvim_buf_line_count(bufnr) > tonumber(vim.env.NVIM_TREESITTER_MAX_SIZE or 100000)
  local is_fir_file = vim.fn.expand "%:e" == "fir"
  return is_large or is_fir_file
end

require("nvim-treesitter.configs").setup {
  auto_install = vim.fn.executable "tree-sitter" == 1,
  highlight = {
    enable = true,
    disable = function(_, bufnr) return buffer_has_large_file(bufnr) end
  },
  textobjects = {
    enable = true,
    disable = function(_, bufnr) return buffer_has_large_file(bufnr) end,
    lookahead = true,
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
      selection_modes = {
        ["@function.outer"] = "V",
      },
    },
  },
  incremental_selection = {
    enable = true,
    disable = function(_, bufnr) return buffer_has_large_file(bufnr) end,
    keymaps = {
      init_selection = "gn",
      node_incremental = "<C-i>",
      node_decremental = "<C-o>",
    },
  },
  playground = {
    enable = true,
  },
}

vim.api.nvim_create_autocmd("BufRead", {
  callback = function()
    if buffer_has_large_file(0) then vim.cmd.TSContextDisable() end
  end,
})

require("treesitter-context").setup { enable = true }

nmap("<leader>oc", vim.cmd.TSContextToggle)

nmap("zR", require("ufo").openAllFolds, "Open all folds")
nmap("zM", require("ufo").closeAllFolds, "Close all folds")

require("ufo").setup {
  provider_selector = function(_, _, _) return { "treesitter", "indent" } end,
}

require("smart-splits").setup()

for _, fmt in ipairs { "<C-w>%s", "<C-%s>" } do
  nmap(string.format(fmt, "h"), require("smart-splits").move_cursor_left)
  nmap(string.format(fmt, "l"), require("smart-splits").move_cursor_right)
  nmap(string.format(fmt, "j"), require("smart-splits").move_cursor_down)
  nmap(string.format(fmt, "k"), require("smart-splits").move_cursor_up)
end

nmap("<M-h>", require("smart-splits").resize_left)
nmap("<M-j>", require("smart-splits").resize_down)
nmap("<M-k>", require("smart-splits").resize_up)
nmap("<M-l>", require("smart-splits").resize_right)

local cmp = require("cmp")
cmp.setup({
  snippet = { expand = function(args) vim.snippet.expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-e>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  }),
})

local configs = require('lspconfig.configs')

local function find_wakeroot(name)
  local dir = string.gsub(name, "/[^/]*$", "")
  if dir == "" then
    return ""
  end
  if file_exists(dir .. "/.wakeroot") or file_exists(dir .. "/wake.db") then
    return dir
  else
    return find_wakeroot(dir)
  end
end

if not configs.wakelsp then
  configs.wakelsp = {
    default_config = {
      cmd = { 'wake', '--lsp' },
      filetypes = { 'wake' },
      root_dir = find_wakeroot,
      settings = {},
    },
  }
end

require('lspconfig').wakelsp.setup {
  capabilities = lsp_capabilities,
  on_attach = lsp_on_attach,
}

vim.filetype.add {
  extension = {
    wake = 'wake',
  }
}
