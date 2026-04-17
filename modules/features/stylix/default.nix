{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.stylix = {
    pkgs,
    config,
    ...
  }: {
    imports = [inputs.stylix.nixosModules.stylix];

    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";

      fonts = {
        serif = config.stylix.fonts.sansSerif;
        sansSerif = {
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode Nerd Font";
        };
        monospace = {
          package = pkgs.nerd-fonts.fira-mono;
          name = "FiraMono Nerd Font";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
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
