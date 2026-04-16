# Common settings shared across all hosts
{ self, inputs, ... }: {

  flake.nixosModules.commonConfiguration = { pkgs, ... }: {
    imports = [ self.nixosModules.stylix ];
    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
# Time & locale
    time.timeZone = "America/Phoenix";
    i18n.defaultLocale = "en_US.UTF-8";

    # Networking
    networking.networkmanager.enable = true;

    # Common system packages
    environment.systemPackages = with pkgs; [];

    # SSH client
    programs.ssh = {
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };

    # GPG agent handles SSH auth via YubiKey smartcard
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    # SSH server
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        AllowAgentForwarding = true;
      };
    };

    # YubiKey smartcard + udev access
    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];

    # sudo via forwarded SSH agent (YubiKey on primary workstation signs the challenge)
    security.pam.sshAgentAuth.enable = true;
    security.pam.services.sudo.sshAgentAuth = true;

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
