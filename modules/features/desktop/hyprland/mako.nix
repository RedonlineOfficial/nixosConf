{
  self,
  inputs,
  ...
}: {
  flake.homeModules.mako = {...}: {
    services.mako = {
      enable = true;
    };
  };
}
