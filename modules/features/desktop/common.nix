{ self, inputs, ... }: {

  flake.nixosModules.commonDesktop = { ... }: {

    hardware.bluetooth.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

  };

}
