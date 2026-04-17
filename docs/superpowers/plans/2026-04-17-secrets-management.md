# Secrets Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate sops-nix with an age backend so encrypted YAML secret files in the repo are automatically decrypted at NixOS activation time, with each host using its SSH host key and the admin using a dedicated age key.

**Architecture:** sops-nix is added as a flake input and wired into a new `secrets` NixOS module imported by `commonConfiguration`. Each host's default secrets file is `secrets/hosts/<hostname>.yaml`, encrypted to that host's SSH-derived age key plus the admin age key. The admin age private key lives at `~/.config/sops/age/keys.txt` on the workstation and is never committed.

**Tech Stack:** sops-nix, age, ssh-to-age, SOPS YAML format

---

## File Map

| Action | Path | Purpose |
|--------|------|---------|
| Modify | `flake.nix` | Add `sops-nix` input |
| Create | `modules/features/secrets/default.nix` | sops-nix NixOS module |
| Modify | `modules/hosts/common/configuration.nix` | Import `secrets` module |
| Modify | `modules/users/joshua/default.nix` | Add `sops` + `ssh-to-age` packages |
| Create | `.sops.yaml` | Key creation rules |
| Create | `secrets/hosts/nixos-demo.yaml` | Encrypted stub for nixos-demo |
| Create | `secrets/hosts/hm-pc-ws-01.yaml` | Encrypted stub for hm-pc-ws-01 |

---

### Task 1: Add sops-nix flake input

**Files:**
- Modify: `flake.nix`

- [ ] **Step 1: Add sops-nix to the inputs block**

Open `flake.nix`. After the `disko` input block (line 36), add:

```nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

The full inputs block should now end with:

```nix
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
```

- [ ] **Step 2: Verify the flake syntax parses**

```bash
nix flake metadata 2>&1 | head -5
```

Expected: prints flake metadata without errors. (The lock file will be updated when the config is first built.)

---

### Task 2: Create the secrets NixOS module

**Files:**
- Create: `modules/features/secrets/default.nix`

- [ ] **Step 1: Create the module file**

```nix
{ self, inputs, ... }: {

  flake.nixosModules.secrets = { config, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    # Derive the host's age identity from its SSH host key at activation time
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # Cache the derived age key here (tmpfs-backed by sops-nix)
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    # Default secrets file is this host's YAML; service modules reference secrets
    # with just sops.secrets."key" = {} without specifying sopsFile each time
    sops.defaultSopsFile = "${self}/secrets/hosts/${config.networking.hostName}.yaml";
  };

}
```

- [ ] **Step 2: Verify the file was created**

```bash
cat modules/features/secrets/default.nix
```

Expected: prints the module content above.

---

### Task 3: Wire secrets into the shared configuration

**Files:**
- Modify: `modules/hosts/common/configuration.nix`
- Modify: `modules/users/joshua/default.nix`

- [ ] **Step 1: Import secrets module in commonConfiguration**

In `modules/hosts/common/configuration.nix`, change line 5 from:

```nix
    imports = [ self.nixosModules.stylix ];
```

to:

```nix
    imports = [ self.nixosModules.stylix self.nixosModules.secrets ];
```

- [ ] **Step 2: Add sops and ssh-to-age to joshua's packages**

In `modules/users/joshua/default.nix`, change the packages list from:

```nix
      packages = with pkgs; [
        claude-code
      ];
```

to:

```nix
      packages = with pkgs; [
        claude-code
        sops        # encrypt/decrypt secrets files
        ssh-to-age  # convert SSH ed25519 public keys to age public keys
      ];
