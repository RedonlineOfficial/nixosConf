# NixOS Dendritic Configuration

## Overview

A NixOS flake-based configuration for `nixos-demo` (x86_64-linux). Uses
`flake-parts` for output composition and `import-tree` to automatically load
all Nix files under `modules/` — no manual imports needed when adding new
module files.

## Flake Inputs

| Input | Purpose |
|---|---|
| `nixpkgs` | nixos-unstable channel — provides all packages |
| `flake-parts` | Flake output composition |
| `import-tree` | Auto-imports all files under `modules/` |
| `claude-code` | Provides the `claude-code` package via overlay |
| `nvf` | Neovim configuration framework (follows `nixpkgs`) |
| `stylix` | System-wide theming via base16 (follows `nixpkgs`) |
| `noctalia` | Noctalia shell (dock, bar, notifications — follows `nixpkgs`) |
| `home-manager` | User environment management (follows `nixpkgs`) |

## Directory Structure

```
nixosConf/
├── flake.nix                          # Inputs and outputs
├── flake.lock
└── modules/
    ├── features/
    │   ├── terminal/
    │   │   ├── default.nix            # metaTerminal module
    │   │   ├── zsh.nix                # zsh module
    │   │   └── git.nix                # git module
    │   ├── desktop/
    │   │   ├── common.nix             # commonDesktop module (bluetooth, power, fonts)
    │   │   └── hyprland/
    │   │       ├── default.nix        # nixosModules.metaHyprland + homeModules.metaHyprland
    │   │       ├── hyprland.nix       # nixosModules.hyprland + homeModules.hyprland
    │   │       ├── noctalia.nix       # nixosModules.noctalia + homeModules.noctalia
    │   │       └── kitty.nix          # nixosModules.kitty + homeModules.kitty
    │   ├── neovim.nix                 # neovim module (via nvf)
    │   └── stylix/
    │       └── default.nix            # stylix module (theme, fonts, wallpaper, opacity)
    ├── hosts/
    │   ├── common/
    │   │   └── configuration.nix      # commonConfiguration module
    │   └── nixos-demo/
    │       ├── default.nix            # nixosConfigurations.nixos-demo
    │       ├── configuration.nix      # nixos-demoConfiguration module
    │       └── hardware-configuration.nix
    └── users/
        └── joshua/
            └── default.nix            # joshua module (imports metaTerminal + home-manager config)
```

## Module System

Every file under `modules/` is auto-loaded by `import-tree` and contributes
to the flake outputs via `flake-parts`. Modules expose themselves as named
`flake.nixosModules.<name>` or `flake.homeModules.<name>` entries, which are
then composed in host and user modules.

**Host module composition** (`hosts/nixos-demo/default.nix`):
- `nixos-demoConfiguration` — hostname, stateVersion
- `nixos-demoHardware` — hardware-configuration.nix
- `commonConfiguration` — bootloader, locale, networking, nix settings, git
- `joshua` — user definition, imports `metaTerminal` + `homeModules.metaHyprland`
- `metaHyprland` — full Hyprland desktop (system-level)
- claude-code overlay inline
- home-manager NixOS module

**metaTerminal** (`features/terminal/default.nix`) pulls in:
- `zsh` module
- `neovim` module
- `lsd` package
- `zoxide` with zsh integration

**nixosModules.metaHyprland** (`features/desktop/hyprland/default.nix`) pulls in:
- `commonDesktop` — bluetooth, power-profiles, upower, FiraCode font
- `hyprland` — `programs.hyprland.enable`, XDG portal paths
- `noctalia` — Noctalia shell system module + binary cache
- `kitty` — (system-level stub)

**homeModules.metaHyprland** (`features/desktop/hyprland/default.nix`) pulls in:
- `homeModules.hyprland` — Hyprland appearance, keybindings, window rules
- `homeModules.noctalia` — Noctalia bar, dock, notifications, fonts
- `homeModules.kitty` — Kitty config, tab bar, session, keybindings

