{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.metaTerminal = {pkgs, ...}: {
    imports = [
      self.nixosModules.neovim
    ];

    environment.systemPackages = with pkgs; [
      lsd
    ];

    programs.zoxide = {
      enable = true;
    };
  };
}
