# Design: Convert `git` from nixosModule to homeModule

## Summary

Convert `flake.nixosModules.git` to `flake.homeModules.git` as the first step
in a broader refactor to move user-specific terminal modules out of the NixOS
module system and into home-manager.

## Motivation

Git configuration (username, email, signing key, commit template) is
inherently per-user. There is no system-level git configuration needed.
Having it as a nixosModule is semantically wrong and prevents per-user
customization in a multi-user future.

## Changes

### `modules/features/terminal/git.nix`
- Replace `flake.nixosModules.git` with `flake.homeModules.git`
- The `programs.git` config block is unchanged

### `modules/features/terminal/default.nix`
- Remove `self.nixosModules.git` from `metaTerminal` imports
- `metaTerminal` remains a nixosModule for now (zsh/neovim not yet converted)

### `modules/users/joshua/default.nix`
- Add `self.homeModules.git` to `home-manager.users.joshua.imports`
- This is temporary wiring until `metaTerminal` is also converted to a homeModule,
  at which point `git` will move into `metaTerminal`'s HM imports instead

## Out of Scope

Conversion of `zsh`, `neovim`, and `metaTerminal` — these are follow-on work
once this change is validated.
