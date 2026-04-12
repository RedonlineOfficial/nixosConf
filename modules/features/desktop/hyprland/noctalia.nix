{ self, inputs, ... }: {

  flake.nixosModules.noctalia = { ... }: {

    imports = [ inputs.noctalia.nixosModules.default ];

    nix.settings = {
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };

  };

  flake.homeModules.noctalia = { ... }: {

    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;

      settings = {
        position = "top";

        dock = {
          enabled = true;
          displayMode = "auto_hide";
        };

        notifications = {
          enabled = true;
          location = "top_right";
        };
      };
    };

  };

}
