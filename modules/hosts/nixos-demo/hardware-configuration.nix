{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.nixos-demoHardware = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [(modulesPath + "/profiles/qemu-guest.nix")];

    boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
    boot.kernelModules = ["kvm-intel"];

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/cc3f30db-a9d2-4c26-ad06-7591a92b5fb3";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/85C4-9098";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/9d355dfb-a10f-493f-a3c5-8be96b26e59d";}
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
