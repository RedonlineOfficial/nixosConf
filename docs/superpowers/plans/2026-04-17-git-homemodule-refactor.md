# git homeModule Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert `flake.nixosModules.git` to `flake.homeModules.git` so git config lives in home-manager where it belongs.

**Architecture:** Three file edits — rename the module declaration in `git.nix`, remove the nixos-level import from `metaTerminal`, and add a temporary HM import in the `joshua` user module. No logic changes.

**Tech Stack:** Nix, flake-parts, import-tree, home-manager

---

## File Map

| File | Change |
|---|---|
| `modules/features/terminal/git.nix` | `nixosModules.git` → `homeModules.git` |
| `modules/features/terminal/default.nix` | Remove `self.nixosModules.git` from imports |
| `modules/users/joshua/default.nix` | Add `self.homeModules.git` to HM imports |

---

### Task 1: Create branch

- [ ] **Create and switch to a new branch**

```bash
git checkout -b refactor/git-homemodule
```

---

### Task 2: Convert git.nix to a homeModule

**Files:**
- Modify: `modules/features/terminal/git.nix`

- [ ] **Replace `flake.nixosModules.git` with `flake.homeModules.git`**

Full file after change:

```nix
{
  self,
  inputs,
  ...
}: {
  flake.homeModules.git = {pkgs, ...}: {
    programs.git = {
      enable = true;

      config = {
        init.defaultBranch = "main";
        core.editor = "nvim -f";
        user = {
          name = "RedonlineOfficial";
          email = "dev@redonline.me";
        };
        commit.gpgsign = true;
        tag.gpgsign = true;
        user.signingKey = "AC56BC54D4551885";
        pull.rebase = false;
        push.autoSetupRemote = true;
        diff.colorMoved = "default";

        # Commit template
        commit.template = "${pkgs.writeText "git-commit-template" ''
          ##### ================== Conventional Commit Template ==================
          ### <type>(<scope>)!: <description>
          ### ------------- MAX 50 CHARACTERS -------------|


          ### <body>
          ### ------------------------ MAX 72 CHARACTERS ------------------------|


          ### <footer>
          ### ------------------------ MAX 72 CHARACTERS ------------------------|
          ##### ========================== END TEMPLATE ==========================

          # <type>:
          #   - feat:     add, change, or remove features
          #   - fix:      bug fixes
          #   - chore:    routine tasks
          #   - docs:     changes to documentation
          #   - style:    changes that don't affect code logic
          #   - refactor: changes that restructure the code without changing logic
          #   - test:     adding or updating tests
          #   - build:    changes to build related components
          #   - perf:     changes to code performance
          #
          # <scope>:
          #   - optional
          #   - scopes vary by project
          #   - do not use issue identifiers
          #
          # !:
          #   - breaking change indicator
          #   - breaking changes shall be described in <footer>
          #
          # <description>:
          #   - mandatory
          #   - concise description of change written in imperative present tense
          #   - do not use capitalization or punctuation
          #
          # <body>:
          #   - optional
          #   - expands upon description to include motivation, details, etc
          #   - written in imperative present tense
          #
          # <footer>:
          #   - optional
          #   - contains issue references and information about breaking changes
          #   - can reference issue identifiers
          #
          # versioning (MAJOR.MINOR.PATCH)
          #   - breaking changes increment MAJOR
          #   - feat or fix increments MINOR
          #   - all other changes increments PATCH
        ''}";
      };
    };
  };
}
```

---

### Task 3: Remove git from metaTerminal

**Files:**
- Modify: `modules/features/terminal/default.nix`

- [ ] **Remove `self.nixosModules.git` from the imports list**

Full file after change:

```nix
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.metaTerminal = {pkgs, ...}: {
    imports = [
      self.nixosModules.zsh
      self.nixosModules.neovim
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
```

---

### Task 4: Wire git into joshua's HM imports

**Files:**
- Modify: `modules/users/joshua/default.nix`

- [ ] **Add `self.homeModules.git` to the `home-manager.users.joshua.imports` list**

Change the imports block from:

```nix
      imports = [
        self.homeModules.metaHyprland
      ];
```

To:

```nix
      imports = [
        self.homeModules.metaHyprland
        self.homeModules.git
      ];
```

---

### Task 5: Commit and validate

- [ ] **Stage and commit**

```bash
git add modules/features/terminal/git.nix \
        modules/features/terminal/default.nix \
        modules/users/joshua/default.nix
git commit -m "refactor: convert git from nixosModule to homeModule"
```

- [ ] **Ask user to run rebuild**

```bash
rebuild
```

Expected: build succeeds with no errors. Git should behave identically after rebuild — verify with `git config --list | grep user`.

---

### Task 6: Merge to main

*Only after rebuild succeeds.*

- [ ] **Merge branch and delete it**

```bash
git checkout main
git merge refactor/git-homemodule
git branch -d refactor/git-homemodule
```
