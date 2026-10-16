# Open questions

Leaning = current suggestion, not a decision.

## Toolkit shape
1. Is the README Layout right? (home/, root/, packages/, setup.d/,
   verify.d/, NEXT.txt)
2. How does a toolkit handle platform differences (mac, arch, omarchy)?
   Example: base has only the omarchy .zshrc; the mac one differs in
   brew shellenv, PATH, plugin paths.
3. When does ~/new-infra move to ~/infra/toolkits, and what happens to
   the old ~/infra repo in between? links.scan depends on the ~/infra path.
4. What are ~/new-infra/assets and ~/new-infra/credentials for, if
   anything?

## Installer (lives in base)
5. links.set becomes a stow wrapper (`stow --no-folding`). links.scan,
   links.prune, links.adopt, root.set stay custom. All still hardcode
   ~/infra/assets/workstation/<layer>; they need to take a toolkit dir.
6. Bootstrap says "only bash and git", but the stow wrapper needs stow.
   Leaning: channel 2 installs stow before channel 1 runs.
7. `toolkit list` / `toolkit add <name>`: names, where they live.
8. Install log: format and location
   (~/.local/state/toolkits/<tk>.log: path, sha256, git sha, time).
9. Channel 3 idempotency: check real state instead of bootstrap's
   `.done` marker files.

## base contents
10. (Resolved: the gcloud work lines live in a work toolkit via
    ~/.zsh/rc.d/*.zsh.) Where does the Wayland fix go?
11. (Resolved: tailnet host entries, herdr machines and atuin sync live
    in the private tailscale-hosts toolkit.)
12. .zsh/functions_and_aliases.sh (282 lines) needs a pass for
    non-base content.
13. home/bin was picked by name only. Review each script.
14. common/yubikey/configure-yubikey.sh (blank-key provisioning):
    include in base but never run by default?
15. Mac equivalents for gpg-agent.conf / scdaemon.conf.

## Channel 2 layering (not in README yet)
16. Leaning: fixed order system pm -> mise -> language pms. Each toolkit
    pins runtimes in its own mise.toml, never `mise use -g`. Install and
    run via `mise -C <tk> exec --`. Deps stay in the toolkit dir.
    base sets mise `trusted_config_paths = ["~/infra/toolkits"]`.

## Collisions
17. xremap: split general.yml (base or keyboard toolkit) from
    extra.yml (another toolkit); unit passes all files.
18. Programs with no include mechanism: single owning toolkit, or
    generate the file in channel 3?

## Agents (not in README yet)
19. Leaning: toolkits announce themselves to agents by shipping
    home/.claude/skills/<tk>/SKILL.md and home/.agents/skills/<tk>/SKILL.md.
    base ships a `toolkits` skill pointing at `toolkit list` for ones
    not installed. Each skill carries the boundaries block.
20. browser-rig: move from ~/personal/01-cap-storage (Syncthing) into
    ~/infra/toolkits (git). Fix its `mise use -g node@lts`.

## Other toolkits
21. secrets: Bitwarden -> KeePass migration.
22. ghostty toolkit.
23. Brave + extensions via /etc/brave/policies/managed (root/ file).
    Which toolkit?
24. Map the remaining ~250 ~/infra files to toolkits.

## Repos
25. Tailscale is in base (pacman.txt, brew.txt cask tailscale-app). Debian
    servers (apt repo, now in ansible/roles/debian/tailscale)?
26. (Resolved: base is public, cloned over https. Private toolkits live on
    closet, cloned with git clone git@closet:toolkits/<name>.git, served
    by a git-shell user on closet.)

## Auth bootstrap chain (YubiKey only)
Plan: new machine -> `tailscale up` -> browser -> GitHub "Sign in with a
passkey" (discoverable credential on the YubiKey, FIDO2 PIN + touch) ->
tailnet -> ssh closet -> KeePass vault and private toolkits. No Tailscale
Funnel needed.
27. Backup YubiKey: register each key as its own GitHub passkey (FIDO2
    credentials can't be cloned); load GPG keys on both from the thumb
    drive.
28. GitHub recovery codes: must live offline (thumb drive / paper), not
    only in KeePass on closet, or the chain is circular.
29. closet must be up to reach the vault. Second copy of the vault
    (phone via Syncthing)?
30. ssh to closet needs base installed first (GPG key). Alternative:
    add a FIDO2 ssh key (ed25519-sk, resident) so `ssh-keygen -K`
    works on a bare machine with only openssh + libfido2.
31. Tailnet settings: device approval and node key expiry (180 days
    default) may need admin-console steps on a new machine.
32. FIDO2 PIN is the one thing to remember (not the GitHub username).
33. Tailscale without GitHub. Researched (Tailscale docs Jan 2026,
    GitHub issues #15071, #16598 still open):
    - one passkey per user; no adding a second, no admin reset
    - passkey users can't create a tailnet, only be invited
    - passkey usernames can never be reused after deletion
    - passkey users can be Admin; Owner stays the GitHub login
    - Personal plan: 6 users, passkey users count
    Leaning: GitHub login stays the Owner (passkey on every YubiKey +
    offline recovery codes). One passkey admin user per YubiKey for
    everyday `tailscale up`. Lost key: remove that user, invite a new
    username (e.g. mh-yk3).
34. Challenge-response (HMAC-SHA1, OTP slot 2) CAN share one secret
    across keys: use it for KeePassXC vault unlock so any spare opens it.
35. Threat model includes corporations. Headscale rejected: still needs
    a hosted public node, and all maintenance and CVEs become mine.
    Leaning: Tailnet Lock, so the coordination server can't add nodes
    without a signature from my own trusted devices. Adds a channel 4
    step per new machine: `tailscale lock sign` from a trusted device.
