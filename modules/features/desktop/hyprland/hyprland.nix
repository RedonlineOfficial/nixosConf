{ self, inputs, ... }: {

  flake.nixosModules.hyprland = { ... }: {

    programs.hyprland.enable = true;

  };

}
