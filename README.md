base: the first toolkit on every machine: shell, git, YubiKey auth, tailnet, and the toolkit installer itself.

## What a toolkit is
A toolkit is one feature of a machine, kept in its own git repo: every
file, package, and command that feature needs. It targets *nix systems
with something resembling the FHS and a $HOME in /home (or /Users) named
after me.

Why toolkits
  - Editing a monorepo slows down evolution of dotfiles when multiple
    machines are involved: there is constant mental overhead remembering
    what is not checked in on each machine.
  - The old repo was sliced by platform (common, linux-arch, omarchy, mac),
    so one feature was scattered across layers. A toolkit keeps a feature
    in one place, and a machine is just the set of toolkits it has.

Where they live
  - ~/infra is a plain folder of toolkit clones: not a repo, not submodules.
    Every toolkit, base included, lives at ~/infra/toolkits/<name>.
  - base is public and cloned over https from GitHub, so a new machine can
    get it before any auth exists. Every other toolkit is private and
    cloned from closet over the tailnet:
      git clone git@closet:toolkits/<name>.git ~/infra/toolkits/<name>
  - What exists: `ssh closet ls /mnt/state/git/toolkits`. The first line
    of each README is a one-line summary.

## Properties every toolkit must have
1. **One feature.** Find all the strands of a feature (packages, config
   files, services, /etc files, env vars, setup commands, agent context,
   skills) and pull them into one toolkit, with scripts that set it up.
2. **Owns its paths.** Two toolkits never ship the same file. When two need
   to shape one program, use the program's include mechanism (zsh `source`,
   ghostty `config-file`, ssh `Include`, hyprland `source`, xremap's multiple
   config files) or, if it has none, build the file from pieces (below).
3. **Idempotent.** Installing twice is the same as installing once: the
   second run changes nothing, makes no copies, and destroys nothing. Setup
   checks the state instead of recording that it ran.
4. **Removable.** Unlinking a toolkit takes its files, its pieces, and its
   contribution to built files with it.
5. **Private by default.** Only base is public. Work content (company names,
   work repos, work servers) lives only in work toolkits.
6. **Verifiable.** verify.d proves the feature works, e.g. `ssh -T
   git@github.com` authenticates.

## Layout
Only the folders a toolkit needs are present.

    <toolkit>/
      README.md       first line: one-line summary
      home/           channel 1: symlinked into $HOME
      home-linux/     channel 1: same, Linux only (home-darwin/: macOS only)
      root/           channel 1: installed (copied) into /
      packages/       channel 2: pacman.txt, aur.txt, brew.txt
      setup.d/*.sh    channel 3: idempotent commands
      verify.d/*.sh   checks that the toolkit works
      NEXT.txt        channel 4: manual steps

## The 4 golden channels
Use them in order. Only drop to the next channel when the previous ones
can't do the job.

1. **Files.** home/ files are symlinked into $HOME with links.set (GNU
   stow). root/ files are copied, never linked: a root config linked into a
   repo I can write without sudo is root config anyone running as me can
   change.
2. **Packages.** Several package managers side by side: pacman and yay on
   Arch, brew on macOS, mise for CLI tools and language runtimes everywhere.
3. **Commands.** For settings no file can express: `systemctl enable --now`,
   `chsh`, building a file from pieces, seeding a file a program owns. Each
   must be safe to run again.
4. **Manual steps.** Loud reminders of what I must click or type, printed
   last in one block so they can't scroll past. Only when 1 to 3 can't.

## Commands (all in base, ~/bin)
  - `toolkit.install <name>`: packages, links, root files, setup.d,
    verify.d, then NEXT.txt.
  - `links.set [-n] [-b] [-D] [name...]`: link (or with -D unlink) toolkits.
    -b moves a regular file in the way to <file>.pre-toolkit and replaces
    dangling links. Runs ~/.config/toolkits/after-link.d/* afterwards.
  - `links.scan`: read-only report: links per toolkit, broken links, links
    still into the old layout, set-aside files, built files.
  - `links.prune [--apply]`: remove broken links into toolkits or the old
    layout.
  - `links.adopt [-o] <toolkit> <file>`: move a home file into a toolkit and
    link it back (-o: this OS only).
  - `pieces.build OUT DIR`: build one file from the pieces in DIR.
  - `toolkit.new <name>`: start a private toolkit, with its repo on closet.

## Building a file from pieces
Some programs have no include mechanism, or rewrite their own config:
git's ~/.config/git/config, ~/AGENTS.md, Claude's settings.json, Codex's
config.toml. Each toolkit links a piece into a `.d` folder, and a hook in
~/.config/toolkits/after-link.d runs `pieces.build`, so the built file
follows the toolkits that are linked right now.
  - JSON pieces are deep-merged. Keys the program adds itself are kept; a
    key a piece owns is reset to the piece (change it in the piece).
  - Other files are concatenated with a comment naming each piece's
    toolkit. If the program edited the built file, the edited copy is kept
    as OUT.drift-<time> and the diff is shown.

## Exceptions and gotchas we have hit
  - **base is platform sensitive.** It is the one toolkit every machine
    gets, so it carries home-linux/ and home-darwin/. Example: the YubiKey
    needs gpg-agent to see the Wayland session, which takes an autostart
    entry that only makes sense on Linux. A file belongs to exactly one of
    home/, home-linux/, home-darwin/. If this ever has to support two Linux
    desktops at once, this split is too coarse.
  - **Never link a file the program writes.** Claude wrote work content into
    a settings.json that was linked into the shared repo. Build such files
    from pieces instead.
  - **Omarchy owns some files.** Taking one over (e.g. ~/.config/git/config)
    moves Omarchy's copy aside; fold its defaults into a piece first.
  - **mise on Omarchy.** Omarchy ships mise-bin; never list mise in
    pacman.txt (it conflicts). brew.txt lists it for macOS.
  - **The global gitignore hides .claude/ and .pi/.** Toolkits that ship
    those folders carry a .gitignore that unignores them.
  - **Codex skips a SKILL.md that is a symlink**, so skill links point at the
    skill's real folder inside its toolkit.
  - **Claude @imports resolve from a file's real path**, which is inside the
    toolkit. Imports in linked files use absolute (~/...) paths.
  - **stow treats absolute links as foreign.** links.set drops an absolute
    link that already points at the toolkit's file so stow can relink it.

## Install log and uninstall (planned)
Each install appends to ~/.local/state/toolkits/<toolkit>.log: path,
sha256, the toolkit's git sha, and the time. On uninstall a copied file is
removed only if its checksum still matches; otherwise it stays and the
report says so. A different git sha than the logged one is reported as
drift.

## Bootstrapping a new machine
base installs the YubiKey setup, so it can't need ssh auth to get here:
  - base is public and cloned over https to ~/infra/toolkits/base.
  - Its installer needs only bash, git and stow (stage 1 installs stow
    before linking).
  - `curl -fsSLo boot https://mhkr.xyz/boot && less boot && bash boot`
    ends with the YubiKey and the tailnet working and base installed.
