{ self, ... }: {

  # Stub — regenerate with nixos-generate-config after install and replace this file.
  # Update boot.kernelModules to kvm-amd if using an AMD CPU.
  flake.nixosModules.hm-pc-ws-01Hardware = { lib, modulesPath, ... }: {
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

    boot.initrd.availableKernelModules = [
      "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"
    ];
    boot.kernelModules = [ "kvm-intel" ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };

}
