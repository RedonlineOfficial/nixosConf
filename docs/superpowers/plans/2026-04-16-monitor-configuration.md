# Monitor Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add dynamic monitor profile switching for a 4-display laptop-dock setup using `nwg-displays` (GUI editor) and `hyprdynamicmonitors` (auto-switching daemon).

**Architecture:** A new `monitors.nix` home module installs both tools, writes the `hyprdynamicmonitors` config declaratively via `home.file`, and runs the daemon as a systemd user service. Profiles are generated using the `freeze` command while monitors are connected, then encoded in Nix. The module is imported into `homeModules.metaHyprland`.

**Tech Stack:** Nix/home-manager, `hyprdynamicmonitors` (TOML + Go templates), `nwg-displays`, systemd user services.

---

## Phase 1: Module Infrastructure

### Task 1: Create `monitors.nix` module skeleton

**Files:**
- Create: `modules/features/desktop/hyprland/monitors.nix`

- [ ] **Step 1: Create the module file**

```nix
{ self, inputs, ... }: {

  flake.homeModules.monitors = { pkgs, ... }: {

    home.packages = with pkgs; [
      nwg-displays
      hyprdynamicmonitors
    ];

    systemd.user.services.hyprdynamicmonitors = {
      Unit = {
        Description = "Dynamic monitor configuration for Hyprland";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.hyprdynamicmonitors}/bin/hyprdynamicmonitors run --enable-lid-events";
        Restart = "on-failure";
        RestartSec = "3s";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

  };

}
```

- [ ] **Step 2: Verify the file evaluates**

```bash
nix build ~/nixosConf#nixosConfigurations.hm-pc-ws-01.config.system.build.toplevel --no-link 2>&1
```

Expected: build succeeds (or fails only on unrelated warnings, not on monitors.nix).
If it fails with "attribute 'monitors' missing", proceed to Task 2 first.

- [ ] **Step 3: Commit**

```bash
git add modules/features/desktop/hyprland/monitors.nix
git commit -m "feat: add monitors module skeleton with hyprdynamicmonitors service"
```

---

### Task 2: Integrate into `homeModules.metaHyprland`

**Files:**
- Modify: `modules/features/desktop/hyprland/default.nix`

- [ ] **Step 1: Add `monitors` to the home meta module imports**

In `modules/features/desktop/hyprland/default.nix`, add `self.homeModules.monitors` to `homeModules.metaHyprland`:

```nix
{ self, inputs, ... }: {

  flake.nixosModules.metaHyprland = { ... }: {

    imports = [
      self.nixosModules.commonDesktop
      self.nixosModules.hyprland
      self.nixosModules.ly
      self.nixosModules.waybar
      self.nixosModules.mako
      self.nixosModules.kitty
      self.nixosModules.nemo
    ];

  };

  flake.homeModules.metaHyprland = { ... }: {

    imports = [
      self.homeModules.commonDesktop
      self.homeModules.hyprland
      self.homeModules.waybar
      self.homeModules.mako
      self.homeModules.kitty
      self.homeModules.nemo
      self.homeModules.rofi
      self.homeModules.monitors
    ];

  };

}
```

- [ ] **Step 2: Verify the config evaluates cleanly**

```bash
nix build ~/nixosConf#nixosConfigurations.hm-pc-ws-01.config.system.build.toplevel --no-link 2>&1
```

Expected: build succeeds.

- [ ] **Step 3: Commit**

```bash
git add modules/features/desktop/hyprland/default.nix
git commit -m "feat: integrate monitors module into metaHyprland"
```

---

### Task 3: Rebuild and verify tools are available

- [ ] **Step 1: Rebuild the system**

```bash
sudo nixos-rebuild switch --flake ~/nixosConf#
```

Expected: switch completes, `home-manager-joshua.service` activates successfully.

- [ ] **Step 2: Verify `hyprdynamicmonitors` is on PATH**

```bash
hyprdynamicmonitors --version
```

Expected: `hyprdynamicmonitors version 1.4.0` (or similar).

- [ ] **Step 3: Verify `nwg-displays` is on PATH**

```bash
which nwg-displays
```

Expected: a path under `/nix/store/...` or similar.

- [ ] **Step 4: Verify systemd service is loaded (not yet started — no config file yet)**

```bash
systemctl --user status hyprdynamicmonitors.service
```

Expected: `Loaded` but likely `inactive` or `failed` — no config.toml exists yet. That's fine.

---

## Phase 2: Profile Generation

### Task 4: Generate the `docked` profile

**Prerequisites:** All three external monitors must be connected and Hyprland must be running with them active.

- [ ] **Step 1: Verify all monitors are detected**

```bash
hyprctl monitors
```

Expected: 4 monitors listed (3 external + laptop built-in). Note the `description` field for each — this is what `hyprdynamicmonitors` uses to match profiles (not the connector name like `DP-1`).

Example output to look for:
```
Monitor DP-1 (ID 0):
    ...
    description: Some Manufacturer Model SERIALNUMBER
```

- [ ] **Step 2: Run `nwg-displays` to visually confirm and arrange the layout**

