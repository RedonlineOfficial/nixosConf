{ self, inputs, ... }: {
  
  flake.nixosModules.metaTerminal = { pkgs, ... }: {

    imports = [
      self.nixosModules.zsh
      self.nixosModules.neovim
      self.nixosModules.git
    ];

    environment.systemPackages = with pkgs; [
      lsd
    ];

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

}