```

---

### Task 4: Verify the Nix config evaluates

**Files:** (none — read-only verification)

- [ ] **Step 1: Evaluate the nixos-demo configuration**

```bash
nix eval .#nixosConfigurations.nixos-demo.config.system.build.toplevel.drvPath
```

Expected: prints a `/nix/store/...` path ending in `.drv`. This confirms the full NixOS config evaluates without errors. If sops-nix is not yet in the lock file, Nix will fetch it first.

- [ ] **Step 2: Evaluate the hm-pc-ws-01 configuration**

```bash
nix eval .#nixosConfigurations.hm-pc-ws-01.config.system.build.toplevel.drvPath
```

Expected: same — prints a `.drv` store path.

---

### Task 5: Commit the Nix wiring

**Files:** (git only)

- [ ] **Step 1: Stage and commit**

```bash
git add flake.nix flake.lock modules/features/secrets/default.nix \
        modules/hosts/common/configuration.nix modules/users/joshua/default.nix
git commit -m "feat: add sops-nix secrets management module"
```

Expected: commit succeeds. `git log --oneline -1` shows the new commit.

---

### Task 6: Generate the admin age key

> **Note:** This task runs on the workstation (nixos-demo or hm-pc-ws-01). The generated private key must NEVER be committed to the repository.

**Files:**
- Create (outside repo): `~/.config/sops/age/keys.txt`

- [ ] **Step 1: Create the sops age key directory**

```bash
mkdir -p ~/.config/sops/age
```

- [ ] **Step 2: Generate the age keypair**

```bash
age-keygen -o ~/.config/sops/age/keys.txt
```

Expected output (example — your public key will differ):

```
Public key: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
```

- [ ] **Step 3: Record the public key**

Copy the printed public key. You will paste it into `.sops.yaml` in Task 7. It begins with `age1`.

- [ ] **Step 4: Verify the key file was created**

```bash
head -1 ~/.config/sops/age/keys.txt
```

Expected: `# created: <timestamp>` — confirms the file exists and is readable.

---

### Task 7: Collect host age keys and create .sops.yaml

> **Note:** Tasks 7 and 8 require the workstation to have `ssh-to-age` available. If the current system hasn't been rebuilt with Task 3's changes yet, run steps using `nix-shell -p ssh-to-age --run "ssh-to-age ..."` instead.

**Files:**
- Create: `.sops.yaml`

- [ ] **Step 1: Get the nixos-demo host age public key**

Run this on the nixos-demo host (or locally if that is nixos-demo):

```bash
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

Expected: a single line starting with `age1`. Copy it.

- [ ] **Step 2: Get the hm-pc-ws-01 host age public key**

Run this on hm-pc-ws-01 (SSH in if needed):

```bash
ssh user@hm-pc-ws-01 'ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub'
```

Expected: a single line starting with `age1`. Copy it.

> If hm-pc-ws-01 is not yet installed, skip this step and leave its anchor commented out. Add it when the machine is provisioned.

- [ ] **Step 3: Create .sops.yaml with the collected keys**

Create `.sops.yaml` at the repo root, substituting the real `age1...` values you collected:

```yaml
keys:
  - &admin age1REPLACE_WITH_ADMIN_PUBLIC_KEY
  - &nixos_demo age1REPLACE_WITH_NIXOS_DEMO_HOST_KEY
  # Uncomment and fill in when hm-pc-ws-01 is installed:
  # - &hm_pc_ws_01 age1REPLACE_WITH_HM_PC_WS_01_HOST_KEY
  # Add new homelab VMs here as they are provisioned:
  # - &gitea age1...

creation_rules:
  - path_regex: secrets/common\.yaml$
    key_groups:
      - age:
          - *admin
          - *nixos_demo
          # - *hm_pc_ws_01

  - path_regex: secrets/hosts/nixos-demo\.yaml$
    key_groups:
      - age:
          - *admin
          - *nixos_demo

  - path_regex: secrets/hosts/hm-pc-ws-01\.yaml$
    key_groups:
      - age:
          - *admin
          # - *hm_pc_ws_01
