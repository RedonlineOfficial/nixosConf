# Common settings shared across all hosts
{ self, inputs, ... }: {

  flake.nixosModules.commonConfiguration = { pkgs, ... }: {
    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Time & locale
    time.timeZone = "America/Phoenix";
    i18n.defaultLocale = "en_US.UTF-8";

    # Networking
    networking.networkmanager.enable = true;

    # Common system packages
    environment.systemPackages = with pkgs; [
      git
    ];

    # SSH
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "no";
    };

    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];

        substituters = [
          "https://cache.nixos.org"
          "https://claude-code.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
        ];

        trusted-users = [ "root" "@wheel" ];
      };

      gc = {
        automatic = true;
        dates = "Saturday *-*-* 23:00:00";
        persistent = true;
      };

      optimise = {
        automatic = true;
        dates = "Saturday *-*-* 23:30:00";
        persistent = true;
      };
    };

    nixpkgs.config.allowUnfree = true;
  };

}
