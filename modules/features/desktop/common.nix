{ self, inputs, ... }: {

  flake.nixosModules.commonDesktop = { pkgs, ... }: {

    hardware.bluetooth.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
    ];

  };

}
