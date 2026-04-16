{ self, ... }: {

  flake.nixosModules.hm-pc-ws-01Configuration = { ... }: {
    networking.hostName = "hm-pc-ws-01";
    system.stateVersion = "25.11";

    # Systemd-based initrd required for FIDO2 LUKS unlock
    boot.initrd.systemd.enable = true;

    # LUKS encrypted root via YubiKey FIDO2.
    # After install, enroll your YubiKey:
    #   sudo systemd-cryptenroll --fido2-device=auto /dev/nvme0n1p2
    boot.initrd.luks.devices."cryptroot" = {
      device = "/dev/disk/by-partlabel/cryptroot";
      crypttabExtraOpts = [
        "fido2-device=auto"
        "token-timeout=10"
      ];
    };

    # Swapfile for hibernation — NixOS creates it automatically on first boot
    swapDevices = [{ device = "/swapfile"; size = 20480; }];

    # Hibernation resume from encrypted swapfile.
    # After first boot, get the resume_offset:
    #   sudo filefrag -v /swapfile | awk 'NR==4{gsub(/\./,""); print $4}'
    # Then add to boot.kernelParams: "resume_offset=<value>"
    boot.resumeDevice = "/dev/mapper/cryptroot";
    boot.kernelParams = [
      # "resume_offset=<value>"  # set after first boot
    ];
  };

}
