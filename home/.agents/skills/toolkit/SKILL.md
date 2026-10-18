---
name: toolkit
description: Create, extend, or fix a toolkit (~/infra/toolkits/<name>), the per-feature repos this machine is built from. Use when adding a program or setting to the machine, moving a dotfile into a toolkit, finding which toolkit owns a file, or checking that a toolkit installs cleanly.
---

# Toolkits

Read `~/infra/toolkits/base/README.md` first: properties, layout, the 4
channels, and the gotchas already hit. This skill is the procedure.

## Find the owner of a file
`readlink -f <file>`: a path under `~/infra/toolkits/<name>/` names the
owner. A file whose first line says "Built by pieces.build" is built: edit
the piece the comment names, never the file. `links.scan` shows the whole
picture.

## Build a toolkit for a feature
1. **Gather the strands.** For the feature, list everything that makes it
   work on this machine:
   - packages (`pacman -Qe`, `yay -Qm`, `mise ls`, `brew leaves`)
   - config under `~/.config`, dotfiles in `~`, `~/bin` scripts
   - systemd units (system and `--user`), timers, autostart entries
   - `/etc` files (`pacman -Qkk` lists edited ones)
   - env vars (`~/.zshenv`, `environment.d`)
   - commands that were run once (enable a service, add a group, chsh)
   - agent context (a piece for `~/.agents/context.d`) and skills
   - secrets it needs: reference them (secrets toolkit, KeePass); never
     copy a secret into a toolkit
2. **Pick or start the toolkit.** One feature per toolkit. New one:
   `toolkit.new <name>`. Work content goes only in a work toolkit
   (a work toolkit); base is public on GitHub.
3. **Place each strand in the lowest channel that can hold it.** Files in
   `home/` (or `home-linux/`/`home-darwin/` if only one OS needs it), `/etc`
   files in `root/`, packages in `packages/`, commands in `setup.d/`,
   clicks in `NEXT.txt`.
   - An existing home file: `links.adopt <toolkit> <file>`.
   - A program with an include mechanism: ship a separate piece.
   - A program without one, or one that rewrites its own config: ship a
     piece into a `.d` folder plus an after-link hook calling
     `pieces.build` (see the claude or codex toolkit).
4. **Write verify.d.** A check that the feature works, not that files exist.
5. **Install and prove idempotency.** `toolkit.install <name>` twice. The
   second run must change nothing: no "moved aside", "built", "installed"
   or `.drift-` output, no new `.pre-toolkit` files (`links.scan`).
6. **Context.** If agents need to know about the feature, ship a short
   piece in `home/.agents/context.d/NN-<name>.md` (30-49 personal,
   50-69 work) or a skill in `home/.agents/skills/<skill>/SKILL.md`.

## Porting from the old infra
`links.scan` lists links still into `~/old-infra`. Copy the source into
the right toolkit, then `links.set -b <toolkit>` replaces the old link.
Drop what is unused instead of porting it; ask the user when unsure.

## Boundaries
- Committing and pushing follow the Commit and Push switches in
  ~/AGENTS.md. `toolkit.new` creates a repo on closet; run it only when
  the user asked for the new toolkit.
- Never put secrets, tokens, or work content in base.
- Root files: write to /tmp, install with `sudo -n`, per Root commands.
- Do not delete a user's file to make room for a link: links.set -b
  moves it aside; compare, then ask before removing the copy.
