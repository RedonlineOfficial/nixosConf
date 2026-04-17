# Design: Convert `zsh` from nixosModule to homeModule

## Summary

Convert `flake.nixosModules.zsh` to `flake.homeModules.zsh` as the second step
in the terminal modules refactor. Unlike `git`, this requires remapping several
option names between the NixOS and home-manager zsh module APIs.

## Motivation

Zsh shell configuration (aliases, functions, prompt, history settings) is
user-specific. There is no reason for it to live at the system level. Moving it
to home-manager gives it the correct scope.

## Option Name Mapping

| NixOS option | Home-manager equivalent |
|---|---|
| `programs.zsh.histSize` | `programs.zsh.history.size` |
| `programs.zsh.setOptions` | `programs.zsh.setOptions` (unchanged) |
| `programs.zsh.shellAliases` | `programs.zsh.shellAliases` (unchanged) |
| `programs.zsh.interactiveShellInit` | `programs.zsh.initExtra` |
| `programs.zsh.promptInit = ""` | dropped (no HM equivalent, was empty) |

The HM module also requires `programs.zsh.enable = true` (distinct from the
NixOS-level `programs.zsh.enable = true` already in `joshua/default.nix`).

The `config.lib.stylix.colors` reference works in HM context unchanged.

## Changes

### `modules/features/terminal/zsh.nix`
- Replace `flake.nixosModules.zsh` with `flake.homeModules.zsh`
- Add `programs.zsh.enable = true`
- Remap options per the table above
- Move `programs.zoxide.enableZshIntegration = true` here from `metaTerminal`
  (zoxide's zsh integration hooks into the user shell, so it belongs in the HM module)

### `modules/features/terminal/default.nix`
- Remove `self.nixosModules.zsh` from `metaTerminal` imports
- Remove `programs.zoxide.enableZshIntegration = true` (moving to HM zsh module)
- Keep `environment.systemPackages = [lsd]` and `programs.zoxide.enable = true`
  (enabling zoxide system-wide stays at NixOS level)

### `modules/users/joshua/default.nix`
- Add `self.homeModules.zsh` to `home-manager.users.joshua.imports`
- Temporary wiring until `metaTerminal` is converted to a homeModule

## Out of Scope

Conversion of `neovim` and `metaTerminal` — follow-on work.
