{ self, inputs, ... }: {

  flake.nixosModules.greetd = { pkgs, ... }: {

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --remember --cmd start-hyprland";
          user = "greeter";
        };
      };
    };

  };

}
