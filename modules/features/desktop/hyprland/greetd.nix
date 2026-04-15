{ self, inputs, ... }: {

  flake.nixosModules.greetd = { ... }: {

    programs.regreet.enable = true;

  };

}
