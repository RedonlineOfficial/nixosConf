# NixOS Dendritic Configuration

## Overview

A NixOS flake-based configuration for multiple hosts (x86_64-linux). Uses
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
| `disko` | Declarative disk partitioning (follows `nixpkgs`) |

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
    │   │       ├── kitty.nix          # nixosModules.kitty + homeModules.kitty
    │   │       └── waybar.nix         # nixosModules.waybar + homeModules.waybar
    │   ├── neovim.nix                 # neovim module (via nvf)
    │   └── stylix/
    │       └── default.nix            # stylix module (theme, fonts, wallpaper, opacity)
    ├── hosts/
    │   ├── common/
    │   │   └── configuration.nix      # commonConfiguration module
    │   ├── nixos-demo/
    │   │   ├── default.nix            # nixosConfigurations.nixos-demo
    │   │   ├── configuration.nix      # nixos-demoConfiguration module
    │   │   └── hardware-configuration.nix
    │   └── hm-pc-ws-01/
    │       ├── default.nix            # nixosConfigurations.hm-pc-ws-01
    │       ├── configuration.nix      # hm-pc-ws-01Configuration module
    │       ├── disko.nix              # hm-pc-ws-01Disko module (disk layout)
    │       └── hardware-configuration.nix  # stub — regenerate after install
    └── users/
        └── joshua/
            ├── default.nix            # joshua module (imports metaTerminal + home-manager config)
            └── gpg-pubkey.asc         # GPG public key (imported declaratively via programs.gpg)
```

## Module System

Every file under `modules/` is auto-loaded by `import-tree` and contributes
to the flake outputs via `flake-parts`. Modules expose themselves as named
`flake.nixosModules.<name>` or `flake.homeModules.<name>` entries, which are
then composed in host and user modules.

**Host module composition** (`hosts/nixos-demo/default.nix`):
- `nixos-demoConfiguration` — hostname, stateVersion
- `nixos-demoHardware` — hardware-configuration.nix
- `commonConfiguration` — bootloader, locale, networking, nix settings, YubiKey
- `joshua` — user definition, imports `metaTerminal` + `homeModules.metaHyprland`
- `metaHyprland` — full Hyprland desktop (system-level)
- claude-code overlay inline
- home-manager NixOS module

**Host module composition** (`hosts/hm-pc-ws-01/default.nix`):
- `inputs.disko.nixosModules.disko` — disko NixOS module
- `hm-pc-ws-01Disko` — GPT disk layout (EFI + LUKS2 root)
- `hm-pc-ws-01Configuration` — hostname, LUKS/FIDO2, swapfile, hibernation
- `hm-pc-ws-01Hardware` — kernel modules (stub, regenerate post-install)
- `commonConfiguration`, `joshua`, `metaHyprland`, home-manager (same as nixos-demo)

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
- **SSH:** enabled, password auth disabled, root login disabled, agent forwarding enabled
- **GPG agent:** enabled system-wide (`programs.gnupg.agent`); designed for forwarded
  agent use — `enableSSHSupport` is off so the forwarded SSH agent socket is not overridden
- **YubiKey:** `pcscd` + udev rules enabled for smartcard/FIDO2 access
- **sudo via YubiKey:** `pam_ssh_agent_auth` enabled — sudo authenticates via forwarded
  SSH agent (YubiKey on primary host signs the PAM challenge); `SSH_AUTH_SOCK` preserved
  across sudo via `env_keep`
- **GPG socket forwarding:** `StreamLocalBindUnlink = true` allows the RemoteForward
  from the primary host to replace the local GPG agent socket on connect
- **Nix:** flakes + nix-command enabled, weekly GC (Saturday 23:00) and
  optimise (Saturday 23:30), allowUnfree = true
- **Binary caches:** cache.nixos.org, claude-code.cachix.org

## User (joshua)

- Normal user, groups: `wheel`, `networkmanager`
- Shell: zsh
- sudo requires password (or YubiKey via forwarded SSH agent)
- Packages: `claude-code`
- GPG public key (`gpg-pubkey.asc`) imported with ultimate trust via `programs.gpg.publicKeys`
  — enables GPG commit signing via forwarded agent on any host

## hm-pc-ws-01 Disk Layout (disko)

GPT on `/dev/nvme0n1`:

| Partition | Label | Size | Format | Mount |
|---|---|---|---|---|
| 1 | `ESP` | 1G | FAT32 | `/boot` |
| 2 | `cryptroot` | remainder | LUKS2 → ext4 | `/` |

- LUKS2 unlocked via YubiKey FIDO2 (`systemd-cryptenroll`)
- `allowDiscards = true` for NVMe performance
- 20GB swapfile at `/swapfile` (NixOS creates automatically)
- Hibernation: `boot.resumeDevice = "/dev/mapper/cryptroot"`

**Post-install steps for hm-pc-ws-01:**
```bash
# 1. Enroll YubiKey into LUKS
sudo systemd-cryptenroll --fido2-device=auto /dev/nvme0n1p2

