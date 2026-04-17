{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.metaTerminal = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      lsd
    ];

    programs.zoxide = {
      enable = true;
    };
  };
}
