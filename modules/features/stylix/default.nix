{ self, inputs, ... }: {

  flake.nixosModules.stylix = { pkgs, ... }: {
    imports = [ inputs.stylix.nixosModules.stylix ];

    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.hack;
          name = "Hack Nerd Font Mono";
        };
        sizes.terminal = 11;
      };

      opacity.terminal = 0.5;

      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/dracula/wallpaper/master/first-collection/nixos.png";
        sha256 = "0q9wd4g7fyzy38dkmknkz2p58xxh03yk916zdyqhlj0qagxnr444";
      };

      targets = {
        nvf.enable = true;
      };
    };
  };

}
