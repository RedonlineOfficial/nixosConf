# Desktop nixosModule Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove four redundant/empty `nixosModule` declarations from desktop modules and trim `nixosModules.metaHyprland` to only the three system-level modules that remain.

**Architecture:** Five file edits — remove empty nixosModule stubs from waybar/mako/kitty, move nemo's package to the homeModule and delete its nixosModule, then strip the dead imports from `nixosModules.metaHyprland`. All homeModule content is untouched.

**Tech Stack:** Nix, flake-parts, import-tree, home-manager

---

## File Map

| File | Change |
|---|---|
| `modules/features/desktop/hyprland/waybar.nix` | Remove empty `nixosModules.waybar` stub |
| `modules/features/desktop/hyprland/mako.nix` | Remove empty `nixosModules.mako` stub |
| `modules/features/desktop/hyprland/kitty.nix` | Remove empty `nixosModules.kitty` stub |
| `modules/features/desktop/hyprland/nemo.nix` | Move package to homeModule, delete nixosModule |
| `modules/features/desktop/hyprland/default.nix` | Trim nixosModules.metaHyprland imports |

---

### Task 1: Create branch

- [ ] **Create and switch to a new branch**

```bash
git checkout -b refactor/desktop-nixosmodule-cleanup
```

---

### Task 2: Remove empty nixosModule stubs (waybar, mako, kitty)

**Files:**
- Modify: `modules/features/desktop/hyprland/waybar.nix`
- Modify: `modules/features/desktop/hyprland/mako.nix`
- Modify: `modules/features/desktop/hyprland/kitty.nix`

- [ ] **Replace waybar.nix — remove the empty nixosModule, keep homeModule**

```nix
{
  self,
  inputs,
  ...
}: {
  flake.homeModules.waybar = {
    pkgs,
    config,
    ...
  }: {
    stylix.targets.waybar.enable = false;

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        targets = ["hyprland-session.target"];
      };

      settings = [
        {
          layer = "top";
          position = "top";
          height = 26;
          spacing = 0;

          modules-left = ["hyprland/workspaces" "hyprland/window"];
          modules-center = ["clock"];
          modules-right = ["pulseaudio" "backlight" "bluetooth" "network" "battery"];

          "hyprland/workspaces" = {
            format = "{icon}";
            persistent-workspaces = {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
            };
            format-icons = {
              "1" = ""; # nf-dev-terminal
              "2" = ""; # nf-dev-terminal
              "3" = "󰈹"; # nf-md-firefox
              "4" = "󰍥"; # nf-md-message_text
              "5" = "󰇮"; # nf-md-email
              "6" = "⏺"; # nf-oct-dot_fill
              "7" = "⏺";
              "8" = "⏺";
              "9" = "⏺";
              "special:magic" = "󰎚"; # nf-md-notebook
              "special:security" = "󰻫"; # nf-md-fingerprint
              "special:spotify" = "󰓇"; # nf-md-spotify
              urgent = "";
            };
          };

          "hyprland/window" = {
            max-length = 60;
          };

          clock = {
            format = "󰥔 {:%H:%M | 󰃭  %A, %B %d %Y}";
            tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          };

          pulseaudio = {
            format = "{icon}  {volume}%";
            format-muted = "󰝟  Muted";
            format-icons.default = ["󰕿" "󰖀" "󰕾"];
            on-click = "pavucontrol";
          };

          backlight = {
            format = "|  {icon}  {percent}%";
            format-icons = ["󰃞" "󰃟" "󰃠"];
          };

          bluetooth = {
            format = "|  󰂯  {status}";
            format-connected = "|  󰂱  {device_alias}";
            format-off = "|  󰂲  Off";
            on-click = "pkill bluetui || kitty --class bluetui -e bluetui";
          };

          network = {
            format-wifi = "|  󰤨  {essid}";
            format-ethernet = "|  󰈀  Ethernet";
            format-disconnected = "|  󰤭  Disconnected";
            tooltip-format = "{ifname}: {ipaddr}";
          };

          battery = {
            format = "|  {icon}  {capacity}%";
            format-charging = "|  󰂄  {capacity}%";
            format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            states = {
              warning = 30;
              critical = 15;
            };
          };
        }
      ];

      style = with config.lib.stylix.colors; ''
        * {
          font-family: "Hack Nerd Font Mono";
          font-size: 13px;
          border: none;
          border-radius: 0;
          min-height: 0;
          padding: 0;
          margin: 0;
        }

        window#waybar {
          background-color: transparent;
          color: #${base05};
        }

        /* Pill containers for each group */
        .modules-left,
        .modules-center,
        .modules-right {
          background-color: #${base00};
          border: 2px solid #${base02};
          border-radius: 999px;
          margin: 6px 0;
          padding: 0 8px;
        }

        /* Workspace buttons */
        #workspaces button {
          padding: 0 5px;
          color: #${base03};
          background-color: transparent;
          border-radius: 999px;
          margin: 4px 2px;
        }

        #workspaces button:hover {
          background-color: #${base02};
          color: #${base05};
        }

        #workspaces button.active {
          background-color: #${base02};
          color: #${base0E};
        }

        #workspaces button.urgent {
          background-color: #${base08};
          color: #${base05};
        }

        #workspaces button.special {
          min-width: 0;
          padding: 0;
          margin: 0;
          opacity: 0;
        }

        #workspaces button.special.active {
          min-width: unset;
          padding: 0 5px;
          margin: 4px 2px;
          opacity: 1;
        }

        #window {
          padding: 0 5px;
          color: #${base03};
        }

        #clock {
          padding: 0 8px;
          color: #${base03};
        }

        #pulseaudio,
        #backlight,
        #bluetooth,
        #network,
        #battery {
          padding: 0 5px;
          color: #${base03};
        }

        #pulseaudio.muted {
          color: #${base03};
        }

        #bluetooth.off,
        #bluetooth.disabled {
          color: #${base03};
        }

        #network.disconnected {
          color: #${base08};
        }

        #battery.warning {
          color: #${base0A};
        }

        #battery.critical {
          color: #${base08};
        }
      '';
    };
  };
}
```

