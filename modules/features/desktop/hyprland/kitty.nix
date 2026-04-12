{ self, inputs, ... }: {

  flake.nixosModules.kitty = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      kitty
    ];

  };

}