A user module that imports both `metaTerminal` (NixOS) and `homeModules.metaHyprland`
(home-manager) gets the full terminal + desktop environment automatically.

## System Settings (commonConfiguration)

- **Bootloader:** systemd-boot, EFI
- **Timezone:** America/Phoenix
- **Locale:** en_US.UTF-8
- **Networking:** NetworkManager
- **System packages:** git
- **SSH:** enabled, password auth disabled, root login disabled
- **Nix:** flakes + nix-command enabled, weekly GC (Saturday 23:00) and
  optimise (Saturday 23:30), allowUnfree = true
- **Binary caches:** cache.nixos.org, claude-code.cachix.org

## User (joshua)

- Normal user, groups: `wheel`, `networkmanager`
- Shell: zsh
- sudo requires password
- Packages: `claude-code`

## Terminal Environment

### Zsh (`features/terminal/zsh.nix`)

History size 10,000. Options: `AUTO_CD`, `HIST_IGNORE_DUPS`,
`HIST_IGNORE_SPACE`.

**Prompt:** custom inline prompt via `vcs_info`. Shows current path, git
branch, staged (`*`) and unstaged (`!`) indicators. Prompt symbol turns green
on success, red on non-zero exit.

**Shell aliases — NixOS:**
- `rebuild` — `sudo nixos-rebuild switch --flake ~/nixosConf#`
- `reload` — restart zsh

**Shell aliases — Navigation:**
- `z` / `..` / `2.`–`5.` — cd shortcuts
- `mkd` — `mkdir -pv`

**Shell aliases — File ops:**
- `cp`, `mv`, `rm` — interactive by default
- `grep`/`fgrep`/`egrep` — coloured output
- `fd` / `ff` — find directory / file by name

**Shell aliases — Git:**
- `gi`/`gic`, `gs`, `gl`, `ga`/`gaa`, `gc`/`gca`, `gco`/`gcm`,
  `gp`/`gpl`/`gd`/`gds`, `gu` (soft reset HEAD~1)

**Shell aliases — Neovim:**
- `v` → `nvim`, `sv` → `sudo nvim`

**Shell aliases — lsd:**
- `l` — `lsd -A --group-directories-first`
- `ll` — long listing with headers and git status
- `lt` / `llt` — tree views

**Shell aliases — Misc:**
- `c` → clear, `:q` → exit

**Shell functions:**
- `extract <file>` — unpacks any common archive format
- `sp` — opens a temp file in nvim (scratchpad)
- `script [-e]` — creates a temp bash script, opens in nvim, optionally executes
- `mcd <dir>` — mkdir + cd in one step
- `oil <user@host[:port]> <path>` — opens a remote path in nvim via oil's SSH support

**Other terminal tools:**
- `lsd` — modern ls replacement
- `zoxide` — smarter cd with frecency tracking, zsh integration enabled

## Neovim (`features/neovim/default.nix`)

Managed entirely by **nvf** (`github:notashelf/nvf`). nvf is a Nix-native
neovim configuration framework — all plugin setup, options, and keymaps are
expressed in Nix. Raw Lua is used only where Nix can't express it (function
values, `:append()` option mutations).

`vim` alias is enabled so `vim` also opens nvim.

### Theme
Dracula, dark style, transparent background. Terminal emulator must support
transparency for the effect to be visible.

### LSP
Global LSP enabled. Per-language servers and treesitter grammars are enabled
for: **bash**, **python**, **nix**, **html**, **css**.

### Plugins

| Plugin | Config location |
|---|---|
| **blink-cmp** | `vim.autocomplete.blink-cmp.setupOpts` |
| **telescope** | `vim.telescope` + keymaps in `vim.maps.normal` |
| **treesitter** | `vim.treesitter` + per-language |
| **oil.nvim** | `vim.utility.oil-nvim.setupOpts` |
| **which-key** | `vim.binds.whichKey` + `luaConfigRC.whichkey` |

