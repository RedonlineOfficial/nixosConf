{
  self,
  inputs,
  ...
}: {
  flake.homeModules.kitty = {...}: {
    programs.kitty = {
      enable = true;

      settings = {
        scrollback_lines = 10000;
        scrollback_pager_history_size = 10;
        scrollback_fill_enlarged_window = true;

        enabled_layouts = "splits";

        tab_bar_edge = "top";
        tab_bar_style = "custom";
        tab_bar_min_tabs = 1;

        startup_session = "kitty.session";
      };

      keybindings = {
        # OS window / tab management
        "ctrl+shift+n" = "new_os_window_with_cwd";
        "ctrl+shift+q" = "close_window";
        "ctrl+shift+]" = "next_tab";
        "ctrl+shift+[" = "previous_tab";

        # Window splits (vim-like)
        "ctrl+shift+backslash" = "launch --location=vsplit --cwd=current";
        "ctrl+shift+minus" = "launch --location=hsplit --cwd=current";

        # Window focus (vim-like hjkl — remaps kitty defaults)
        "ctrl+shift+h" = "neighboring_window left";
        "ctrl+shift+j" = "neighboring_window bottom";
        "ctrl+shift+k" = "neighboring_window top";
        "ctrl+shift+l" = "neighboring_window right";
      };
    };

    home.file.".config/kitty/kitty.session".text = ''
      # Tab 1: NixOS config workspace
      new_tab nixosConf
      cd ~/nixosConf
      layout splits
      launch zsh
      launch --location=vsplit claude

      # Tab 2: Default terminal (focus marks this as the active tab on startup)
      new_tab Terminal
      cd ~
      launch zsh
      focus
    '';

    home.file.".config/kitty/tab_bar.py".text = ''
      from datetime import datetime
      from kitty.fast_data_types import Screen
      from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb

      # Nerd Font symbols
      SEPARATOR = ""   # powerline solid right arrow
      CLOCK     = "󰥔"  # nf-md-clock
      CALENDAR  = "󰃭"  # nf-md-calendar


      def draw_tab(
          draw_data: DrawData,
          screen: Screen,
          tab: TabBarData,
          before_first_tab: bool,
          max_tab_length: int,
          index: int,
          is_last: bool,
          extra_data: ExtraData,
      ) -> int:
          if tab.is_active:
              tab_fg = as_rgb(int(draw_data.active_fg))
              tab_bg = as_rgb(int(draw_data.active_bg))
          else:
              tab_fg = as_rgb(int(draw_data.inactive_fg))
              tab_bg = as_rgb(int(draw_data.inactive_bg))

          bar_bg = as_rgb(int(draw_data.default_bg))
          bar_fg = as_rgb(int(draw_data.inactive_fg))

          # Tab label
          screen.cursor.fg = tab_fg
          screen.cursor.bg = tab_bg
          screen.draw(f"  {tab.title} ")

          # Powerline separator
          screen.cursor.fg = tab_bg
          screen.cursor.bg = bar_bg
          screen.draw(SEPARATOR)

          end_x = screen.cursor.x

          # Clock and date on the right, drawn after the last tab
          if is_last:
              now = datetime.now()
              right = f"  {CALENDAR} {now.strftime('%a %d %b')}  {CLOCK} {now.strftime('%H:%M')}  "
              x = screen.columns - len(right)
              if x > end_x:
                  screen.cursor.x = x
                  screen.cursor.fg = bar_fg
                  screen.cursor.bg = bar_bg
                  screen.draw(right)

          return end_x
    '';
  };
}
