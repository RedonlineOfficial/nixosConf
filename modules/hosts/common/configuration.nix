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

    # GPG — local agent for direct sessions; forwarded agent takes over via RemoteForward when SSH'd in
    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    # SSH server
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        AllowAgentForwarding = true;
        # Allow RemoteForward to replace the local gpg-agent socket on connect
        StreamLocalBindUnlink = true;
      };
    };

    # YubiKey smartcard + udev access
    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];

    # sudo via forwarded SSH agent (YubiKey on primary workstation signs the challenge)
    security.pam.sshAgentAuth = {
      enable = true;
      authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" "%h/.ssh/authorized_keys" ];
    };
    security.pam.services.sudo.sshAgentAuth = true;
    security.sudo.extraConfig = "Defaults env_keep+=SSH_AUTH_SOCK";

    # YubiKey U2F/FIDO2 for local login and sudo (sufficient — password still works as fallback)
    # After rebuild, register your YubiKey: pamu2fcfg | sudo tee /etc/u2f_keys
    # For a second/backup key: pamu2fcfg -n | sudo tee -a /etc/u2f_keys
    security.pam.u2f = {
      enable = true;
      settings = {
        cue = true;
        authfile = "/etc/u2f_keys";
      };
    };
    security.pam.services.login.u2fAuth = true;
    security.pam.services.sudo.u2fAuth = true;

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
