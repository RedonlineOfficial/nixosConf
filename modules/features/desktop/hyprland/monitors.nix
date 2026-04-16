{ self, inputs, ... }: {

  flake.homeModules.monitors = { pkgs, ... }: {

    home.packages = with pkgs; [
      nwg-displays
      hyprdynamicmonitors
    ];

    home.file.".config/hyprdynamicmonitors/config.toml" = {
      force = true;
      text = ''
        [general]
        destination = "$HOME/.config/hypr/monitors.conf"

        [power_events]

        [power_events.dbus_query_object]
        path = "/org/freedesktop/UPower/devices/line_power_AC"

        [[power_events.dbus_signal_match_rules]]
        object_path = "/org/freedesktop/UPower/devices/line_power_AC"


        [profiles.docked]
        config_file = "$HOME/.config/hyprdynamicmonitors/hyprconfigs/docked.go.tmpl"
        config_file_type = "template"
        [profiles.docked.conditions]

        [[profiles.docked.conditions.required_monitors]]
        description = "AU Optronics 0xC693"
        monitor_tag = "monitor0"

        [[profiles.docked.conditions.required_monitors]]
        description = "Sceptre Tech Inc Sceptre F27"
        monitor_tag = "monitor1"

        [[profiles.docked.conditions.required_monitors]]
        description = "Lenovo Group Limited P24q-10 U4P00001"
        monitor_tag = "monitor2"

        [[profiles.docked.conditions.required_monitors]]
        description = "Sceptre Tech Inc Sceptre K27 0x00000001"
        monitor_tag = "monitor3"


        [profiles.undocked]
        config_file = "$HOME/.config/hyprdynamicmonitors/hyprconfigs/undocked.go.tmpl"
        config_file_type = "template"
        [profiles.undocked.conditions]

        [[profiles.undocked.conditions.required_monitors]]
        description = "AU Optronics 0xC693"
        monitor_tag = "monitor0"
      '';
    };

    home.file.".config/hyprdynamicmonitors/hyprconfigs/docked.go.tmpl" = {
      force = true;
      text = ''
        # Generated with hyprdynamicmonitors freeze.
        # This is a template that you can edit, it is just a starter that pulled your current monitor setup,
        # adjust as needed.
        # You can use templates here etc, see https://github.com/fiffeek/hyprdynamicmonitors/blob/main/examples/basic/hyprconfigs/template.go.tmpl.
        # Monitors are given arbitrary tags (the "monitor" prefix and the ID coming from hyprland).
        # If you are using tui to edit, leave this at the end of your file (the last monitor config applies)
        # and leave the markers.
        # <<<<< TUI AUTO START
        monitor=desc:AU Optronics 0xC693,3840x2400@60.00000,1920x1080,2.00000000,transform,0
        monitor=desc:Sceptre Tech Inc Sceptre F27,1920x1080@60.00000,3840x0,1.00000000,transform,1
        monitor=desc:Lenovo Group Limited P24q-10 U4P00001,1920x1080@60.00000,0x0,1.00000000,transform,0
        monitor=desc:Sceptre Tech Inc Sceptre K27 0x00000001,1920x1080@240.00000,1920x0,1.00000000,transform,0
        # <<<<< TUI AUTO END
      '';
    };

    home.file.".config/hyprdynamicmonitors/hyprconfigs/undocked.go.tmpl" = {
      force = true;
      text = ''
        # Generated with hyprdynamicmonitors freeze.
        # This is a template that you can edit, it is just a starter that pulled your current monitor setup,
        # adjust as needed.
        # You can use templates here etc, see https://github.com/fiffeek/hyprdynamicmonitors/blob/main/examples/basic/hyprconfigs/template.go.tmpl.
        # Monitors are given arbitrary tags (the "monitor" prefix and the ID coming from hyprland).
        # If you are using tui to edit, leave this at the end of your file (the last monitor config applies)
        # and leave the markers.
        # <<<<< TUI AUTO START
        monitor=desc:AU Optronics 0xC693,3840x2400@60.00400,0x0,2.00000000,transform,0,vrr,0
        # <<<<< TUI AUTO END
      '';
    };

    wayland.windowManager.hyprland.extraConfig = ''
      source = ~/.config/hypr/monitors.conf
    '';

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
