{ self, inputs, ... }: {

  flake.nixosModules.dolphin = { pkgs, ... }: {

    environment.systemPackages = with pkgs; [
      dolphin
      ffmpegthumbs              # video thumbnails
      kdegraphics-thumbnailers  # image and document thumbnails
      kio-extras                # extended KIO protocol support
    ];

  };

  flake.homeModules.dolphin = { ... }: { };

}
