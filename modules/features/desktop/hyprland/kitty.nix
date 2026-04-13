{ self, inputs, ... }: {

  flake.nixosModules.kitty = { ... }: { };

  flake.homeModules.kitty = { ... }: {

    programs.kitty = {
      enable = true;

      settings = {
        scrollback_lines = 10000;
        scrollback_pager_history_size = 10;
        scrollback_fill_enlarged_window = true;
      };

      keybindings = {
        "ctrl+shift+n" = "new_os_window_with_cwd";
        "ctrl+shift+q" = "close_window";
      };
    };

  };

}