**blink-cmp:** Documentation auto-shows. Fuzzy uses Lua implementation
(avoids needing a pre-built Rust binary on NixOS). Custom keymap:
`<C-p>`/`<C-n>` navigate, `<C-y>` accept, `<C-e>` cancel, `<C-space>`
toggle docs, `<Tab>`/`<S-Tab>` snippet nav, `<C-b>`/`<C-f>` scroll docs,
`<C-k>` signature help.

**oil.nvim:** Default file explorer, hidden files visible, sorted by type
then name. `skip_confirm_for_simple_edits = true`. LSP file method
integration enabled. `<C-l>` disabled inside oil buffers to avoid conflicting
with split navigation. Toggle bound to `<leader>fe` via a custom `ToggleOil()`
Lua function that checks for an existing oil buffer and deletes it rather than
opening a new one.

**telescope:** Keymaps all under `<leader>s`. which-key group label "[S]earch"
with a green icon registered via `require("which-key").add()` in
`luaConfigRC.whichkey`.

**treesitter:** Enabled globally and per-language. Highlight enabled per
language module.

**which-key:** Enabled. Groups registered in `luaConfigRC.whichkey`.

### Key Options of Note
- `clipboard = "unnamedplus"` — system clipboard integration
- `undofile = true` with persistent undodir at `~/.local/share/nvim/undodir`
- No swapfile, no backup files
- 2-space indent, spaces not tabs
- `colorcolumn = 100`, relative line numbers, cursorline
- `scrolloff = 10` / `sidescrolloff = 10`
- `iskeyword` extended with `-` (via `luaConfigRC.options`)
- `path` extended with `**` for recursive file search
- `diffopt` extended with `linematch:60`

### Keymaps

**Normal mode — General:**
| Key | Action |
|---|---|
| `<ESC>` | Clear search highlights |
| `<C-h/j/k/l>` | Move between splits |
| `<C-Arrow>` | Resize splits |
| `<leader>w` | Save |
| `<leader>x` | Save and quit |
| `<leader>q` | Quit |
| `<leader>Q` | Force quit |

**Normal mode — Oil:**
| Key | Action |
|---|---|
| `<leader>fe` | Toggle Oil file explorer |

**Normal mode — Telescope (`<leader>s`):**
| Key | Action |
|---|---|
| `<leader>sp` | Search builtin pickers |
| `<leader>sb` | Search buffers |
| `<leader>sf` | Find files |
| `<leader>sw` | Grep current word |
| `<leader>sg` | Live grep |
| `<leader>sr` | Resume last search |
| `<leader>sh` | Search help tags |
| `<leader>sm` | Search man pages |

**Visual mode:**
| Key | Action |
|---|---|
| `J` | Move selection down |
| `K` | Move selection up |

## Applying Changes

```bash
sudo nixos-rebuild switch --flake ~/nixosConf#nixos-demo
```

Or using the shell alias:
```bash
rebuild
```

## Claude Workflow Instructions

- For any set of changes, create a new branch first, then `git add` and `git commit` using the **Conventional Commits** standard (`feat:`, `fix:`, `refactor:`, `chore:`, etc.).
- Always show the proposed commands and **wait for user confirmation** before running them.
- Do not batch unrelated changes into a single commit.
- After committing, ask the user to run `rebuild` to test the build.
- If the build succeeds, merge the branch into `main`.
- **Important:** NixOS flakes use git to determine which files to include — untracked files are invisible to `nixos-rebuild`. Always commit (or at least stage) changes before asking the user to rebuild.

## Adding a New Feature Module

1. Create `modules/features/<name>/default.nix` — `import-tree` picks it up
   automatically.
2. Expose it as `flake.nixosModules.<name>`.
3. Import it where needed — either in `metaTerminal`, a user module, or
   directly in the host's module list in `hosts/nixos-demo/default.nix`.
