{
  self,
  inputs,
  ...
}: let
  wallpaperUrl = "https://raw.githubusercontent.com/dracula/wallpaper/master/first-collection/nixos.png";
  wallpaperSha256 = "0q9wd4g7fyzy38dkmknkz2p58xxh03yk916zdyqhlj0qagxnr444";
  terminalOpacity = 0.5;
  terminalFontSize = 11;
in {
  flake.homeModules.stylix = {pkgs, ...}: {
    imports = [inputs.stylix.homeModules.stylix];

    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";

      fonts = {
        serif = {
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode Nerd Font";
        };
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
        sizes.terminal = terminalFontSize;
      };

      opacity.terminal = terminalOpacity;

      image = pkgs.fetchurl {
        url = wallpaperUrl;
        sha256 = wallpaperSha256;
      };

      targets = {
        nvf.enable = true;
      };
    };
  };

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
        sizes.terminal = terminalFontSize;
      };

      opacity.terminal = terminalOpacity;

      image = pkgs.fetchurl {
        url = wallpaperUrl;
        sha256 = wallpaperSha256;
      };

      targets = {
        nvf.enable = true;
      };
    };
  };
}
