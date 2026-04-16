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
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnzbcr6a2th9Sj1rHfKO7yAFJB30AhJRx5D5AFmA5zehfYygG2bNu+s2fewCXSClNXf2d1BaBVcW5dQetb5BtIiCEXXSiLzLQMA8K1RmntrWubZrkMtaoT8K7rr6pDJQV5WHZ7PLdaDNuR+45gfANRumSj4aPtDcfPW/gHUoN5gh2eHVKVya7/8Jg7iLzjZDPMXVb5YLFYqM4mOf0GNQ1X1pl8LVtTuaCJxn9xyCbqOo6Msx9pKa6ZNs1zDQcJSSkXniDc77hPtYgcBpRSL04JYX7WYVSgubeiJdDsoEPtPceImLFcswHnGjPW1Pshz+yBwBn6jUWeo/GzAk2mih6Hfgq15pNWvANH8jqaXv6LBzQo8Ll8b6bFlB3kYNF2zDw+/gfzbq2uQpnBPe4sE4GiSPLkiHKjmE2rr2Lu4ewcGpzMLJyEV/gPVYKvzhOCr9/fhIoy5R+WX8tQV+tqBw9U+adQjsrwrdDgRzvvAmzmiLWzIh2yQkh1ZAEOUwYc+0O60O8TMIyjwP8yNMppGoIU3MY35f45au/KyOLPgBXaKgBQziHU3ZLWfoE1PyShGOHEzxrjnw1UNGmx3AK+Z8JUApBVLohG0Wd8s2e71la+0M20bkwp2q2HeoExHTaYDvkojFqJ8tm5oRU3WC+10W3zZZ09J2ogAJc7VVpQ0mGHTQ=="
      ];
    };

    security.sudo.wheelNeedsPassword = true;

    home-manager.users.${userName} = {
      imports = [
        self.homeModules.metaHyprland
      ];

      home.username = userName;
      home.homeDirectory = "/home/${userName}";
      home.stateVersion = "25.11";

      gtk.gtk4.theme = null;

      programs.gpg = {
        enable = true;
        publicKeys = [
          {
            source = ./gpg-pubkey.asc;
            trust = "ultimate";
          }
        ];
        scdaemonSettings = {
          disable-ccid = true;
        };
      };
    };
  };

}
