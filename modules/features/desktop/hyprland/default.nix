{ self, inputs, ... }: {

  flake.nixosModules.metaHyprland = { ... }: {

    imports = [
      self.nixosModules.commonDesktop
      self.nixosModules.hyprland
      self.nixosModules.waybar
      self.nixosModules.mako
      self.nixosModules.kitty
      self.nixosModules.nemo
    ];

  };

  flake.homeModules.metaHyprland = { ... }: {

    imports = [
      self.homeModules.hyprland
      self.homeModules.waybar
      self.homeModules.mako
      self.homeModules.kitty
      self.homeModules.nemo
    ];

  };

}
