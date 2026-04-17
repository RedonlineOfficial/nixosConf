# Design: Add homeModules.metaTerminal and eliminate nixosModules.metaTerminal

## Summary

Create `flake.homeModules.metaTerminal` that composes all three terminal
homeModules plus `lsd`, and remove the now-redundant
`flake.nixosModules.metaTerminal` entirely. This mirrors the
`metaHyprland` pattern where both NixOS and HM meta-modules live in
the same file — except here the NixOS side is no longer needed.

## Motivation

After converting git, zsh, and neovim to homeModules:
- `nixosModules.metaTerminal` only contained `lsd` (as a system package)
  and `programs.zoxide.enable = true` (already covered by `homeModules.zsh`)
- Both remaining items belong at the user level, not system level
- Eliminating the nixosModule removes the last NixOS-level terminal concern
  and gives `joshua/default.nix` a clean two-import HM section

## Changes

### `modules/features/terminal/default.nix`
- Delete `flake.nixosModules.metaTerminal`
- Add `flake.homeModules.metaTerminal` that:
  - Imports `self.homeModules.git`, `self.homeModules.zsh`, `self.homeModules.neovim`
  - Adds `home.packages = with pkgs; [lsd]`

Full file after change:

```nix
{
  self,
  inputs,
  ...
}: {
  flake.homeModules.metaTerminal = {pkgs, ...}: {
    imports = [
      self.homeModules.git
      self.homeModules.zsh
      self.homeModules.neovim
    ];

    home.packages = with pkgs; [
      lsd
    ];
  };
}
```

### `modules/users/joshua/default.nix`
- Remove `self.nixosModules.metaTerminal` from the NixOS-level imports
- Replace `self.homeModules.git`, `self.homeModules.zsh`,
  `self.homeModules.neovim` with `self.homeModules.metaTerminal` in
  the HM imports

## Result

`joshua/default.nix` HM imports become:
```nix
imports = [
  self.homeModules.metaHyprland
  self.homeModules.metaTerminal
];
```

`programs.zoxide.enable = true` is dropped from the NixOS level — it is
already present in `homeModules.zsh` via `programs.zoxide.enable = true`
and `programs.zoxide.enableZshIntegration = true`.
