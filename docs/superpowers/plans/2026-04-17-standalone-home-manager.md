# Standalone Home Manager Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable `home-manager switch --flake ~/nixosConf#joshua` as a fast path for dotfile changes, while keeping `nixos-rebuild` working unchanged for full system changes.

**Architecture:** Extract joshua's home-manager config from `flake.nixosModules.joshua` into a new `flake.homeModules.joshuaHome`. Wire it into both the existing NixOS home-manager integration (slim import) and a new `flake.homeConfigurations.joshua` standalone entry. Host configs are untouched.

**Tech Stack:** NixOS flakes, flake-parts, home-manager, import-tree

---

## File Map

| File | Change |
|---|---|
| `modules/users/joshua/default.nix` | Modify — add `homeModules.joshuaHome` and `homeConfigurations.joshua`, slim down `nixosModules.joshua` |

No other files change.

---

### Task 1: Create feature branch

**Files:**
- No file changes — git operation only

- [ ] **Step 1: Create and check out branch**

```bash
git checkout -b feat/standalone-home-manager
```

Expected output:
```
Switched to a new branch 'feat/standalone-home-manager'
```

---

### Task 2: Restructure `modules/users/joshua/default.nix`

**Files:**
- Modify: `modules/users/joshua/default.nix`

The file currently defines one thing (`flake.nixosModules.joshua`) with NixOS user config and a `home-manager.users.joshua` block mixed together. Replace the entire file with three definitions:

1. `flake.nixosModules.joshua` — NixOS-level only; `home-manager.users.joshua` shrinks to a single-line import.
2. `flake.homeModules.joshuaHome` — all current home-manager config (single source of truth).
3. `flake.homeConfigurations.joshua` — standalone entrypoint using `homeManagerConfiguration`.

`self` and `userName` are captured from the outer flake-parts module scope (the `{ self, inputs, ... }:` args) — they do not need to be passed as `extraSpecialArgs`.

- [ ] **Step 1: Replace the file contents**

Write `modules/users/joshua/default.nix`:

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
        age
        sops
        ssh-to-age
        alejandra
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnzbcr6a2th9Sj1rHfKO7yAFJB30AhJRx5D5AFmA5zehfYygG2bNu+s2fewCXSClNXf2d1BaBVcW5dQetb5BtIiCEXXSiLzLQMA8K1RmntrWubZrkMtaoT8K7rr6pDJQV5WHZ7PLdaDNuR+45gfANRumSj4aPtDcfPW/gHUoN5gh2eHVKVya7/8Jg7iLzjZDPMXVb5YLFYqM4mOf0GNQ1X1pl8LVtTuaCJxn9xyCbqOo6Msx9pKa6ZNs1zDQcJSSkXniDc77hPtYgcBpRSL04JYX7WYVSgubeiJdDsoEPtPceImLFcswHnGjPW1Pshz+yBwBn6jUWeo/GzAk2mih6Hfgq15pNWvANH8jqaXv6LBzQo8Ll8b6bFlB3kYNF2zDw+/gfzbq2uQpnBPe4sE4GiSPLkiHKjmE2rr2Lu4ewcGpzMLJyEV/gPVYKvzhOCr9/fhIoy5R+WX8tQV+tqBw9U+adQjsrwrdDgRzvvAmzmiLWzIh2yQkh1ZAEOUwYc+0O60O8TMIyjwP8yNMppGoIU3MY35f45au/KyOLPgBXaKgBQziHU3ZLWfoE1PyShGOHEzxrjnw1UNGmx3AK+Z8JUApBVLohG0Wd8s2e71la+0M20bkwp2q2HeoExHTaYDvkojFqJ8tm5oRU3WC+10W3zZZ09J2ogAJc7VVpQ0mGHTQ=="
      ];
    };

    security.sudo.wheelNeedsPassword = true;

    home-manager.users.${userName}.imports = [self.homeModules.joshuaHome];
  };

  flake.homeModules.joshuaHome = {...}: {
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

    home.file.".gnupg/sshcontrol" = {
      force = true;
      text = ''
        5DF8A48A7D0C6D87A9EDD14327E21DD87DC90C1F
      '';
    };
  };

  flake.homeConfigurations.${userName} = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = {inherit inputs self;};
    modules = [self.homeModules.joshuaHome];
  };
}
```

---

### Task 3: Verify both configs evaluate

**Files:**
- No file changes — evaluation only

NixOS flakes use git to determine which files to include. Stage the change before running nix commands.

- [ ] **Step 1: Stage the modified file**

```bash
git add modules/users/joshua/default.nix
```

- [ ] **Step 2: Verify the standalone home config evaluates**

```bash
nix build .#homeConfigurations.joshua.activationPackage --no-link
```

Expected: build completes with no errors. If it fails, check the error — most likely cause is a missing `extraSpecialArgs` that a sub-module needs, in which case add it to the `homeManagerConfiguration` call in `default.nix`.

- [ ] **Step 3: Verify the NixOS config still evaluates**

```bash
nix build .#nixosConfigurations.nixos-demo.config.system.build.toplevel --no-link
```

Expected: build completes with no errors.

---

### Task 4: Commit and test

**Files:**
- No file changes — git and user testing

- [ ] **Step 1: Commit**

```bash
git commit -m "feat: add standalone home-manager configuration for joshua"
```

- [ ] **Step 2: Ask user to test the NixOS path**

Ask the user to run:
```bash
rebuild
```
This verifies the NixOS integration still works end-to-end (home-manager runs as part of system rebuild).

- [ ] **Step 3: Ask user to test the standalone path**

Ask the user to run:
```bash
home-manager switch --flake ~/nixosConf#joshua
```
This verifies the standalone path works. Expected: home-manager applies the config and prints generation info.

- [ ] **Step 4: Merge to main on success**

```bash
git checkout main
git merge feat/standalone-home-manager
```

---

## Post-Implementation: New Workflow

| Scenario | Command |
|---|---|
| Dotfile / home config change | `home-manager switch --flake ~/nixosConf#joshua` |
| System or NixOS config change | `rebuild` |
