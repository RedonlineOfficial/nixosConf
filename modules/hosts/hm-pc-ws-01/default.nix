{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.hm-pc-ws-01 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      # Disk layout
      inputs.disko.nixosModules.disko
      self.nixosModules.hm-pc-ws-01Disko

      # Host configuration
      self.nixosModules.hm-pc-ws-01Configuration
      self.nixosModules.hm-pc-ws-01Hardware

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
