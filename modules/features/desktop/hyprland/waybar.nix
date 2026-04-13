{ self, inputs, ... }: {

  flake.nixosModules.waybar = { ... }: { };

  flake.homeModules.waybar = { pkgs, ... }: {

    stylix.targets.waybar.enable = true;

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
          background-color: transparent !important;
          color: @base05;
        }

        /* Pill containers for each group */
        .modules-left,
        .modules-center,
        .modules-right {
          background-color: @base00;
          border: 2px solid @base02;
          border-radius: 999px;
          margin: 6px 0;
          padding: 0 8px;
        }

        /* Workspace buttons */
        #workspaces button {
          padding: 0 10px;
          color: @base03;
          background-color: transparent;
          border-radius: 999px;
          margin: 4px 2px;
        }

        #workspaces button:hover {
          background-color: @base02;
          color: @base05;
        }

        #workspaces button.active {
          background-color: @base02;
          color: @base0E;
        }

        #workspaces button.urgent {
          background-color: @base08;
          color: @base05;
        }

        #window {
          padding: 0 12px;
          color: @base03;
        }

        #clock {
          padding: 0 16px;
          color: @base05;
        }

        #pulseaudio,
        #backlight,
        #bluetooth,
        #network,
        #battery {
          padding: 0 12px;
          color: @base05;
        }

        #pulseaudio.muted {
          color: @base03;
        }

        #bluetooth.off,
        #bluetooth.disabled {
          color: @base03;
        }

        #network.disconnected {
          color: @base08;
        }

        #battery.warning {
          color: @base0A;
        }

        #battery.critical {
          color: @base08;
        }
      '';
    };

  };

}
