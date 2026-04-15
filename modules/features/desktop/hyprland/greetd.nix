{ self, inputs, ... }: {

  flake.nixosModules.greetd = { lib, ... }: {

    programs.regreet = {
      enable = true;
      settings.GTK.application_prefer_dark_theme = lib.mkForce true;
    };

  };

}
