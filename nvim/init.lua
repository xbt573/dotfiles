vim.o.compatible = false

vim.o.number     = true
vim.o.tabstop    = 4
vim.o.shiftwidth = 4
vim.o.expandtab  = true

vim.o.foldmethod  = 'indent'
vim.o.foldnestmax = 10
vim.o.foldenable  = false
vim.o.foldlevel   = 2

vim.o.clipboard  = 'unnamedplus'
vim.o.showmode   = false
vim.o.splitright = true

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

vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    pattern = { '*.go', '*.lua' },
    callback = function()
        vim.lsp.buf.formatting_sync(nil, 3000)
    end
})

local function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map("i", "jk", "<ESC><ESC>", { silent = true })

local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use {
        'xbt573/gruvbox.nvim',
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
            -- { 'kyazdani42/nvim-web-devicons', opt = true },
            -- { 'SmiteshP/nvim-navic', opt = true },
            'kyazdani42/nvim-web-devicons',
            'SmiteshP/nvim-navic'
        },
        config = function()
            require('lualine').setup({
                sections = {
                    lualine_c = {
                        { require('nvim-navic').get_location, cond = require('nvim-navic').is_available },
                    }
                }
            })
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
            require("nvim-tree").setup {
                auto_reload_on_write = true,
                diagnostics = {
                    enable = true
                }
            }
            vim.api.nvim_set_keymap('', '<C-r>', '<ESC>:NvimTreeToggle<CR>', { noremap = true, silent = true })
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

            'SmiteshP/nvim-navic'
        },
        config = function()
            -- Mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            local opts = { noremap = true, silent = true }
            vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
            vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

            -- Use an on_attach function to only map the following keys
            -- after the language server attaches to the current buffer
            local on_attach = function(client, bufnr)
                require('inlay-hints').on_attach(client, bufnr)
                require('nvim-navic').attach(client, bufnr)
                -- Enable completion triggered by <c-x><c-o>
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                -- Mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local bufopts = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
                vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
                vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
                vim.keymap.set('n', '<space>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, bufopts)
                vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
                vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
                vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
                vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
            end


            require('lspconfig').gopls.setup {
                on_attach = on_attach,
                settings = {
                    gopls = {
                        hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            constantValues = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
                        }
                    }
                }
            }


            require('lspconfig').sumneko_lua.setup {
                on_attach = on_attach,
                settings = {
                    Lua = {
                        runtime = {
                            version = 'LuaJIT',
                        },
                        diagnostics = {
                            globals = { 'vim' },
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            }

            require('lspconfig').ruby_ls.setup {
                on_attach = on_attach
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
        requires = 'nvim-tree/nvim-web-devicons',
        config = function()
            require("bufferline").setup {
                options = {
                    mode = "tabs",
                    numbers = "buffer_id",
                    offsets = {
                        {
                            filetype = "NvimTree",
                            text = "Files",
                            text_align = "center",
                            separator = true
                        }
                    },
                    color_icons = true
                }
            }
        end
    }

    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    }

    use 'tpope/vim-commentary'
    -- use {
    --     'lvimuser/lsp-inlayhints.nvim',
    --     config = function()
    --         require('lsp-inlayhints').setup()
    --     end
    -- }
    use {
        'simrat39/inlay-hints.nvim',
        config = function()
            require("inlay-hints").setup()
        end
    }

    if packer_bootstrap then
        require('packer').sync()
    end
end)
