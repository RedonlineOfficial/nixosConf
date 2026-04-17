{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.nemo = {pkgs, ...}: {
    environment.systemPackages = [pkgs.nemo];
  };

  flake.homeModules.nemo = {pkgs, ...}: {
    # Nemo is GTK3 — Stylix themes it automatically via stylix.targets.gtk (enabled by default).
    gtk.iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };
}
