vim.o.compatible    = false

vim.o.number        = true
vim.o.tabstop       = 4
vim.o.shiftwidth    = 4
vim.o.expandtab     = true

vim.o.foldmethod    = 'indent'
vim.o.foldnestmax   = 10
vim.o.foldenable    = false
vim.o.foldlevel     = 2

vim.o.clipboard     = 'unnamedplus'
vim.o.showmode      = false
vim.o.splitright    = true

vim.o.termguicolors = true
vim.o.completeopt   = 'menu,menuone,noselect'

vim.o.autoread = true
vim.o.background = 'dark'
vim.o.endofline = false
vim.o.gdefault = true
vim.o.swapfile = false

vim.diagnostic.config({
	update_in_insert = true
})

local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	use {
		'ellisonleao/gruvbox.nvim',
		config = function()
			require('gruvbox').setup {
				italic = false,
				contrast = "hard",
			}
			vim.cmd('colorscheme gruvbox')
		end
	}

	use {
		'nvim-lualine/lualine.nvim',
		requires = {
			'kyazdani42/nvim-web-devicons',
			opt = true
		},
		config = function()
			require('lualine').setup({})
		end
	}

	use {
		'nvim-treesitter/nvim-treesitter',
		run = function()
			local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
			ts_update()
		end,
		config = function()
			require('nvim-treesitter.configs').setup {
				ensure_installed = { 'lua', 'cpp', 'c', 'kotlin', 'go', 'python' },
				highlight = {
					enable = true
				},
				indent = {
					enable = true
				}
			}
		end
	}
	use {
		'nvim-tree/nvim-tree.lua',
		requires = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
			require("nvim-tree").setup()
			vim.api.nvim_set_keymap('', '<C-r>', '<ESC>:NvimTreeToggle<CR>', { noremap = true, silent = true})
		end
	}
	use {
		'neovim/nvim-lspconfig',
		requires = {
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
			'hrsh7th/nvim-cmp',

			'hrsh7th/vim-vsnip',
			'hrsh7th/cmp-vsnip',

			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim'
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup()
			require("mason-lspconfig").setup_handlers {
				function (server_name)
					require("lspconfig")[server_name].setup {}
				end,
			}
			local cmp = require('cmp')
			cmp.setup({
				snippet = {
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body)
					end
				},
				window = {
					documentation = cmp.config.window.bordered(),
					completion = cmp.config.window.bordered()
				},

				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<CR>'] = cmp.mapping.confirm({ select = true }),
				}),

				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'vsnip' }
				}, {
					{ name = 'buffer' },
				})
			})

			cmp.setup.filetype('gitcommit', {
				sources = cmp.config.sources({
					{ name = 'cmp_git' },
				}, {
					{ name = 'buffer' },
				})
			})

			cmp.setup.cmdline({ '/', '?' }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = 'buffer' }
				}
			})

			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = 'path' }
				}, {
					{ name = 'cmdline' }

				})
			})

			local capabilities = require('cmp_nvim_lsp').default_capabilities()

			local lspconfig = require('lspconfig')
			lspconfig.util.default_config = vim.tbl_extend(
			"force",
			lspconfig.util.default_config,
			{ capabilities = capabilities }
			)
		end
	}

    use {
        'akinsho/bufferline.nvim',
        tag = "v3.*",
        requires = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            diagnostics_indicator = function(count, level, diagnostics_dict, context)
                local icon = level:match("error") and " " or " "
                return " " .. icon .. count
            end

            require("bufferline").setup{
                options = {
                    diagnostics = "nvim_lsp",
                    diagnostics_update_in_insert = true,
                    diagnostics_indicator = diagnostics_indicator
                }
            }
        end
    }

	if packer_bootstrap then
		require('packer').sync()
	end
end)
