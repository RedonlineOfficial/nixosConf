{ self, inputs, ... }: {

  flake.nixosModules.waybar = { ... }: { };

  flake.homeModules.waybar = { pkgs, ... }: {

    stylix.targets.waybar.enable = false;

    programs.waybar = {
      enable = true;
      systemd.enable = true;

      settings = [{
        layer    = "top";
        position = "top";
        height   = 36;
        spacing  = 4;

        modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right  = [ "pulseaudio" "backlight" "bluetooth" "network" "battery" ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            default = "";
            active  = "";
            urgent  = "";
          };
        };

        "hyprland/window" = {
          max-length = 60;
        };

        clock = {
          format     = "  {:%I:%M %p}";
          format-alt = "󰃭  {:%A, %B %d %Y}";
          tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
        };

        pulseaudio = {
          format        = "{icon}  {volume}%";
          format-muted  = "󰝟  Muted";
          format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
          on-click = "pavucontrol";
        };

        backlight = {
          format       = "{icon}  {percent}%";
          format-icons = [ "󰃞" "󰃟" "󰃠" ];
        };

        bluetooth = {
          format           = "󰂯  {status}";
          format-connected = "󰂱  {device_alias}";
          format-off       = "󰂲  Off";
          on-click         = "blueman-manager";
        };

        network = {
          format-wifi        = "󰤨  {essid}";
          format-ethernet    = "󰈀  Ethernet";
          format-disconnected = "󰤭  Disconnected";
          tooltip-format     = "{ifname}: {ipaddr}";
        };

        battery = {
          format          = "{icon}  {capacity}%";
          format-charging = "󰂄  {capacity}%";
          format-icons    = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          states = {
            warning  = 30;
            critical = 15;
          };
        };
      }];

      style = ''
        * {
          font-family: "Hack Nerd Font Mono";
          font-size: 13px;
          border: none;
          border-radius: 0;
          min-height: 0;
          padding: 0;
          margin: 0;
        }

        window#waybar {
          background-color: transparent;
          color: #f8f8f2;
        }

        /* Pill containers for each group */
        .modules-left,
        .modules-center,
        .modules-right {
          background-color: #282a36;
          border-radius: 999px;
          margin: 6px 0;
          padding: 0 8px;
        }

        /* Workspace buttons */
        #workspaces button {
          padding: 0 10px;
          color: #9ea8c7;
          background-color: transparent;
          border-radius: 999px;
          margin: 4px 2px;
        }

        #workspaces button:hover {
          background-color: #44475a;
          color: #f8f8f2;
        }

        #workspaces button.active {
          background-color: #44475a;
          color: #bd93f9;
        }

        #workspaces button.urgent {
          background-color: #ff5555;
          color: #f8f8f2;
        }

        #window {
          padding: 0 12px;
          color: #9ea8c7;
        }

        #clock {
          padding: 0 16px;
          color: #f8f8f2;
        }

        #pulseaudio,
        #backlight,
        #bluetooth,
        #network,
        #battery {
          padding: 0 12px;
          color: #f8f8f2;
        }

        #pulseaudio.muted {
          color: #6272a4;
        }

        #bluetooth.off,
        #bluetooth.disabled {
          color: #6272a4;
        }

        #network.disconnected {
          color: #ff5555;
        }

        #battery.warning {
          color: #f1fa8c;
        }

        #battery.critical {
          color: #ff5555;
        }
      '';
    };

  };

}
