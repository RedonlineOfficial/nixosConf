# Monitor Configuration Design

**Date:** 2026-04-16
**Status:** Approved

## Overview

Dynamic monitor profile management for a laptop-on-dock setup using `nwg-displays`
as a GUI layout editor and `hyprdynamicmonitors` for automatic profile switching when
monitors connect or disconnect.

## Hardware Setup

- **Laptop built-in:** below primary external (eDP-1 or similar)
- **Primary external:** center
- **Left external:** to the left of primary
- **Right external:** vertical (rotated 90°), to the right of primary

## Architecture

### New module: `modules/features/desktop/hyprland/monitors.nix`

Exposes two flake outputs:

- **`nixosModules.monitors`** — no system-level config required; stub only
- **`homeModules.monitors`** — all configuration lives here:
  - Installs `nwg-displays` and `wlr-randr` as home packages (GUI editor + runtime query dep)
  - Installs `hyprdynamicmonitors`
  - Writes `hyprdynamicmonitors` profile config declaratively via `home.file`
  - Registers `hyprdynamicmonitors` as a systemd user service for lifecycle management

### Integration

`homeModules.monitors` is added to the imports list in
`modules/features/desktop/hyprland/default.nix` alongside `kitty`, `waybar`, etc.

## Profiles

Defined in `~/.config/hypr/dynamic-monitors.toml` (written by `home.file`).

### `docked`

Triggers when all three external monitors are connected.

| Monitor | Position | Rotation | Primary |
|---------|----------|----------|---------|
| Left external | left of primary | normal | no |
| Primary external | center | normal | yes |
| Right external | right of primary | 90° | no |
| Laptop built-in | below primary | normal | no |

### `undocked`

Triggers when no external monitors are connected.

| Monitor | Position | Rotation | Primary |
|---------|----------|----------|---------|
| Laptop built-in | 0x0 | normal | yes |

## Config Workflow

Monitor connector names (e.g. `DP-1`, `HDMI-1`, `eDP-1`) and exact
resolutions/refresh rates are filled in after running `hyprctl monitors`
while docked. Initial Nix config uses placeholder values that are updated
in a follow-up commit once the real values are known.

## Systemd User Service

`hyprdynamicmonitors` runs as a persistent daemon under systemd user session:

```
systemd.user.services.hyprdynamicmonitors = {
  Unit.Description = "Dynamic monitor configuration for Hyprland";
  Unit.After = [ "graphical-session.target" ];
  Unit.PartOf = [ "graphical-session.target" ];
  Service.ExecStart = "${pkgs.hyprdynamicmonitors}/bin/hyprdynamicmonitors";
  Service.Restart = "on-failure";
  Install.WantedBy = [ "graphical-session.target" ];
};
```

## Files Changed

| File | Change |
|------|--------|
| `modules/features/desktop/hyprland/monitors.nix` | New module |
| `modules/features/desktop/hyprland/default.nix` | Add `homeModules.monitors` to imports |
