-- ============================================
-- 基础设置
-- ============================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.termguicolors = true
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.updatetime = 250
opt.clipboard = "unnamedplus"

-- 自动创建 swap/undo 目录（如果不存在）
local swap_dir = vim.fn.stdpath("state") .. "/swap"
local undo_dir = vim.fn.stdpath("state") .. "/undo"
for _, dir in ipairs({ swap_dir, undo_dir }) do
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end

opt.directory = swap_dir .. "//"
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true
opt.undodir = undo_dir .. "//"

-- ============================================
-- 插件管理器 lazy.nvim 自举
-- ============================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================
-- 插件列表
-- ============================================
require("lazy").setup({

  -- 主题
  {
    "nchhillar2004/gemini.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("gemini")
    end,
  },

  -- 语法高亮 / 括号配对高亮
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc" },
        highlight = { enable = true },
      })
    end,
  },
  { "hiphish/rainbow-delimiters.nvim" },

  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },

  -- 补全
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- 文件树
  { "nvim-tree/nvim-tree.lua" },

  -- 模糊搜索
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- 状态栏
  { "nvim-lualine/lualine.nvim" },

  -- 浮动命令行
  {
    "rachartier/tiny-cmdline.nvim",
    config = function()
      require("vim._core.ui2").enable {}
      require("tiny-cmdline").setup {
        width = {
          value = "60%",
          min = 40,
          max = 80,
        },
        position = {
          x = "50%",
          y = "90%",
        },
        menu_col_offset = 0,
      }
    end,
  },

  -- 调试 (DAP)
  { "mfussenegger/nvim-dap" },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  },

  -- 编辑增强
  { "windwp/nvim-autopairs", config = true },
  { "numToStr/Comment.nvim", config = true },
  { "lewis6991/gitsigns.nvim", config = true },
  { "folke/which-key.nvim", config = true },

  -- 括号/作用域跳转与可视化
  { "andymass/vim-matchup" },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope = {
          enabled = true,
          show_start = true,
          show_end = true,
          highlight = { "Function" },
        },
      })
    end,
  },

})

-- ============================================
-- 补全引擎设置
-- ============================================
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
  },
})

-- ============================================
-- LSP 设置（clangd 用于 C）
-- ============================================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {},
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

--vim.lsp.config("clangd", {
--  capabilities = capabilities,
--})
--vim.lsp.enable("clangd")

-- LSP 相关快捷键（只在有LSP连接的buffer里生效）
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(keys, func)
      vim.keymap.set("n", keys, func, { buffer = ev.buf })
    end
    map("gd", vim.lsp.buf.definition)
    map("gr", vim.lsp.buf.references)
    map("K", vim.lsp.buf.hover)
    map("<leader>rn", vim.lsp.buf.rename)
    map("<leader>ca", vim.lsp.buf.code_action)
  end,
})

-- ============================================
-- rainbow-delimiters 配置
-- ============================================
local rainbow_delimiters = require("rainbow-delimiters")
vim.g.rainbow_delimiters = {
  strategy = { [""] = rainbow_delimiters.strategy["global"] },
  query = { [""] = "rainbow-delimiters" },
}

-- ============================================
-- 文件树 / 状态栏
-- ============================================
require("nvim-tree").setup()
require("lualine").setup()

-- ============================================
-- 常用快捷键
-- ============================================
local keymap = vim.keymap.set
keymap("n", "<leader>e", ":NvimTreeToggle<CR>")
keymap("n", "<leader>ff", ":Telescope find_files<CR>")
keymap("n", "<leader>fg", ":Telescope live_grep<CR>")
keymap("n", "<leader>w", ":w<CR>")
keymap("n", "<leader>q", ":q<CR>")

-- ============================================
-- DAP 调试快捷键
-- ============================================
local dap = require("dap")
local dapui = require("dapui")
dapui.setup()

keymap("n", "<F5>", dap.continue)
keymap("n", "<F10>", dap.step_over)
keymap("n", "<F11>", dap.step_into)
keymap("n", "<F12>", dap.step_out)
keymap("n", "<leader>b", dap.toggle_breakpoint)
keymap("n", "<leader>du", dapui.toggle)

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
