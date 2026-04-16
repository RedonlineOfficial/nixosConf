{ self, inputs, ... }: {

  flake.homeModules.monitors = { pkgs, ... }: {

    home.packages = with pkgs; [
      nwg-displays
      hyprdynamicmonitors
    ];

    systemd.user.services.hyprdynamicmonitors = {
      Unit = {
        Description = "Dynamic monitor configuration for Hyprland";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.hyprdynamicmonitors}/bin/hyprdynamicmonitors run --enable-lid-events";
        Restart = "on-failure";
        RestartSec = "3s";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

  };

}
