# Design: Convert `neovim` from nixosModule to homeModule

## Summary

Convert `flake.nixosModules.neovim` to `flake.homeModules.neovim` as the third
step in the terminal modules refactor. This is the simplest conversion — nvf
exposes both `nixosModules.default` and `homeManagerModules.default`, and the
`programs.nvf` option set is identical in both contexts.

## Changes

### `modules/features/terminal/neovim.nix`
- Replace `flake.nixosModules.neovim` with `flake.homeModules.neovim`
- Swap `imports = [inputs.nvf.nixosModules.default]` → `imports = [inputs.nvf.homeManagerModules.default]`
- The `programs.nvf` config block is completely unchanged

### `modules/features/terminal/default.nix`
- Remove `self.nixosModules.neovim` from `metaTerminal` imports
- `metaTerminal` will now have no imports — only `lsd` package and `programs.zoxide.enable = true`

### `modules/users/joshua/default.nix`
- Add `self.homeModules.neovim` to `home-manager.users.joshua.imports`
- Temporary wiring until `metaTerminal` is converted

## Out of Scope

Collapsing the now import-free `metaTerminal` into `joshua/default.nix` — that
is a follow-on decision once all three terminal modules are converted.