- [ ] **Replace mako.nix — remove the empty nixosModule, keep homeModule**

```nix
{
  self,
  inputs,
  ...
}: {
  flake.homeModules.mako = {...}: {
    services.mako = {
      enable = true;
    };
  };
}
```

- [ ] **Replace kitty.nix — remove the empty nixosModule, keep homeModule**

```nix
{
  self,
  inputs,
  ...
}: {
  flake.homeModules.kitty = {...}: {
    programs.kitty = {
      enable = true;

      settings = {
        scrollback_lines = 10000;
        scrollback_pager_history_size = 10;
        scrollback_fill_enlarged_window = true;

        enabled_layouts = "splits";

        tab_bar_edge = "top";
        tab_bar_style = "custom";
        tab_bar_min_tabs = 1;

        startup_session = "kitty.session";
      };

      keybindings = {
        # OS window / tab management
        "ctrl+shift+n" = "new_os_window_with_cwd";
        "ctrl+shift+q" = "close_window";
        "ctrl+shift+]" = "next_tab";
        "ctrl+shift+[" = "previous_tab";

        # Window splits (vim-like)
        "ctrl+shift+backslash" = "launch --location=vsplit --cwd=current";
        "ctrl+shift+minus" = "launch --location=hsplit --cwd=current";

        # Window focus (vim-like hjkl — remaps kitty defaults)
        "ctrl+shift+h" = "neighboring_window left";
        "ctrl+shift+j" = "neighboring_window bottom";
        "ctrl+shift+k" = "neighboring_window top";
        "ctrl+shift+l" = "neighboring_window right";
      };
    };

    home.file.".config/kitty/kitty.session".text = ''
      # Tab 1: NixOS config workspace
      new_tab nixosConf
      cd ~/nixosConf
      layout splits
      launch zsh
      launch --location=vsplit claude

      # Tab 2: Default terminal (focus marks this as the active tab on startup)
      new_tab Terminal
      cd ~
      launch zsh
      focus
    '';

    home.file.".config/kitty/tab_bar.py".text = ''
      from datetime import datetime
      from kitty.fast_data_types import Screen
      from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

      # Nerd Font symbols
      SEPARATOR = ""   # powerline solid right arrow
      CLOCK     = "󰥔"  # nf-md-clock
      CALENDAR  = "󰃭"  # nf-md-calendar


      def draw_tab(
          draw_data: DrawData,
          screen: Screen,
          tab: TabBarData,
          before_first_tab: bool,
          max_tab_length: int,
          index: int,
          is_last: bool,
          extra_data: ExtraData,
      ) -> int:
          if tab.is_active:
              tab_fg = as_rgb(int(draw_data.active_fg))
              tab_bg = as_rgb(int(draw_data.active_bg))
          else:
              tab_fg = as_rgb(int(draw_data.inactive_fg))
              tab_bg = as_rgb(int(draw_data.inactive_bg))

          bar_bg = as_rgb(int(draw_data.default_bg))
          bar_fg = as_rgb(int(draw_data.inactive_fg))

          # Tab label
          screen.cursor.fg = tab_fg
          screen.cursor.bg = tab_bg
          screen.draw(f"  {tab.title} ")

          # Powerline separator
          screen.cursor.fg = tab_bg
          screen.cursor.bg = bar_bg
          screen.draw(SEPARATOR)

          end_x = screen.cursor.x

          # Clock and date on the right, drawn after the last tab
          if is_last:
              now = datetime.now()
              right = f"  {CALENDAR} {now.strftime('%a %d %b')}  {CLOCK} {now.strftime('%H:%M')}  "
              x = screen.columns - len(right)
              if x > end_x:
                  screen.cursor.x = x
                  screen.cursor.fg = bar_fg
                  screen.cursor.bg = bar_bg
                  screen.draw(right)

          return end_x
    '';
  };
}
```

