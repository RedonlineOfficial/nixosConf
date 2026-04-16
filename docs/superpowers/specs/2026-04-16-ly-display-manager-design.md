# Replace greetd/regreet with Ly Display Manager

**Date:** 2026-04-16
**Status:** Approved

## Problem

greetd + regreet (via cage/Hyprland) had multi-monitor display issues.
Ly is a TUI display manager that Hyprland explicitly recommends and that
fits the workstation aesthetic better.

## Design

Replace the `greetd` NixOS module with a `ly` module. Three file changes:

### 1. Delete `modules/features/desktop/hyprland/greetd.nix`

Removes greetd service, regreet greeter, cage/Hyprland wrapper, and all
associated config.

### 2. Create `modules/features/desktop/hyprland/ly.nix`

Exposes `flake.nixosModules.ly`. The module body is a single option:

```nix
services.displayManager.ly.enable = true;
```

Ly's NixOS module (`services.displayManager.ly`) auto-configures:
- PAM service (`ly`)
- systemd `display-manager.service`
- Wayland session discovery via `services.displayManager.sessionData`
- Shutdown/restart commands via systemctl
- The greeter user

No additional settings needed for a standard Hyprland wayland session.

### 3. Update `modules/features/desktop/hyprland/default.nix`

Replace `self.nixosModules.greetd` with `self.nixosModules.ly` in the
`metaHyprland` imports list. No other host, user, or common modules change.

## Scope

- No changes to `commonConfiguration`, host modules, or user modules.
- No new dependencies — `ly` is already in nixpkgs unstable.
- The `greeter` system user created by greetd is replaced by Ly's own
  user management; no manual user declaration needed.
