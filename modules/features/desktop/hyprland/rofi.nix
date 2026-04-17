{self, ...}: {
  flake.homeModules.rofi = {
    pkgs,
    config,
    ...
  }: let
    c = config.lib.stylix.colors;
    inherit (config.lib.formats.rasi) mkLiteral;
  in {
    home.packages = [
      pkgs.papirus-icon-theme
      (pkgs.writeShellScriptBin "rofi-power-menu" ''
        chosen=$(printf "󰐥  Shutdown\n󰜉  Reboot\n󰒲  Suspend\n󰋊  Hibernate\n󰍃  Logout" \
          | rofi -dmenu -p "󰐥  Power")
        case "$chosen" in
          *Shutdown)  systemctl poweroff ;;
          *Reboot)    systemctl reboot ;;
          *Suspend)   systemctl suspend ;;
          *Hibernate) systemctl hibernate ;;
          *Logout)    hyprctl dispatch exit ;;
        esac
      '')
    ];

    stylix.targets.rofi.enable = false;

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      terminal = "${pkgs.kitty}/bin/kitty";

      extraConfig = {
        show-icons = true;
        icon-theme = "Papirus-Dark";
        drun-display-format = "{name}";
        display-drun = "  Apps";
      };

      theme = {
        "*" = {
          background-color = mkLiteral "#${c.base00}";
          border-color = mkLiteral "#${c.base02}";
          text-color = mkLiteral "#${c.base05}";
          font = "FiraCode Nerd Font 12";
          margin = mkLiteral "0";
          padding = mkLiteral "0";
          spacing = mkLiteral "0";
        };

        "window" = {
          background-color = mkLiteral "#${c.base00}";
          border = mkLiteral "2px";
          border-radius = mkLiteral "12px";
          padding = mkLiteral "16px";
          width = mkLiteral "560px";
        };

        "inputbar" = {
          background-color = mkLiteral "#${c.base01}";
          border-radius = mkLiteral "8px";
          padding = mkLiteral "8px 12px";
          margin = mkLiteral "0 0 12px 0";
          spacing = mkLiteral "8px";
          children = mkLiteral "[prompt, entry]";
        };

        "prompt" = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "#${c.base0D}";
        };

        "entry" = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "#${c.base05}";
          placeholder-color = mkLiteral "#${c.base03}";
          placeholder = "Search...";
        };

        "listview" = {
          background-color = mkLiteral "transparent";
          lines = mkLiteral "8";
          columns = mkLiteral "1";
          spacing = mkLiteral "4px";
        };

        "element" = {
          background-color = mkLiteral "transparent";
          border-radius = mkLiteral "8px";
          padding = mkLiteral "8px";
          spacing = mkLiteral "10px";
          orientation = mkLiteral "horizontal";
        };

        "element selected" = {
          background-color = mkLiteral "#${c.base02}";
          text-color = mkLiteral "#${c.base0E}";
        };

        "element-icon" = {
          background-color = mkLiteral "transparent";
          size = mkLiteral "28px";
        };

        "element-text" = {
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "inherit";
          vertical-align = mkLiteral "0.5";
        };
      };
    };
  };
}
