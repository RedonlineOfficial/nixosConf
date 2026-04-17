{
  self,
  inputs,
  ...
}: {
  flake.homeModules.nemo = {pkgs, ...}: {
    home.packages = [pkgs.nemo];

    # Nemo is GTK3 — Stylix themes it automatically via stylix.targets.gtk (enabled by default).
    gtk.iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };
}
