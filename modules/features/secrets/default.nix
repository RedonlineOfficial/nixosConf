{ self, inputs, ... }: {

  flake.nixosModules.secrets = { config, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    # Derive the host's age identity from its SSH host key at activation time
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # Cache the derived age key here (persisted to disk; re-derived from SSH host key on each activation)
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    # Default secrets file is this host's YAML; service modules reference secrets
    # with just sops.secrets."key" = {} without specifying sopsFile each time
    sops.defaultSopsFile = "${self}/secrets/hosts/${config.networking.hostName}.yaml";
  };

}
