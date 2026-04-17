{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.mako = {...}: {};

  flake.homeModules.mako = {...}: {
    services.mako = {
      enable = true;
    };
  };
}
