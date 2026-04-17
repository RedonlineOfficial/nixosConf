{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.metaHyprland = {...}: {
    imports = [
      self.nixosModules.commonDesktop
      self.nixosModules.hyprland
      self.nixosModules.ly
    ];
  };

  flake.homeModules.metaHyprland = {...}: {
    imports = [
      self.homeModules.commonDesktop
      self.homeModules.hyprland
      self.homeModules.waybar
      self.homeModules.mako
      self.homeModules.kitty
      self.homeModules.nemo
      self.homeModules.rofi
      self.homeModules.monitors
    ];
  };
}
