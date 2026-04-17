# metaTerminal homeModule Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `flake.nixosModules.metaTerminal` with `flake.homeModules.metaTerminal` that composes git + zsh + neovim + lsd, and clean up `joshua/default.nix` to use the new meta-module.

**Architecture:** Two file edits — rewrite `terminal/default.nix` to expose only a homeModule, and update `joshua/default.nix` to drop the NixOS metaTerminal import and consolidate the four individual HM terminal imports into one.

**Tech Stack:** Nix, flake-parts, import-tree, home-manager

---

## File Map

| File | Change |
|---|---|
| `modules/features/terminal/default.nix` | Replace nixosModule with homeModule |
| `modules/users/joshua/default.nix` | Remove nixos import, consolidate HM imports |

---

### Task 1: Create branch

- [ ] **Create and switch to a new branch**

```bash
git checkout -b refactor/metaterminal-homemodule
```

---

### Task 2: Rewrite terminal/default.nix

**Files:**
- Modify: `modules/features/terminal/default.nix`

- [ ] **Replace the entire file with the homeModule version**

```nix
{
  self,
  inputs,
  ...
}: {
  flake.homeModules.metaTerminal = {pkgs, ...}: {
    imports = [
      self.homeModules.git
      self.homeModules.zsh
      self.homeModules.neovim
    ];

    home.packages = with pkgs; [
      lsd
    ];
  };
}
```

---

### Task 3: Update joshua/default.nix

**Files:**
- Modify: `modules/users/joshua/default.nix`

- [ ] **Remove `self.nixosModules.metaTerminal` from NixOS imports and consolidate HM imports**

Change the NixOS imports block from:

```nix
    imports = [
      self.nixosModules.metaTerminal
    ];
```

To: *(remove the entire imports block — it will be empty)*

And change the HM imports block from:

```nix
      imports = [
        self.homeModules.metaHyprland
        self.homeModules.git
        self.homeModules.zsh
        self.homeModules.neovim
      ];
```

To:

```nix
      imports = [
        self.homeModules.metaHyprland
        self.homeModules.metaTerminal
      ];
```

Full file after both changes:

```nix
{
  self,
  inputs,
  ...
}: let
  userName = "joshua";
in {
  flake.nixosModules.${userName} = {pkgs, ...}: {
    programs.zsh.enable = true;

    users.users.${userName} = {
      isNormalUser = true;
      description = userName;
      extraGroups = ["wheel" "networkmanager"];
      shell = pkgs.zsh;
      packages = with pkgs; [
        claude-code
        age # age-keygen for generating admin key
        sops # encrypt/decrypt secrets files
        ssh-to-age # convert SSH ed25519 public keys to age public keys
        alejandra
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnzbcr6a2th9Sj1rHfKO7yAFJB30AhJRx5D5AFmA5zehfYygG2bNu+s2fewCXSClNXf2d1BaBVcW5dQetb5BtIiCEXXSiLzLQMA8K1RmntrWubZrkMtaoT8K7rr6pDJQV5WHZ7PLdaDNuR+45gfANRumSj4aPtDcfPW/gHUoN5gh2eHVKVya7/8Jg7iLzjZDPMXVb5YLFYqM4mOf0GNQ1X1pl8LVtTuaCJxn9xyCbqOo6Msx9pKa6ZNs1zDQcJSSkXniDc77hPtYgcBpRSL04JYX7WYVSgubeiJdDsoEPtPceImLFcswHnGjPW1Pshz+yBwBn6jUWeo/GzAk2mih6Hfgq15pNWvANH8jqaXv6LBzQo8Ll8b6bFlB3kYNF2zDw+/gfzbq2uQpnBPe4sE4GiSPLkiHKjmE2rr2Lu4ewcGpzMLJyEV/gPVYKvzhOCr9/fhIoy5R+WX8tQV+tqBw9U+adQjsrwrdDgRzvvAmzmiLWzIh2yQkh1ZAEOUwYc+0O60O8TMIyjwP8yNMppGoIU3MY35f45au/KyOLPgBXaKgBQziHU3ZLWfoE1PyShGOHEzxrjnw1UNGmx3AK+Z8JUApBVLohG0Wd8s2e71la+0M20bkwp2q2HeoExHTaYDvkojFqJ8tm5oRU3WC+10W3zZZ09J2ogAJc7VVpQ0mGHTQ=="
      ];
    };

    security.sudo.wheelNeedsPassword = true;

    home-manager.users.${userName} = {
      imports = [
        self.homeModules.metaHyprland
        self.homeModules.metaTerminal
      ];

      home.username = userName;
      home.homeDirectory = "/home/${userName}";
      home.stateVersion = "25.11";

      gtk.gtk4.theme = null;

      programs.gpg = {
        enable = true;
        publicKeys = [
          {
            source = ./gpg-pubkey.asc;
            trust = "ultimate";
          }
        ];
        scdaemonSettings = {
          disable-ccid = true;
          pcsc-shared = true;
        };
      };

      # Register the YubiKey auth subkey keygrip for SSH use via gpg-agent
      home.file.".gnupg/sshcontrol" = {
        force = true;
        text = ''
          5DF8A48A7D0C6D87A9EDD14327E21DD87DC90C1F
        '';
      };
    };
  };
}
```

---

### Task 4: Commit and validate

- [ ] **Stage and commit**

```bash
git add modules/features/terminal/default.nix \
        modules/users/joshua/default.nix
git -c commit.gpgsign=false commit -m "refactor: add homeModules.metaTerminal, remove nixosModules.metaTerminal"
```

- [ ] **Ask user to run rebuild**

```bash
rebuild
```

Expected: build succeeds. Verify `lsd` is available (`l`, `ll`, `lt`) and all terminal tools still work.

---

### Task 5: Merge to main

*Only after rebuild succeeds.*

- [ ] **Merge branch and delete it**

```bash
git checkout main
git merge refactor/metaterminal-homemodule
git branch -d refactor/metaterminal-homemodule
```
