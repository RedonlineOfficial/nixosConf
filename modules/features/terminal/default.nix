{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.metaTerminal = {pkgs, ...}: {
    imports = [
      self.nixosModules.zsh
      self.nixosModules.neovim
    ];

    environment.systemPackages = with pkgs; [
      lsd
    ];

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
