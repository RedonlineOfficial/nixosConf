{ self, inputs, ... }: {

  flake.nixosModules.metaHyprland = { ... }: {

    imports = [
      self.nixosModules.commonDesktop
      self.nixosModules.hyprland
      self.nixosModules.noctalia
      self.nixosModules.kitty
      self.nixosModules.dolphin
    ];

  };

  flake.homeModules.metaHyprland = { ... }: {

    imports = [
      self.homeModules.hyprland
      self.homeModules.noctalia
      self.homeModules.kitty
      self.homeModules.dolphin
    ];

  };

}
