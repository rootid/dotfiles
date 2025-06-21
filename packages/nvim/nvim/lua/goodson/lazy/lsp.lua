local root_files = {
  '.luarc.json',
  '.luarc.jsonc',
  '.luacheckrc',
  '.stylua.toml',
  'stylua.toml',
  'selene.toml',
  'selene.yml',
  '.git',
}

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "stevearc/conform.nvim",        -- Formatting plugin
    "williamboman/mason.nvim",      -- Package manager
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",        -- LSP completion
    "hrsh7th/cmp-buffer",          -- Buffer completion
    "hrsh7th/cmp-path",            -- Path completion
    "hrsh7th/cmp-cmdline",         -- Command line completion
    "hrsh7th/nvim-cmp",            -- Completion engine
    "L3MON4D3/LuaSnip",            -- Snippet engine
    "saadparwaiz1/cmp_luasnip",    -- Snippet completion
    "j-hui/fidget.nvim",           -- LSP progress UI
  },

  config = function()
    require("conform").setup({
      formatters_by_ft = {
      }
    })
    local cmp = require('cmp')
    local cmp_lsp = require("cmp_nvim_lsp")
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities())

    require("fidget").setup({})
    require("mason").setup()
    require("mason-lspconfig").setup({
      -- Add LSP servers Here
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        --"gopls",
      },
      handlers = {
        function(server_name) -- default handler (optional)
          require("lspconfig")[server_name].setup {
            capabilities = capabilities
          }
        end,

        zls = function()
          local lspconfig = require("lspconfig")
          lspconfig.zls.setup({
            root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
            settings = {
              zls = {
                enable_inlay_hints = true,
                enable_snippets = true,
                warn_style = true,
              },
            },
          })
          vim.g.zig_fmt_parse_errors = 0
          vim.g.zig_fmt_autosave = 0

        end,
        ["lua_ls"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                format = {
                  enable = true,
                  -- Put format options here
                  -- NOTE: the value should be STRING!!
                  defaultConfig = {
                    indent_style = "space",
                    indent_size = "2",
                  }
                },
              }
            }
          }
        end,
      }
    })

    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if not cmp.visible() then
            cmp.complete()
          elseif cmp.visible() then
            cmp.select_next_item()
          elseif require('luasnip').expand_or_jumpable() then
            require('luasnip').expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif require('luasnip').jumpable(-1) then
            require('luasnip').jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<CR>"] = cmp.mapping.confirm({ select = true })
      }),
      sources = cmp.config.sources({
        { name = "copilot", group_index = 2 },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      }, {
          { name = 'buffer' },
        })
    })
    --cmp.setup({
    --  snippet = {
    --    expand = function(args)
    --      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    --    end,
    --  },
    --  mapping = cmp.mapping.preset.insert({
    --    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    --    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    --    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    --    ["<Tab>"] = cmp.mapping.complete(),
    --  }),
    --  sources = cmp.config.sources({
    --    --{ name = "copilot", group_index = 2 }, TODO: test the copilot
    --    { name = 'nvim_lsp' }, -- LSP completions
    --    { name = 'luasnip' }, -- For luasnip users.
    --  }, {
    --      { name = 'buffer' },   -- Buffer completions
    --      { name = 'path' },     -- Path completions
    --    })
    --})

    vim.diagnostic.config({
      -- update_in_insert = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
      },
    })
  end
}
