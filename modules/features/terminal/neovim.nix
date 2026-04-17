{ self, inputs, ... }: {

  flake.nixosModules.neovim = { ... }: {
    imports = [ inputs.nvf.nixosModules.default ];

    programs.nvf = {
      enable = true;
      settings = {
        vim = {
          vimAlias = true;

          globals.mapleader = " ";

          theme.transparent = true;

          lsp.enable = true;

          languages = {
            bash = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };
            python = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };
            nix = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };
            html = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
              format.enable = true;
            };
            css = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
            };
          };

          autocomplete.blink-cmp = {
            enable = true;
            setupOpts = {
              completion.documentation.auto_show = true;
              keymap = {
                "<C-p>"     = [ "select_prev" "fallback_to_mappings" ];
                "<C-n>"     = [ "select_next" "fallback_to_mappings" ];
                "<C-y>"     = [ "select_and_accept" "fallback" ];
                "<C-e>"     = [ "cancel" "fallback" ];
                "<C-space>" = [ "show" "show_documentation" "hide_documentation" ];
                "<Tab>"     = [ "snippet_forward" "fallback" ];
                "<S-Tab>"   = [ "snippet_backward" "fallback" ];
                "<C-b>"     = [ "scroll_documentation_up" "fallback" ];
                "<C-f>"     = [ "scroll_documentation_down" "fallback" ];
                "<C-k>"     = [ "show_signature" "hide_signature" "fallback" ];
              };
              fuzzy.implementation = "lua";
            };
          };

          telescope.enable = true;

          treesitter = {
            enable = true;
          };

          utility.oil-nvim = {
            enable = true;
            setupOpts = {
              default_file_explorer = true;
              skip_confirm_for_simple_edits = true;
              watch_for_changes = true;
              constrain_cursor = "editable";
              cleanup_delay_ms = 2000;
              prompt_save_on_select_new_entry = true;
              buf_options = {
                buflisted = false;
                bufhidden = "hide";
              };
              win_options = {
                wrap = false;
                signcolumn = "no";
                cursorcolumn = false;
                foldcolumn = "0";
                spell = false;
                list = false;
                conceallevel = 3;
                concealcursor = "nvic";
              };
              lsp_file_methods = {
                enabled = true;
                timeout_ms = 1000;
                autosave_changes = false;
              };
              view_options = {
                show_hidden = true;
                natural_order = "fast";
                case_insensitive = false;
                sort = [
                  [ "type" "asc" ]
                  [ "name" "asc" ]
                ];
              };
              # Disable <C-l> in oil to preserve split navigation
              keymaps."<C-l>" = false;
            };
          };

          binds.whichKey.enable = true;

          options = {
            # General
            selection     = "inclusive";
            mouse         = "a";
            clipboard     = "unnamedplus";
            modifiable    = true;
            encoding      = "utf-8";
            wrap          = false;
            autoread      = true;
            autowrite     = false;
            hidden        = true;
            errorbells    = false;
            backspace     = "indent,eol,start";
            autochdir     = false;

            # Appearance
            number         = true;
            relativenumber = true;
            cursorline     = true;
            signcolumn     = "yes";
            colorcolumn    = "100";
            showmatch      = true;
            showmode       = false;
            conceallevel   = 0;
            concealcursor  = "";
            synmaxcol      = 300;
            fillchars      = "eob: ";
            termguicolors  = true;

            # Tabbing
            tabstop     = 2;
            shiftwidth  = 2;
            softtabstop = 2;
            expandtab   = true;

            # Indentation
            smartindent = true;
            autoindent  = true;

            # Search
            ignorecase = true;
            smartcase  = true;
            hlsearch   = true;
            incsearch  = true;

            # Scroll
            scrolloff     = 10;
            sidescrolloff = 10;

            # Windows
            wildmenu   = true;
            wildmode   = "longest:full,full";
            pumheight  = 10;
            pumblend   = 10;
            winblend   = 0;
            cmdheight  = 1;

            # Backup and undo
            backup      = false;
            writebackup = false;
            swapfile    = false;
            undofile    = true;

            # Splits
            splitbelow = true;
            splitright = true;

            # Completions
            completeopt = "menuone,noinsert,noselect";
            inccommand  = "split";

            # Performance
            redrawtime    = 10000;
            maxmempattern = 20000;
            updatetime    = 300;
            timeoutlen    = 500;
            ttimeoutlen   = 0;
          };

          maps.normal = {
            # General
            "<Space>"     = { action = "<Nop>"; };
            "<ESC>"       = { action = "<cmd>nohlsearch<CR>"; desc = "Clear search highlights"; };

            # Move between splits
            "<C-h>"       = { action = "<C-w>h"; desc = "Move to left split"; };
            "<C-j>"       = { action = "<C-w>j"; desc = "Move to split below"; };
            "<C-k>"       = { action = "<C-w>k"; desc = "Move to split above"; };
            "<C-l>"       = { action = "<C-w>l"; desc = "Move to right split"; };

            # Resize splits
            "<C-Up>"      = { action = ":resize -2<CR>"; silent = true; desc = "Shrink split height"; };
            "<C-Down>"    = { action = ":resize +2<CR>"; silent = true; desc = "Grow split height"; };
            "<C-Left>"    = { action = ":vertical resize -2<CR>"; silent = true; desc = "Shrink split width"; };
            "<C-Right>"   = { action = ":vertical resize +2<CR>"; silent = true; desc = "Grow split width"; };

            # Save/Exit
            "<leader>w"   = { action = "<cmd>w<CR>"; desc = "Save"; };
            "<leader>x"   = { action = "<cmd>x<CR>"; desc = "Save and quit"; };
            "<leader>q"   = { action = "<cmd>q<CR>"; desc = "Quit"; };
            "<leader>Q"   = { action = "<cmd>q!<CR>"; desc = "Force quit"; };

            # Oil
            "<leader>fe"  = { action = ":lua ToggleOil()<CR>"; silent = true; desc = "Toggle Oil"; };

            # Telescope
            "<leader>sp"  = { action = ":lua require('telescope.builtin').builtin()<CR>"; silent = true; desc = "[S]earch Builtin [P]ickers"; };
            "<leader>sb"  = { action = ":lua require('telescope.builtin').buffers()<CR>"; silent = true; desc = "[S]earch [B]uffers"; };
            "<leader>sf"  = { action = ":lua require('telescope.builtin').find_files()<CR>"; silent = true; desc = "[S]earch [F]iles"; };
            "<leader>sw"  = { action = ":lua require('telescope.builtin').grep_string()<CR>"; silent = true; desc = "[S]earch Current [W]ord"; };
            "<leader>sg"  = { action = ":lua require('telescope.builtin').live_grep()<CR>"; silent = true; desc = "[S]earch by [G]rep"; };
            "<leader>sr"  = { action = ":lua require('telescope.builtin').resume()<CR>"; silent = true; desc = "[S]earch [R]esume"; };
            "<leader>sh"  = { action = ":lua require('telescope.builtin').help_tags()<CR>"; silent = true; desc = "[S]earch [H]elp"; };
            "<leader>sm"  = { action = ":lua require('telescope.builtin').man_pages()<CR>"; silent = true; desc = "[S]earch [M]anuals"; };
          };

          maps.visual = {
            # Move selected text up/down
            "J" = { action = ":m '>+1<CR>gv=gv"; silent = true; desc = "Move selection down"; };
            "K" = { action = ":m '<-2<CR>gv=gv"; silent = true; desc = "Move selection up"; };
          };

          luaConfigRC.whichkey = ''
            require("which-key").add({
              { "<leader>s", group = "[S]earch", icon = { icon = "", color = "green" } },
            })
          '';

          luaConfigRC.keymaps = ''
            function ToggleOil()
              local oil_buf = nil
              for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
                if ft == "oil" then
                  oil_buf = buf
                  break
                end
              end
              if oil_buf and vim.api.nvim_buf_is_valid(oil_buf) then
                vim.api.nvim_buf_delete(oil_buf, { force = true })
              else
                vim.cmd("Oil")
              end
            end
          '';

          luaConfigRC.options = ''
            -- Append to existing options
            vim.opt.iskeyword:append("-")
            vim.opt.path:append("**")
            vim.opt.diffopt:append("linematch:60")

            -- Undo directory
            local undodir = vim.fn.expand("~/.local/share/nvim/undodir")
            if vim.fn.isdirectory(undodir) == 0 then
              vim.fn.mkdir(undodir, "p")
            end
            vim.opt.undodir = undodir
          '';
        };
      };
    };
  };

}
