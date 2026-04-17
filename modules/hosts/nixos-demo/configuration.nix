{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.nixos-demoConfiguration = {pkgs, ...}: {
    networking.hostName = "nixos-demo";

    system.stateVersion = "25.11";
  };
}
