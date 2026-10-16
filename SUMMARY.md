# Where we are

Goal: retire ~/infra (sliced by platform layer) into toolkits (sliced by
feature), each its own git repo. Open items live in OPEN-QUESTIONS.md.

## Decided
- A toolkit is one feature: its files, packages, and commands.
- ~/infra becomes a plain folder of toolkit clones (no umbrella repo, no
  submodules). Toolkits live under ~/infra so links.scan keeps working.
  ~/new-infra/toolkits is the staging area.
- base is always installed first, so it carries the toolkit installer.
- base = shell + YubiKey + gitconfig + shell utilities + installer.
- Ghostty and secrets are separate toolkits. Leaning toward migrating
  secrets from Bitwarden to KeePass.
- Not too atomic: about 2 or 3 toolkits on every machine, the rest
  pulled in on demand. Listing what exists matters more than dependency
  resolution.
- The 4 channels, used in order:
  1. files: home files linked (stow), root files copied
  2. packages: several package managers side by side
  3. commands: idempotent (systemctl, chsh, ...)
  4. loud reminders of manual steps, printed last
- Done = files placed, packages installed, services running, verified.
- links.set may become a stow wrapper; links.scan/prune/adopt and
  root.set stay custom.
- Auth chain: keep the existing GitHub-owned tailnet. Register 3
  YubiKeys (main + 2 cold-storage backups) as passkeys on that one
  GitHub account; recovery codes offline. New machine: tailscale up ->
  GitHub passkey -> ssh closet -> vault and private toolkits.
  (Tailscale Owner can't be removed/demoted/transferred on a shared
  domain, so no tailnet escapes an SSO owner.)
- Uninstall via an install log with checksums and git sha; remove only
  unchanged files (dpkg conffile style).

## Built so far
- README.md: base contents, Toolkit Primer, Layout, channels, install
  log, bootstrap.
- home/ and root/: channel 1 files copied (not moved) from ~/infra.
  Nothing linked into $HOME, nothing committed.
- OPEN-QUESTIONS.md.
- secrets/ exists as an empty folder.
- Tailscale is part of base (auth bootstrap): packages/pacman.txt,
  packages/brew.txt, setup.d/tailscaled.sh, verify.d/tailscale.sh,
  NEXT.txt. The old tailscale/ toolkit is deleted.
- hosts/ toolkit (private, git init, no commits): closet and office ssh
  entries in home/.ssh/config.d/hosts. To be pushed to closet.
- Private toolkits are cloned from closet:
  git clone git@closet:toolkits/<name>.git ~/infra/toolkits/<name>
- base .ssh/config now includes ~/.ssh/config.d/* so other toolkits
  can ship ssh hosts (collision rule in practice).

## Related sessions
- YubiKey-only auth / password manager: Claude session a977d861,
  ~/infra, herdr pane w6:p63 on xps.
- links.set vs GNU stow: Claude session da10313f, ~/infra, herdr pane
  w6:p5T on xps.
- browser-rig (agent browser toolkit candidate):
  ~/personal/01-cap-storage/browser-rig.