```bash
nwg-displays
```

Drag monitors into the correct arrangement (left external | primary | vertical right | laptop below primary). Apply. This configures Hyprland for the current session but does not persist — it's just for visual verification.

- [ ] **Step 3: Freeze the current config as the `docked` profile**

```bash
hyprdynamicmonitors freeze --profile-name docked
```

Expected: Creates `~/.config/hyprdynamicmonitors/config.toml` (with a `docked` profile entry) and `~/.config/hyprdynamicmonitors/hyprconfigs/docked.go.tmpl`.

- [ ] **Step 4: Inspect the generated files**

```bash
cat ~/.config/hyprdynamicmonitors/config.toml
cat ~/.config/hyprdynamicmonitors/hyprconfigs/docked.go.tmpl
```

Verify the profile lists the correct monitors by description and the template contains the expected monitor layout commands.

---

### Task 5: Generate the `undocked` profile

**Prerequisites:** All external monitors must be disconnected.

- [ ] **Step 1: Disconnect all external monitors and verify only the laptop screen is active**

```bash
hyprctl monitors
```

Expected: 1 monitor listed (the laptop built-in).

- [ ] **Step 2: Freeze the current config as the `undocked` profile**

```bash
hyprdynamicmonitors freeze --profile-name undocked
```

Expected: Appends an `undocked` profile entry to `~/.config/hyprdynamicmonitors/config.toml` and creates `~/.config/hyprdynamicmonitors/hyprconfigs/undocked.go.tmpl`.

- [ ] **Step 3: Validate the full config**

```bash
hyprdynamicmonitors validate
```

Expected: no errors.

- [ ] **Step 4: Inspect the final config**

```bash
cat ~/.config/hyprdynamicmonitors/config.toml
cat ~/.config/hyprdynamicmonitors/hyprconfigs/undocked.go.tmpl
```

---

## Phase 3: Make Config Declarative

### Task 6: Encode generated configs in Nix

**Files:**
- Modify: `modules/features/desktop/hyprland/monitors.nix`

The goal is to copy the content of the generated files into `home.file` entries so they are reproduced declaratively on any host rebuild.

- [ ] **Step 1: Read the generated `config.toml` and encode it**

Run `cat ~/.config/hyprdynamicmonitors/config.toml` and copy its full output into `monitors.nix` as a `home.file` entry:

```nix
home.file.".config/hyprdynamicmonitors/config.toml" = {
  force = true;
  text = ''
    <full output of: cat ~/.config/hyprdynamicmonitors/config.toml>
  '';
};
```

The file will contain two profile blocks — one for `docked` (requiring 3 external monitors by description) and one for `undocked` (requiring only the laptop built-in). Each block references its `.go.tmpl` template path.

- [ ] **Step 2: Encode the `docked.go.tmpl` template**

Run `cat ~/.config/hyprdynamicmonitors/hyprconfigs/docked.go.tmpl` and copy its full output:

```nix
home.file.".config/hyprdynamicmonitors/hyprconfigs/docked.go.tmpl" = {
  force = true;
  text = ''
    <full output of: cat ~/.config/hyprdynamicmonitors/hyprconfigs/docked.go.tmpl>
  '';
};
```

This file contains Go template syntax wrapping `hyprctl` monitor configuration commands for the 4-monitor docked layout.

- [ ] **Step 3: Encode the `undocked.go.tmpl` template**

Run `cat ~/.config/hyprdynamicmonitors/hyprconfigs/undocked.go.tmpl` and copy its full output:

```nix
home.file.".config/hyprdynamicmonitors/hyprconfigs/undocked.go.tmpl" = {
  force = true;
  text = ''
    <full output of: cat ~/.config/hyprdynamicmonitors/hyprconfigs/undocked.go.tmpl>
  '';
};
```

- [ ] **Step 4: Verify the config evaluates**

```bash
nix build ~/nixosConf#nixosConfigurations.hm-pc-ws-01.config.system.build.toplevel --no-link 2>&1
```

Expected: build succeeds.

- [ ] **Step 5: Commit**

```bash
git add modules/features/desktop/hyprland/monitors.nix
git commit -m "feat: encode hyprdynamicmonitors profiles declaratively"
```

---

### Task 7: Rebuild and test auto-switching

- [ ] **Step 1: Rebuild**

```bash
sudo nixos-rebuild switch --flake ~/nixosConf#
```

Expected: switch completes cleanly.

- [ ] **Step 2: Verify the service is running**

```bash
systemctl --user status hyprdynamicmonitors.service
```

Expected: `active (running)`.

- [ ] **Step 3: Test docked switching**

Connect all external monitors. Wait ~2 seconds.

```bash
hyprctl monitors
```

Expected: All 4 monitors active with the layout from the `docked` profile.

- [ ] **Step 4: Test undocked switching**

Disconnect all external monitors. Wait ~2 seconds.

```bash
hyprctl monitors
```

Expected: Only the laptop built-in is active.

- [ ] **Step 5: Push**

```bash
git push
```