# 2. Get swapfile resume offset for hibernation
sudo filefrag -v /swapfile | awk 'NR==4{gsub(/\./,""); print $4}'
# Add resume_offset=<value> to boot.kernelParams in configuration.nix, then rebuild

# 3. Regenerate hardware-configuration.nix from actual hardware
sudo nixos-generate-config --show-hardware-config
# Replace modules/hosts/hm-pc-ws-01/hardware-configuration.nix with output
```

## Installing a New Host with Disko

Boot the NixOS live ISO and connect to the internet, then run a single
command that partitions, formats, mounts, and installs NixOS:

```bash
sudo nix run 'github:nix-community/disko#disko-install' -- \
  --flake 'github:RedonlineOfficial/nixosConf#<hostname>' \
  --disk main /dev/<device> \
  --write-efi-boot-entries
```

> **Note:** `diskoScript` is deprecated — always use `disko-install`.

After first boot, enroll the YubiKey into LUKS (hm-pc-ws-01 only):
```bash
sudo systemd-cryptenroll --fido2-device=auto /dev/nvme0n1p2
```

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

## Waybar (`features/desktop/hyprland/waybar.nix`)

Managed via `homeModules.waybar`. Stylix auto-theming is disabled
(`stylix.targets.waybar.enable = false`) — colors are applied manually using
`config.lib.stylix.colors`.

### Layout

Three floating pills at the top of the screen:

| Pill | Modules |
|---|---|
| Left | `hyprland/workspaces`, `hyprland/window` |
| Center | `clock` |
| Right | `pulseaudio`, `backlight`, `bluetooth`, `network`, `battery` |

### Styling

- Pills: `background-color: base00`, `border: 2px solid base02`,
  `border-radius: 999px`, `margin: 6px 0`
- All text: `base03` (matches inactive workspace button color)
- State overrides: `base08` for disconnected/critical, `base0A` for battery
  warning, `base0E` for active workspace
- Active workspace: `background-color: base02`, `color: base0E`

### Separators

Separators between right pill modules are embedded directly in each module's
format string (e.g. `"|  󰂯  {status}"`), so they disappear automatically
if a module is hidden (e.g. backlight on a machine with no screen).

### Clock

`format = "󰥔 {:%H:%M | 󰃭  %A, %B %d %Y}"` — 24-hour time and full spelled-out
date always visible. Hover tooltip shows a calendar.

## Applying Changes

```bash
sudo nixos-rebuild switch --flake ~/nixosConf#<hostname>
```

Or using the shell alias (uses current hostname automatically):
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
   directly in the host's module list.

## Adding a New Host

1. Create `modules/hosts/<hostname>/` with `default.nix`, `configuration.nix`,
   `hardware-configuration.nix`, and `disko.nix` — follow the `hm-pc-ws-01`
   pattern for disko-based hosts.
2. `import-tree` picks up all files automatically.
3. Reference `inputs.disko.nixosModules.disko` and the host's disko module in
   `default.nix`.
