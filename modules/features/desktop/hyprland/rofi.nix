{ self, ... }: {

  flake.homeModules.rofi = { pkgs, ... }: {

    home.packages = [
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

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      terminal = "${pkgs.kitty}/bin/kitty";
    };

  };

}
