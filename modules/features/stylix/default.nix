{ self, inputs, ... }: {

  flake.nixosModules.stylix = { pkgs, ... }: {
    imports = [ inputs.stylix.nixosModules.stylix ];

    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";

      # Solid dracula-background wallpaper (used by desktop wallpaper targets)
      image = pkgs.runCommand "dracula-wallpaper.png" {
        nativeBuildInputs = [ pkgs.imagemagick ];
      } ''
        convert -size 1920x1080 xc:'#282a36' "$out"
      '';

      targets = {
        nvf.enable = true;
      };
    };
  };

}