---

### Task 3: Move nemo package to homeModule

**Files:**
- Modify: `modules/features/desktop/hyprland/nemo.nix`

- [ ] **Replace nemo.nix — delete nixosModule, add nemo package to homeModule**

```nix
{
  self,
  inputs,
  ...
}: {
  flake.homeModules.nemo = {pkgs, ...}: {
    home.packages = [pkgs.nemo];

    # Nemo is GTK3 — Stylix themes it automatically via stylix.targets.gtk (enabled by default).
    gtk.iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };
}
```

---

### Task 4: Trim nixosModules.metaHyprland

**Files:**
- Modify: `modules/features/desktop/hyprland/default.nix`

- [ ] **Remove waybar, mako, kitty, nemo from nixosModules.metaHyprland imports**

Change the `nixosModules.metaHyprland` imports block from:

```nix
  flake.nixosModules.metaHyprland = {...}: {
    imports = [
      self.nixosModules.commonDesktop
      self.nixosModules.hyprland
      self.nixosModules.ly
      self.nixosModules.waybar
      self.nixosModules.mako
      self.nixosModules.kitty
      self.nixosModules.nemo
    ];
  };
```

To:

```nix
  flake.nixosModules.metaHyprland = {...}: {
    imports = [
      self.nixosModules.commonDesktop
      self.nixosModules.hyprland
      self.nixosModules.ly
    ];
  };
```

Leave `flake.homeModules.metaHyprland` completely unchanged.

---

### Task 5: Commit and validate

- [ ] **Stage and commit**

```bash
git add modules/features/desktop/hyprland/waybar.nix \
        modules/features/desktop/hyprland/mako.nix \
        modules/features/desktop/hyprland/kitty.nix \
        modules/features/desktop/hyprland/nemo.nix \
        modules/features/desktop/hyprland/default.nix
git -c commit.gpgsign=false commit -m "refactor: remove empty nixosModule stubs from desktop modules"
```

- [ ] **Ask user to run rebuild**

```bash
rebuild
```

Expected: build succeeds. Verify desktop environment launches normally (waybar, mako, kitty, nemo all functional).

---

### Task 6: Merge to main

*Only after rebuild succeeds.*

- [ ] **Merge branch and delete it**

```bash
git checkout main
git merge refactor/desktop-nixosmodule-cleanup
git branch -d refactor/desktop-nixosmodule-cleanup
```
