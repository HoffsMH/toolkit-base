This is the base toolkit
It is always the first toolkit installed on a machine, so it also carries
the tooling that installs every other toolkit.

It will have:
  - Toolkit installer
    - link home files (stow wrapper), install root files, run setup
    - links.scan / links.prune / links.adopt
    - install log with checksums
  - Shell setup
    - zsh config
      - .zshrc
      - functions and aliases
    - zsh plugins like fast highlighting and autopair
    - zoxide
    - starship prompt
    - atuin
    - direnv
  - Shell utilities (trm, runlog, snip, clip, ...)
  - Git config
  - Yubikey setup
    - gpg-agent, scdaemon, pcscd
    - ssh config
  - Tailscale (auth bootstrap: passkey login, then ssh to closet)
    - tailscaled, ssh host entries for tailnet machines

Not here: Ghostty and secrets (KeePass) are their own toolkits.

## Toolkit Primer
A toolkit is one feature of a machine, kept in its own git repo: every
file, package, and command that feature needs. It targets *nix systems
with something resembling the FHS and a $HOME in /home named after the
user (me).

Why toolkits
  - Editing a monorepo slows down evolution of dotfiles when multiple
    machines are involved: there is constant mental overhead remembering
    what is not checked in on each machine.
  - In the old repo one feature is scattered across platform layers
    (common, linux-arch, omarchy, mac). A toolkit keeps it in one place.

How its different from the old infra mono-repo approach
  - The old repo is sliced by platform; toolkits are sliced by feature.
  - Every machine installs base (plus maybe 2 or 3 others), then pulls in
    only the toolkits it wants.
  - ~/infra is a plain folder of toolkit clones, not a repo and not
    submodules. Every active toolkit, base included, lives at
    ~/infra/toolkits/<name>:

    ~/infra/toolkits/
      base/       cloned over https from GitHub
      hosts/      cloned from git@closet:toolkits/hosts.git
      secrets/    cloned from git@closet:toolkits/secrets.git
      ...

  - base is the only toolkit cloned from GitHub. Every other one is
    cloned from closet over the tailnet:
      git clone git@closet:toolkits/<name>.git ~/infra/toolkits/<name>

How to discover what toolkits are available
  - The first line of each toolkit's README is a one-line summary.
  - `toolkit list` prints those lines.

How to create a new toolkit or extract a new one from an old one
  - Make a new repo under ~/infra/toolkits/ with the layout below.
  - `links.adopt` moves a home file into a toolkit and links it back.

How to avoid collisions with other toolkits
  - Each toolkit owns its paths. Two toolkits never ship the same file.
  - When two toolkits need to shape one program, use the program's own
    include mechanism and ship separate pieces:
    - zsh `source`, ghostty `config-file`, git `[include]`,
      ssh `Include`, hyprland `source`
    - xremap merges every config file it is given
      (general.yml from one toolkit, extra.yml from another)
  - A program with no include mechanism gets one owning toolkit, or its
    file is generated from pieces in channel 3.

## Layout
Every toolkit has the same shape so one installer works for all of them.
Only the folders a toolkit needs are present.

    <toolkit>/
      README.md       first line: one-line summary
      home/           channel 1: symlinked into $HOME
      root/           channel 1: installed (copied) into /
      packages/       channel 2: pacman.txt, aur.txt, brew.txt, mise.toml
      setup.d/*.sh    channel 3: idempotent commands
      verify.d/*.sh   checks that the toolkit works
      NEXT.txt        channel 4: manual steps

## The 4 golden channels
Use them in order. Only drop to the next channel when the previous ones
can't do the job.

- Channel 1 files
  - home files are symlinked using a combination of these scripts and stow
  - root files for security reasons have to be installed instead of linked
    (a root config symlinked into a repo I can write to without sudo is
    root config anyone running as me can change)

- Channel 2 software installation via package managers
  - must support multiple simultaneous package managers on same system ie
    - pacman + yay + omarchy, sitting alongside mise for dev dependencies

- Channel 3
  - commands that influence the settings of software whose files are impossible or impractical
    to influence via channel 1
    - examples
      - systemctl service enable --now X
      - restarting services
      - chsh for user
  - must be safe to run again: check the state, don't just record that it ran

- Channel 4
  - loud reminders to me of what I need to do or click manually
  - printed last, in one block, so they can't scroll past
  - This is only after all 3 previous channels can't be used


That's it if you:
  - place or link files in the correct spot.
  - Successfully install software dependencies.
  - successfully start services
  - verify it works (e.g. `ssh -T git@github.com` authenticates)

## Install log and uninstall
Each install appends to ~/.local/state/toolkits/<toolkit>.log: path,
sha256, the toolkit's git sha, and the time.

  - Symlinks need no checksum; the link target says where they came from.
  - On uninstall a file is removed only if its checksum still matches the
    log. If it changed, leave it and say so loudly.
  - If the toolkit's current git sha differs from the logged one, report
    the drift.

## Bootstrapping a new machine
base installs the yubikey setup, so it can't need ssh auth to get here:
  - base is public and cloned over https to ~/infra/toolkits/base
  - its installer needs only bash, git and stow (stage 1 installs stow
    before linking, since links.set needs it)
