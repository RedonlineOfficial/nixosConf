{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.nixos-demo = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      # Host configuration
      self.nixosModules.nixos-demoConfiguration
      self.nixosModules.nixos-demoHardware

      # Common host configuration
      self.nixosModules.commonConfiguration

      # System level user definition
      self.nixosModules.joshua

      # Desktop
      self.nixosModules.metaHyprland

      # Apply claude-code overlay
      {nixpkgs.overlays = [inputs.claude-code.overlays.default];}

      # Home manager
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };
}
