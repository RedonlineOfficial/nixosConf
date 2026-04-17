{
  self,
  inputs,
  ...
}: {
  flake.homeModules.metaTerminal = {pkgs, ...}: {
    imports = [
      self.homeModules.git
      self.homeModules.zsh
      self.homeModules.neovim
    ];

    home.packages = with pkgs; [
      lsd
    ];
  };
}
