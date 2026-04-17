# Secrets Management Design

**Date:** 2026-04-17
**Status:** Approved

## Overview

Add declarative secrets management to the NixOS flake configuration using
**sops-nix** with an **age** backend. Secrets are stored as encrypted YAML
files in the repository — only ciphertext is committed. Each host decrypts its
own secrets at activation time using its SSH host key; the admin (workstation)
can decrypt and edit any secret using a dedicated age key.

## Scope

- Service credentials (database passwords, API keys, OAuth tokens)
- Misc per-host secrets
- Out of scope: SSH host keys, TLS certificates (handled by Let's Encrypt),
  VPN credentials (handled by Tailscale)

## Repository Structure

```
nixosConf/
├── .sops.yaml                          # Key creation rules
├── secrets/
│   ├── common.yaml                     # Secrets shared across all hosts (if needed)
│   └── hosts/
│       ├── nixos-demo.yaml
│       ├── hm-pc-ws-01.yaml
│       └── <hostname>.yaml             # One file per host/VM, added as hosts are created
└── modules/
    └── features/
        └── secrets/
            └── default.nix             # sops-nix NixOS module
```

Each Proxmox VM is a dedicated NixOS host running one service (or a small
number of related services). The per-host file structure aligns naturally with
this — `secrets/hosts/gitea.yaml` holds all secrets the gitea VM needs,
including any credentials it uses to talk to other services (e.g. its database
password). The consumer of a secret holds it, not the producer.

## Key Management

### Host keys

sops-nix derives each host's age identity from its SSH host ed25519 key at
runtime. No extra key material is required. Configuration in the shared secrets
module:

```nix
sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
sops.age.keyFile = "/var/lib/sops-nix/key.txt";
```

To get a host's age public key (needed when registering it in `.sops.yaml`):

```bash
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

Run this on the host after first install.

### Admin key

A dedicated age key on the workstation. The private key lives at
`~/.config/sops/age/keys.txt` (sops default path — picked up automatically).
The public key is registered as `&admin` in `.sops.yaml`.

Generate once:

```bash
age-keygen -o ~/.config/sops/age/keys.txt
# public key is printed to stdout — copy it into .sops.yaml
```

This key is not stored in the repository. It stays on the workstation. The
YubiKey remains the primary authentication boundary (workstation login, sudo,
SSH); the age key is the credential for the secrets workflow specifically.

## `.sops.yaml`

```yaml
keys:
  - &admin age1...           # workstation age public key
  - &nixos_demo age1...      # ssh-to-age of nixos-demo SSH host key
  - &hm_pc_ws_01 age1...     # ssh-to-age of hm-pc-ws-01 SSH host key
  # Add new hosts here as VMs are provisioned:
  # - &gitea age1...

creation_rules:
  - path_regex: secrets/common\.yaml$
    key_groups:
      - age: [*admin, *nixos_demo, *hm_pc_ws_01]

  - path_regex: secrets/hosts/nixos-demo\.yaml$
    key_groups:
      - age: [*admin, *nixos_demo]

  - path_regex: secrets/hosts/hm-pc-ws-01\.yaml$
    key_groups:
      - age: [*admin, *hm_pc_ws_01]
```

When a new VM is added: add its anchor to `keys:`, add a `creation_rules`
entry for its file, and update `common.yaml`'s rule if that VM needs shared
secrets.

## NixOS Module

`modules/features/secrets/default.nix` — shared sops-nix wiring imported by
all hosts via `commonConfiguration`:

```nix
{ self, inputs, ... }: {
  flake.nixosModules.secrets = { config, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    sops.defaultSopsFile = "${self}/secrets/hosts/${config.networking.hostName}.yaml";
  };
}
```

`sops.defaultSopsFile` is set to the host's own YAML by hostname, so service
modules can reference secrets without specifying the file path:

```nix
sops.secrets."db/password" = {};
services.gitea.database.passwordFile = config.sops.secrets."db/password".path;
```

sops-nix decrypts secrets at activation time and writes them to a tmpfs path
under `/run/secrets/` — never touches persistent disk unencrypted.

Secrets from `common.yaml` require an explicit `sopsFile` override since
`defaultSopsFile` points to the host's own file:

```nix
sops.secrets."shared/key" = {
  sopsFile = "${self}/secrets/common.yaml";
};
```

## Flake Changes

- Add `sops-nix` input to `flake.nix`, following `nixpkgs`
- Import `secrets` nixosModule in `commonConfiguration`
- Add `sops` and `ssh-to-age` to the `joshua` user packages in `modules/users/joshua/default.nix` (admin workflow tools — small enough to include on all hosts)

## Workflow

### Adding or rotating a secret

```bash
sops secrets/hosts/gitea.yaml   # opens editor; sops decrypts/re-encrypts transparently
git add secrets/hosts/gitea.yaml
git commit -m "chore: update gitea secrets"
```

### Adding a new homelab VM

1. Install NixOS via `disko-install` as usual
2. SSH into the new host and get its age public key:
   ```bash
   ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
   ```
3. Add the anchor and creation rule to `.sops.yaml`
4. Create the host's secrets file: `sops secrets/hosts/<hostname>.yaml`
5. Rebuild the host — `secrets` module is already active via `commonConfiguration`

### Initial workstation setup (one-time)

1. `age-keygen -o ~/.config/sops/age/keys.txt` — generate admin key
2. Copy the printed public key into `.sops.yaml` as `&admin`
3. For each existing host, run `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`
   and add to `.sops.yaml`
4. Create initial secret files via `sops secrets/hosts/<hostname>.yaml`

## Error Handling

- If a host's SSH host key changes (e.g. after a reinstall), its age identity
  changes. Re-run `ssh-to-age` to get the new public key, update `.sops.yaml`,
  then run `sops updatekeys secrets/hosts/<hostname>.yaml` to re-encrypt for
  the new key.
- If the admin age key is lost, secrets can still be decrypted by any host
  that holds a matching private key — but you cannot edit them from the
  workstation until a new admin key is registered and secrets are re-encrypted.
  Keep a backup of `~/.config/sops/age/keys.txt`.
