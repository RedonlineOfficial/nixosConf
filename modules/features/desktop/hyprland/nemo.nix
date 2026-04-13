{ self, inputs, ... }: {

  flake.nixosModules.nemo = { pkgs, ... }: {

    environment.systemPackages = [ pkgs.nemo ];

  };

  flake.homeModules.nemo = { ... }: {
    # Nemo is GTK3 — Stylix themes it automatically via stylix.targets.gtk (enabled by default).
  };

}
