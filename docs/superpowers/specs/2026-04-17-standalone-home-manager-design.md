# Standalone Home Manager Design

**Date:** 2026-04-17
**Status:** Approved

## Goal

Enable `home-manager switch` as a fast path for dotfile changes, while keeping `nixos-rebuild` as the single command for full system changes. Both paths use the same home configuration — no duplication.

## Current State

`modules/users/joshua/default.nix` defines `flake.nixosModules.joshua`, which contains:
- NixOS user config (user creation, groups, shell, packages, SSH keys, sudo)
- `home-manager.users.joshua` block (GPG, gtk, sshcontrol, imports of `metaHyprland` + `metaTerminal`)

Host configs (`nixos-demo`, `hm-pc-ws-01`) include `inputs.home-manager.nixosModules.home-manager` and `useGlobalPkgs`/`useUserPackages` settings.

`flake.nix` already imports `inputs.home-manager.flakeModules.default`, so `flake.homeConfigurations` is already a recognised output type.

## Approach

Extract the home-manager config into a shared `homeModule`, then wire it into both the NixOS integration and a new standalone `homeConfigurations` entry.

## Module Restructuring

`modules/users/joshua/default.nix` will define three things (same file, following the pattern of `hyprland/default.nix`):

### `flake.nixosModules.joshua` (NixOS-level only)

Keeps: user creation, groups, shell, packages, SSH authorized keys, sudo config.

The `home-manager.users.joshua` block shrinks to:
```nix
home-manager.users.joshua.imports = [ self.homeModules.joshuaHome ];
```

### `flake.homeModules.joshuaHome` (single source of truth)

Contains everything currently in `home-manager.users.joshua`:
- `home.username`, `home.homeDirectory`, `home.stateVersion`
- `imports = [ self.homeModules.metaHyprland self.homeModules.metaTerminal ]`
- `gtk.gtk4.theme = null`
- `programs.gpg` config (public key, scdaemon settings)
- `home.file.".gnupg/sshcontrol"`

### `flake.homeConfigurations.joshua` (standalone entrypoint)

```nix
flake.homeConfigurations.joshua = inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  extraSpecialArgs = { inherit inputs self; };
  modules = [ self.homeModules.joshuaHome ];
};
```

## Host Configs

`nixos-demo/default.nix` and `hm-pc-ws-01/default.nix` are **unchanged**. The NixOS home-manager module and `useGlobalPkgs`/`useUserPackages` settings remain as-is.

## Workflow After Change

| Scenario | Command |
|---|---|
| Dotfile / home config change | `home-manager switch --flake ~/nixosConf#joshua` |
| Full system change | `rebuild` (same as today) |

## Gotcha: pkgs Difference Between Paths

`useGlobalPkgs = true` means the NixOS path inherits system `pkgs` (including the `claude-code` overlay). The standalone path uses `inputs.nixpkgs.legacyPackages.x86_64-linux` with no overlays applied.

In practice this has no effect — `claude-code` and other overlay packages are installed via `users.users.joshua.packages` on the NixOS side, not through any home module. If a home module ever needs an overlay package, the overlay would need to be applied to the standalone `pkgs` as well.

## Git Note

Because NixOS flakes use git to determine included files, changes to `default.nix` must be staged or committed before running `home-manager switch` for the first time.
