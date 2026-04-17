# neovim homeModule Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert `flake.nixosModules.neovim` to `flake.homeModules.neovim` by swapping the nvf module import and rewiring the NixOS/HM boundaries.

**Architecture:** Three file edits — swap the nvf module import in `neovim.nix`, remove the neovim import from `metaTerminal`, and add a temporary HM import in the `joshua` user module. The entire `programs.nvf` config block is unchanged.

**Tech Stack:** Nix, flake-parts, import-tree, home-manager, nvf

---

## File Map

| File | Change |
|---|---|
| `modules/features/terminal/neovim.nix` | `nixosModules.neovim` → `homeModules.neovim`, swap nvf module |
| `modules/features/terminal/default.nix` | Remove `self.nixosModules.neovim` from imports |
| `modules/users/joshua/default.nix` | Add `self.homeModules.neovim` to HM imports |

---

### Task 1: Create branch

- [ ] **Create and switch to a new branch**

```bash
git checkout -b refactor/neovim-homemodule
```

---

### Task 2: Convert neovim.nix to a homeModule

**Files:**
- Modify: `modules/features/terminal/neovim.nix`

- [ ] **Change the module declaration and nvf import**

Change the opening two lines of the module body from:

```nix
  flake.nixosModules.neovim = {...}: {
    imports = [inputs.nvf.nixosModules.default];
```

To:

```nix
  flake.homeModules.neovim = {...}: {
    imports = [inputs.nvf.homeManagerModules.default];
```

Everything after `imports = [...]` — the entire `programs.nvf` block — is unchanged.

---

### Task 3: Remove neovim from metaTerminal

**Files:**
- Modify: `modules/features/terminal/default.nix`

- [ ] **Remove `self.nixosModules.neovim` from the imports list**

Full file after change:

```nix
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.metaTerminal = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      lsd
    ];

    programs.zoxide = {
      enable = true;
    };
  };
}
```

Note: the `imports = [...]` block is removed entirely since it's now empty.

---

### Task 4: Wire neovim into joshua's HM imports

**Files:**
- Modify: `modules/users/joshua/default.nix`

- [ ] **Add `self.homeModules.neovim` to the `home-manager.users.joshua.imports` list**

Change:

```nix
      imports = [
        self.homeModules.metaHyprland
        self.homeModules.git
        self.homeModules.zsh
      ];
```

To:

```nix
      imports = [
        self.homeModules.metaHyprland
        self.homeModules.git
        self.homeModules.zsh
        self.homeModules.neovim
      ];
```

---

### Task 5: Commit and validate

- [ ] **Stage and commit**

```bash
git add modules/features/terminal/neovim.nix \
        modules/features/terminal/default.nix \
        modules/users/joshua/default.nix
git -c commit.gpgsign=false commit -m "refactor: convert neovim from nixosModule to homeModule"
```

- [ ] **Ask user to run rebuild**

```bash
rebuild
```

Expected: build succeeds. Verify neovim launches (`v`), LSP works, and formatting on save is active.

---

### Task 6: Merge to main

*Only after rebuild succeeds.*

- [ ] **Merge branch and delete it**

```bash
git checkout main
git merge refactor/neovim-homemodule
git branch -d refactor/neovim-homemodule
```
