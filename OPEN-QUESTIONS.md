# Open questions

Toolkit-system questions still open. Leaning = current suggestion, not a
decision. Auth, YubiKey and security threads live in the private infra
specs (roadmap and identity decisions), not here.

## Installer
1. `toolkit list`: one line per available kit, installed or not.
   `toolkit.install` covers adding one.
2. Install log for safe uninstall (README "Install log and uninstall"):
   format and location. Leaning: ~/.local/state/toolkits/<tk>.log with
   path, sha256, git sha, time; remove only files that still match.

## base contents
3. .zsh/functions_and_aliases.sh needs a pass for non-base content and
   aliases to missing tools.
4. home/bin was picked by name only. Review each script; drop the dead
   ones (e.cap, nvim.cap, cap.sync, jrnl need missing tools).
5. Blank-key YubiKey provisioning (the old configure-yubikey.sh): bring
   it into base next to yubikey.setup, never run by default?

## Channel 2 layering
6. README covers the managers (pacman/yay, brew, mise). Still open: each
   kit pins runtimes in its own mise.toml, never `mise use -g`; run via
   `mise -C <kit> exec --`; base sets mise
   `trusted_config_paths = ["~/infra/toolkits"]` so kit configs need no
   `mise trust`.

## Other kits
7. Brave + extensions via /etc/brave/policies/managed (a root/ file).
   Which kit?
8. Tailscale on the Debian servers (apt repo, still only in the old
   monorepo's ansible role).

## Resolved
- Layout and platform splits: README Layout (home/, home-linux/,
  home-darwin/, root/, packages/, setup.d/, verify.d/, NEXT.txt).
- Kits live in ~/infra/toolkits; base public on GitHub, private kits on
  closet. ~/infra/credentials holds the KeePass vault (Syncthing, not git).
- links.set wraps stow; stage1 installs stow before base links.
- Channel 3 idempotency: README "Properties every toolkit must have".
- Files with no include mechanism: built from pieces (pieces.build).
- Collisions: xremap merges /etc/xremap/config.d/*.yml; ssh hosts via
  ~/.ssh/config.d/*; zsh via ~/.zsh/rc.d/*.zsh.
- Agent discovery: kits ship home/.agents/skills/<name>/SKILL.md; base
  ships the `toolkit` skill.
- Mac gpg: pinentry-dispatch picks pinentry-mac or pinentry-gnome3.
- Ghostty stayed in base (home/, home-linux/, home-darwin/).
- browser-rig moved into ~/infra/toolkits; its cleanup is on the specs
  roadmap.
