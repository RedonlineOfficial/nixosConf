{ self, inputs, ... }: {

  flake.nixosModules.hyprland = { ... }: {

    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

  };

  flake.homeModules.hyprland = { pkgs, ... }: {

    home.packages = with pkgs; [
      brightnessctl
      playerctl
      bluetui
      wl-clipboard
    ];

    wayland.windowManager.hyprland = {
      enable = true;

      settings = {

        "exec-once" = [
          "[workspace 1 silent] kitty"
          "[workspace 2 silent] kitty"
          "[workspace 3 silent] firefox"
          "[workspace 5 silent] proton-mail"
          "[workspace special:magic silent] kitty"
          "[workspace special:security silent] bitwarden"
          "[workspace special:security silent] yubioath-flutter"
          "[workspace special:spotify silent] spotify"
        ];

        "$mainMod"     = "SUPER";
        "$terminal"    = "kitty";
        "$browser"     = "firefox";
        "$fileExplorer" = "nemo";
        "$launcher"    = "rofi -show drun";

        bind = [
          # General
          "$mainMod, Q, killactive"
          "$mainMod SHIFT, Q, exec, rofi-power-menu"
          "$mainMod SHIFT, F, togglefloating"
          "$mainMod SHIFT, W, exec, pkill waybar && waybar"

          # Programs
          "$mainMod, Return, exec, $terminal"
          "$mainMod, Space, exec, pkill $launcher || $launcher"
          "$mainMod, B, exec, $browser"
          "$mainMod, E, exec, $fileExplorer"

          # Move Focus
          "$mainMod, h, movefocus, l"
          "$mainMod, j, movefocus, d"
          "$mainMod, k, movefocus, u"
          "$mainMod, l, movefocus, r"
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"

          # Move Window
          "$mainMod SHIFT, h, movewindow, l"
          "$mainMod SHIFT, j, movewindow, d"
          "$mainMod SHIFT, k, movewindow, u"
          "$mainMod SHIFT, l, movewindow, r"
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"

          # Special workspaces
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod, A, togglespecialworkspace, security"
          "$mainMod, M, togglespecialworkspace, spotify"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        bindel = [
          # Volume
          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          # Brightness
          ",XF86MonBrightnessUp, exec, brightnessctl -n2 set 5%+"
          ",XF86MonBrightnessDown, exec, brightnessctl -n2 set 5%-"
          "$mainMod, XF86MonBrightnessUp, exec, brightnessctl -n2 set 100%"
          "$mainMod, XF86MonBrightnessDown, exec, brightnessctl -n2 set 10%"
        ];

        bindl = [
          # Media
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPause, exec, playerctl play-pause"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
        ];

        general = {
          gaps_out = 7;
          border_size = 1;
          resize_on_border = true;
        };

        decoration = {
          rounding = 10;
          blur.size = 3;
        };

        animations = {
          enabled = true;
          bezier = [
            "easeOutQuint,   0.23, 1,    0.32, 1"
            "easeInOutCubic, 0.65, 0.05, 0.36, 1"
            "linear,         0,    0,    1,    1"
            "almostLinear,   0.5,  0.5,  0.75, 1"
            "quick,          0.15, 0,    0.1,  1"
          ];
          animation = [
            "global,        1,     10,    default"
            "border,        1,     5.39,  easeOutQuint"
            "windows,       1,     4.79,  easeOutQuint"
            "windowsIn,     1,     4.1,   easeOutQuint, popin 87%"
            "windowsOut,    1,     1.49,  linear,       popin 87%"
            "fadeIn,        1,     1.73,  almostLinear"
            "fadeOut,       1,     1.46,  almostLinear"
            "fade,          1,     3.03,  quick"
            "layers,        1,     3.81,  easeOutQuint"
            "layersIn,      1,     4,     easeOutQuint, fade"
            "layersOut,     1,     1.5,   linear,       fade"
            "fadeLayersIn,  1,     1.79,  almostLinear"
            "fadeLayersOut, 1,     1.39,  almostLinear"
            "workspaces,    1,     1.94,  almostLinear, fade"
            "workspacesIn,  1,     1.21,  almostLinear, fade"
            "workspacesOut, 1,     1.94,  almostLinear, fade"
            "zoomFactor,    1,     7,     quick"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        misc = {
          force_default_wallpaper = 1;
          disable_hyprland_logo = true;
        };

        workspace = [
          "1, monitor:desc:Sceptre Tech Inc Sceptre K27 0x00000001, default:true"
          "2, monitor:desc:Sceptre Tech Inc Sceptre K27 0x00000001"
          "3, monitor:desc:Sceptre Tech Inc Sceptre F27"
          "4, monitor:desc:Lenovo Group Limited P24q-10 U4P00001"
          "5, monitor:desc:AU Optronics 0xC693"
        ];

      };

      extraConfig = ''
        windowrule {
            name = suppress-maximize-events
            match:class = .*
            suppress_event = maximize
        }

        windowrule {
            name = fix-xwayland-drags
            match:class = ^$
            match:title = ^$
            match:xwayland = true
            match:float = true
            match:fullscreen = false
            match:pin = false
            no_focus = true
        }

        windowrule {
            name = move-hyprland-run
            match:class = hyprland-run
            move = 20 monitor_h-120
            float = yes
        }

        windowrule {
            name = bluetui-popup
            match:class = bluetui
            float = yes
            size = 640 400
            move = monitor_w-660 40
        }
      '';
    };

  };

}
