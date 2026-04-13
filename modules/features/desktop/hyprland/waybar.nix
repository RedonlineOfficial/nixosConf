{ self, inputs, ... }: {

  flake.nixosModules.waybar = { ... }: { };

  flake.homeModules.waybar = { pkgs, config, ... }: {

    stylix.targets.waybar.enable = false;

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        targets = [ "hyprland-session.target" ];
      };

      settings = [{
        layer    = "top";
        position = "top";
        height   = 26;
        spacing  = 0;

        modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right  = [ "pulseaudio" "custom/sep" "backlight" "custom/sep" "bluetooth" "custom/sep" "network" "custom/sep" "battery" ];

        "hyprland/workspaces" = {
          format = "{icon}";
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
          };
          format-icons = {
            "1" = "";   # nf-dev-terminal
            "2" = "";   # nf-dev-terminal
            "3" = "󰈹"; # nf-md-firefox
            "4" = "󰍥"; # nf-md-message_text
            "5" = "󰇮"; # nf-md-email
            "6" = "⏺"; # nf-oct-dot_fill
            "7" = "⏺";
            "8" = "⏺";
            "9" = "⏺";
            "special:magic"    = "󰎚"; # nf-md-notebook
            "special:security" = "󰻫"; # nf-md-fingerprint
            "special:spotify"  = "󰓇"; # nf-md-spotify
            urgent = "";
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

        "custom/sep" = {
          format   = "|";
          interval = "once";
          tooltip  = false;
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

      style = with config.lib.stylix.colors; ''
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
          color: #${base05};
        }

        /* Pill containers for each group */
        .modules-left,
        .modules-center,
        .modules-right {
          background-color: #${base00};
          border: 2px solid #${base02};
          border-radius: 999px;
          margin: 6px 0;
          padding: 0 8px;
        }

        /* Workspace buttons */
        #workspaces button {
          padding: 0 5px;
          color: #${base03};
          background-color: transparent;
          border-radius: 999px;
          margin: 4px 2px;
        }

        #workspaces button:hover {
          background-color: #${base02};
          color: #${base05};
        }

        #workspaces button.active {
          background-color: #${base02};
          color: #${base0E};
        }

        #workspaces button.urgent {
          background-color: #${base08};
          color: #${base05};
        }

        #workspaces button.special {
          min-width: 0;
          padding: 0;
          margin: 0;
          opacity: 0;
        }

        #workspaces button.special.active {
          min-width: unset;
          padding: 0 5px;
          margin: 4px 2px;
          opacity: 1;
        }

        #window {
          padding: 0 5px;
          color: #${base03};
        }

        #clock {
          padding: 0 8px;
          color: #${base05};
        }

        #pulseaudio,
        #backlight,
        #bluetooth,
        #network,
        #battery {
          padding: 0 5px;
          color: #${base05};
        }

        #custom-sep {
          color: #${base02};
          padding: 0 2px;
        }

        #pulseaudio.muted {
          color: #${base03};
        }

        #bluetooth.off,
        #bluetooth.disabled {
          color: #${base03};
        }

        #network.disconnected {
          color: #${base08};
        }

        #battery.warning {
          color: #${base0A};
        }

        #battery.critical {
          color: #${base08};
        }
      '';
    };

  };

}