```

- [ ] **Step 4: Verify the file parses correctly**

```bash
cat .sops.yaml
```

Expected: prints the YAML without errors. Confirm the `age1` values are filled in (not placeholder text).

---

### Task 8: Create encrypted stub secret files for existing hosts

**Files:**
- Create: `secrets/hosts/nixos-demo.yaml`
- Create: `secrets/hosts/hm-pc-ws-01.yaml`

- [ ] **Step 1: Create the secrets directory**

```bash
mkdir -p secrets/hosts
```

- [ ] **Step 2: Create and encrypt the nixos-demo stub**

```bash
echo 'placeholder: ""' > secrets/hosts/nixos-demo.yaml
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  sops --encrypt --in-place secrets/hosts/nixos-demo.yaml
```

Expected: `secrets/hosts/nixos-demo.yaml` now contains sops-encrypted content (begins with `sops:` metadata, values are ciphertext).

- [ ] **Step 3: Verify the stub decrypts correctly**

```bash
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  sops --decrypt secrets/hosts/nixos-demo.yaml
```

Expected:

```yaml
placeholder: ""
```

- [ ] **Step 4: Create and encrypt the hm-pc-ws-01 stub**

```bash
echo 'placeholder: ""' > secrets/hosts/hm-pc-ws-01.yaml
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  sops --encrypt --in-place secrets/hosts/hm-pc-ws-01.yaml
```

> If the hm-pc-ws-01 host age key was skipped in Task 7 (machine not installed), this file will only be encrypted to the admin key. That is fine — update `.sops.yaml` and run `sops updatekeys secrets/hosts/hm-pc-ws-01.yaml` once the machine is provisioned.

- [ ] **Step 5: Verify hm-pc-ws-01 stub decrypts**

```bash
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
  sops --decrypt secrets/hosts/hm-pc-ws-01.yaml
```

Expected:

```yaml
placeholder: ""
```

---

### Task 9: Commit secrets infrastructure and verify build

**Files:** (git + rebuild)

- [ ] **Step 1: Stage and commit**

```bash
git add .sops.yaml secrets/hosts/nixos-demo.yaml secrets/hosts/hm-pc-ws-01.yaml
git commit -m "chore: add sops key config and encrypted stub secret files"
```

- [ ] **Step 2: Ask the user to rebuild**

The config must be committed (or staged) before `nixos-rebuild` — untracked files are invisible to the Nix flake. Ask the user to run:

```bash
rebuild
```

Expected: rebuild completes without errors. sops-nix activates and derives the host age key from `/etc/ssh/ssh_host_ed25519_key`.

- [ ] **Step 3: Verify sops-nix derived key exists post-rebuild**

After the rebuild completes:

```bash
sudo ls /var/lib/sops-nix/key.txt
```

Expected: file exists. This is the age key sops-nix cached from the SSH host key — used at each activation to decrypt secrets.

---

## Reference: Adding a real secret (post-setup pattern)

When you need to store an actual secret for a service:

```bash
# Edit the host's secrets file — sops decrypts, opens editor, re-encrypts on save
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops secrets/hosts/gitea.yaml
```

Inside the editor, add your secret (example):

```yaml
placeholder: ""
db/password: "your-actual-password-here"
```

Then in the host's NixOS config:

```nix
sops.secrets."db/password" = {};
services.gitea.database.passwordFile = config.sops.secrets."db/password".path;
```

The secret is written to `/run/secrets/db/password` at activation — never to persistent disk unencrypted.

---

## Reference: Adding a new homelab VM

1. Install NixOS via `disko-install`
2. Get the host's age public key: `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`
3. Add anchor to `keys:` in `.sops.yaml` and a `creation_rules` entry for `secrets/hosts/<hostname>.yaml`
4. Update `common.yaml`'s key group if the VM needs shared secrets
5. Create the stub: `echo 'placeholder: ""' > secrets/hosts/<hostname>.yaml && sops --encrypt --in-place secrets/hosts/<hostname>.yaml`
6. Commit and rebuild
