return {
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      local auto_select = true
      return {
        auto_brackets = {}, -- configure any filetype to auto add brackets
        completion = {
          completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
        },
        preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
        mapping = cmp.mapping.preset.insert({
          -- Scroll docs
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),

          -- Move down the completion list with Ctrl-j
          ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),

          -- Move up the completion list with Ctrl-k
          ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),

          -- Manually trigger completion
          ["<C-Space>"] = cmp.mapping.complete(),

          -- Confirm selection
          ["<CR>"] = LazyVim.cmp.confirm({ select = auto_select }),

          -- Confirm selection with <C-y>
          ["<C-y>"] = LazyVim.cmp.confirm({ select = true }),

          -- Accept current selection, Replace current word (using <S-CR>)
          ["<S-CR>"] = LazyVim.cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace }),

          -- Abort and fallback on <C-CR>
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,

          -- Use tab for snippet or AI acceptance (based on your configuration)
          ["<tab>"] = function(fallback)
            return LazyVim.cmp.map({ "snippet_forward", "ai_accept" }, fallback)()
          end,
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
        formatting = {
          format = function(entry, item)
            local icons = LazyVim.config.icons.kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end

            local widths = {
              abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
              menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
            }

            for key, width in pairs(widths) do
              if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
              end
            end

            return item
          end,
        },
        experimental = {
          -- only show ghost text when we show ai completions
          ghost_text = vim.g.ai_cmp and {
            hl_group = "CmpGhostText",
          } or false,
        },
        sorting = defaults.sorting,
      }
    end,
    main = "lazyvim.util.cmp",
  },
  {
    "zbirenbaum/copilot-cmp",
    enabled = vim.g.ai_cmp, -- only enable if wanted
    opts = {},
    config = function(_, opts)
      local copilot_cmp = require("copilot_cmp")
      copilot_cmp.setup(opts)
      -- attach cmp source whenever copilot attaches
      -- fixes lazy-loading issues with the copilot cmp source
      LazyVim.lsp.on_attach(function()
        copilot_cmp._on_insert_enter({})
      end, "copilot")
    end,
    specs = {
      {
        "nvim-cmp",
        optional = true,
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
          table.insert(opts.sources, 1, {
            name = "copilot",
            group_index = 1,
            priority = 100,
          })
        end,
      },
    },
    keys = {
      {
        "<leader>co",
        function()
          if require("copilot.client").is_disabled() then
            require("copilot.command").enable()
          else
            require("copilot.command").disable()
          end
        end,
        desc = "Toggle (Copilot)",
      },
    },
  },
  {
    "giuxtaposition/blink-cmp-copilot",
    enabled = vim.g.ai_cmp, -- only enable if needed
    specs = {
      {
        "blink.cmp",
        optional = true,
        opts = {
          sources = {
            providers = {
              copilot = { name = "copilot", module = "blink-cmp-copilot" },
            },
            completion = {
              enabled_providers = { "copilot" },
            },
          },
        },
      },
    },
  },
}
