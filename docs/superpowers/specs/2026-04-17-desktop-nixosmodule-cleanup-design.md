# Design: Clean up empty nixosModule stubs in desktop modules

## Summary

Remove four redundant `nixosModule` declarations from the desktop modules and
trim `nixosModules.metaHyprland` to only the three genuinely system-level
imports that remain.

## What Stays (system-level, correct as-is)

- `nixosModules.commonDesktop` — bluetooth, power-profiles, upower, fonts
- `nixosModules.hyprland` — `programs.hyprland.enable`, withUWSM, XDG paths
- `nixosModules.ly` — display manager
- `nixosModules.stylix` — system-wide theming

## Changes

### `waybar.nix` — delete empty nixosModule stub
Remove `flake.nixosModules.waybar = {...}: {};`. Keep `flake.homeModules.waybar` unchanged.

### `mako.nix` — delete empty nixosModule stub
Remove `flake.nixosModules.mako = {...}: {};`. Keep `flake.homeModules.mako` unchanged.

### `kitty.nix` — delete empty nixosModule stub
Remove `flake.nixosModules.kitty = {...}: {};`. Keep `flake.homeModules.kitty` unchanged.

### `nemo.nix` — move package to homeModule, delete nixosModule
Move `environment.systemPackages = [pkgs.nemo]` from `nixosModules.nemo` to
`homeModules.nemo` as `home.packages = [pkgs.nemo]`. Delete `nixosModules.nemo`.

### `hyprland/default.nix` — trim nixosModules.metaHyprland
Remove `waybar`, `mako`, `kitty`, `nemo` from `nixosModules.metaHyprland`
imports. Result:

```nix
flake.nixosModules.metaHyprland = {...}: {
  imports = [
    self.nixosModules.commonDesktop
    self.nixosModules.hyprland
    self.nixosModules.ly
  ];
};
```

`homeModules.metaHyprland` is unchanged.
