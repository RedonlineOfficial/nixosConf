{ self, inputs, ... }: {

  flake.nixosModules.greetd = { lib, pkgs, ... }: {

    programs.regreet = {
      enable = true;
      settings.GTK.application_prefer_dark_theme = lib.mkForce true;
    };

    # Override greetd session to use Hyprland instead of cage.
    # cage is a single-output compositor that treats all monitors as one display.
    services.greetd.settings.default_session = lib.mkForce {
      user = "greeter";
      command =
        let
          hyprConf = pkgs.writeText "greetd-hyprland.conf" ''
            monitor=,preferred,auto,1

            exec-once = ${pkgs.greetd.regreet}/bin/regreet; hyprctl dispatch exit 0

            misc {
              disable_hyprland_logo = true
              disable_splash_rendering = true
              force_default_wallpaper = 0
            }
          '';
        in "${pkgs.hyprland}/bin/Hyprland --config ${hyprConf}";
    };

  };

}
