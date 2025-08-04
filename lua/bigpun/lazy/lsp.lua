local root_files = {
	".luarc.json",
	".luarc.jsonc",
	".stylua.toml",
	".luacheckrc",
	"stylua.toml",
	"selene.toml",
	"selene.yml",
	".git",
}

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"stevearc/conform.nvim",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		--	"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		{
			"j-hui/fidget.nvim",
			tag = "legacy",
		},
		-- TypeScript specific plugins
		"pmizio/typescript-tools.nvim", -- Enhanced TypeScript support
		"jose-elias-alvarez/null-ls.nvim", -- Additional formatters and linters
		"windwp/nvim-ts-autotag", -- Auto close/rename HTML/JSX tags
		"JoosepAlviste/nvim-ts-context-commentstring", -- Better JSX commenting
	},

	config = function()
		require("conform").setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		})

		-- Format on save
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				require("conform").format({ bufnr = args.buf })
			end,
		})

		-- Add format keymap
		vim.keymap.set({ "n", "v" }, "<leader>f", function()
			require("conform").format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 500,
			})
		end, { desc = "Format file or range" })

		local cmp = require("cmp")
		local cmp_lsp = require("cmp_nvim_lsp")
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		require("fidget").setup({
			notification = {
				view = {
					window = {
						border = "rounded",
						winblend = 0,
						align = "bottom", -- "top" or "bottom"
						relative = "editor", -- "editor", "win", or "cursor"
					},
				},
			},
			progress = {
				display = {
					done_icon = "✔", -- or "✓", "", etc.
				},
			},
		})
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"ts_ls",
				"omnisharp",
				"angularls",
				"gopls",
			},
			handlers = {
				function(server_name) -- default handler (optional)
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
					})
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
				["gopls"] = function()
					local lspconfig = require("lspconfig")
					local util = require("lspconfig.util")

					lspconfig.gopls.setup({
						cmd = { vim.fn.exepath("gopls") }, -- resolves Mason's binary
						capabilities = require("cmp_nvim_lsp").default_capabilities(),
						filetypes = { "go", "gomod", "gowork", "gotmpl" },
						root_dir = util.root_pattern("go.work", "go.mod", ".git"),
						settings = {
							gopls = {
								analyses = {
									unusedparams = true,
									shadow = true,
									nilness = true,
									unusedwrite = true,
									useany = true,
								},
								codelenses = {
									generate = true, -- show `go generate` lens
									gc_details = true, -- show GC optimization details
									test = true, -- run tests from code lens
									tidy = true, -- run `go mod tidy`
									upgrade_dependency = true,
									vendor = true,
								},
								usePlaceholders = true,
								staticcheck = true,
								gofumpt = true, -- stricter gofmt
								hints = {
									assignVariableTypes = true,
									compositeLiteralFields = true,
									compositeLiteralTypes = true,
									constantValues = true,
									functionTypeParameters = true,
									parameterNames = true,
									rangeVariableTypes = true,
								},
							},
						},
						on_attach = function(client, bufnr)
							-- optional custom mappings or formatting behavior here
						end,
					})
				end,
				["angularls"] = function()
					local lspconfig = require("lspconfig")
					local util = require("lspconfig.util")

					lspconfig.angularls.setup({
						cmd = {
							vim.fn.exepath("ngserver"), -- use the actual executable from Mason
							"--stdio",
						},
						filetypes = { "typescript", "html" },
						root_dir = util.root_pattern("angular.json", "project.json"),
						on_attach = function(client, bufnr)
							-- Optional: customize keymaps or behavior here
						end,
						capabilities = require("cmp_nvim_lsp").default_capabilities(),
					})
				end,
				["lua_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.lua_ls.setup({
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
									},
								},
							},
						},
					})
				end,
				["omnisharp"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.omnisharp.setup({
						cmd = {
							vim.fn.executable("OmniSharp") == 1 and "OmniSharp" or "omnisharp",
							"-z", -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
							"--hostPID",
							tostring(vim.fn.getpid()),
							"DotNet:enablePackageRestore=false",
							"--encoding",
							"utf-8",
							"--languageserver",
						},
						capabilities = {
							workspace = {
								workspaceFolders = false,
							},
						},
						filetypes = { "cs", "vb" },
						init_options = {},
						root_dir = function(bufnr, on_dir)
							local fname = vim.api.nvim_buf_get_name(bufnr)
							on_dir(
								lspconfig.util.root_pattern("*.sln")(fname)
									or lspconfig.util.root_pattern("*.csproj")(fname)
									or lspconfig.util.root_pattern("omnisharp.json")(fname)
									or lspconfig.util.root_pattern("function.json")(fname)
							)
						end,
						settings = {
							FormattingOptions = {
								EnableEditorConfigSupport = true,
								OrganizeImports = nil,
							},
							MsBuild = {
								LoadProjectsOnDemand = nil,
							},
							RoslynExtensionsOptions = {
								EnableAnalyzersSupport = nil,
								EnableImportCompletion = nil,
								AnalyzeOpenDocumentsOnly = nil,
								EnableDecompilationSupport = nil,
							},
							RenameOptions = {
								RenameInComments = nil,
								RenameOverloads = nil,
								RenameInStrings = nil,
							},
							Sdk = {
								IncludePrereleases = true,
							},
						},
					})
				end,
				["ts_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.ts_ls.setup({
						capabilities = capabilities,
						settings = {
							typescript = {
								inlayHints = {
									includeInlayParameterNameHints = "all",
									includeInlayParameterNameHintsWhenArgumentMatchesName = false,
									includeInlayFunctionParameterTypeHints = true,
									includeInlayVariableTypeHints = true,
									includeInlayPropertyDeclarationTypeHints = true,
									includeInlayFunctionLikeReturnTypeHints = true,
									includeInlayEnumMemberValueHints = true,
								},
								suggest = {
									includeCompletionsForModuleExports = true,
									includeCompletionsForImportStatements = true,
									autoImports = true,
									includeAutomaticOptionalChainCompletions = true,
								},
								format = {
									indentSize = 2,
									convertTabsToSpaces = true,
									tabSize = 2,
									semicolons = "insert",
								},
								implementationsCodeLens = true,
								referencesCodeLens = true,
								preferences = {
									quoteStyle = "single",
									importModuleSpecifier = "relative",
								},
							},
							javascript = {
								inlayHints = {
									includeInlayParameterNameHints = "all",
									includeInlayParameterNameHintsWhenArgumentMatchesName = false,
									includeInlayFunctionParameterTypeHints = true,
									includeInlayVariableTypeHints = true,
									includeInlayPropertyDeclarationTypeHints = true,
									includeInlayFunctionLikeReturnTypeHints = true,
									includeInlayEnumMemberValueHints = true,
								},
							},
							completions = {
								completeFunctionCalls = true,
							},
						},
						commands = {
							OrganizeImports = {
								organize_imports,
								description = "Organize Imports",
							},
						},
					})
				end,
			},
		})

		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		-- LSP Keybindings
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
		vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Documentation" })
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

		-- Close quickfix/location list windows
		vim.keymap.set("n", "<leader>c", function()
			vim.cmd("cclose") -- Close quickfix
			vim.cmd("lclose") -- Close location list
		end, { desc = "Close quickfix/location windows" })

		-- Diagnostic keymaps
		-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous Diagnostic' })
		-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })
		-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show Diagnostic Error' })
		vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Show Diagnostics List" })

		local luasnip = require("luasnip")
		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body) -- For `luasnip` users.
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
				["<CR>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						if luasnip.expandable() then
							luasnip.expand()
						else
							cmp.confirm({
								select = true,
							})
						end
					else
						fallback()
					end
				end),

				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.locally_jumpable(1) then
						luasnip.jump(1)
					else
						fallback()
					end
				end, { "i", "s" }),

				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),
			sources = cmp.config.sources({
				{ name = "copilot", group_index = 2 },
				{ name = "nvim_lsp" },
				{ name = "luasnip" }, -- For luasnip users.
			}, {
				{ name = "buffer" },
			}),
		})

		-- Define diagnostic signs with explicit highlights
		local signs = {
			Error = "✘",
			Warn = "▲",
			Hint = "⚑",
			Info = "»",
		}

		-- Set diagnostic signs and highlights
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, {
				text = icon,
				texthl = hl,
				numhl = "",
				linehl = "DiagnosticLine" .. type,
			})
		end

		vim.diagnostic.config({
			virtual_text = {
				prefix = "■", -- More visible prefix
				source = true,
				severity = {
					min = vim.diagnostic.severity.ERROR,
				},
			},
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = true,
				header = "",
				prefix = "",
			},
			signs = true,
			underline = true,
			update_in_insert = true, -- Show updates even in insert mode
			severity_sort = true,
		})
	end,
}
