{ self, inputs, ... }: let

  userName = "joshua";

in {

  flake.nixosModules.${userName} = { pkgs, ... }: {
    imports = [
      self.nixosModules.metaTerminal
    ];

    programs.zsh.enable = true;

    users.users.${userName} = {
      isNormalUser = true;
      description = userName;
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
      packages = with pkgs; [
        claude-code
      ];
    };

    security.sudo.wheelNeedsPassword = true;

    home-manager.users.${userName} = {
      imports = [
        self.homeModules.hyprland
        self.homeModules.noctalia
      ];

      home.username = userName;
      home.homeDirectory = "/home/${userName}";
      home.stateVersion = "25.11";

      gtk.gtk4.theme = null;
    };
  };

}
