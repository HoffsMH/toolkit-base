---
name: toolkit-sync
description: Commit, push and sync a change to an existing toolkit out to the user's other machines. Use right after finishing changes to a toolkit that lives on more than one machine, or when the user says "sync", "sync to other machines", or "commit push and sync". Not for a brand-new toolkit.
---

# Toolkit sync

## When to use it
- Finished a change to an existing toolkit: offer "Commit, push and
  sync?" A yes enables the Commit and Push switches for that change and
  is the instruction to pull on the other machines.
- A brand-new toolkit (`toolkit.new`): offer only commit and push to
  closet for safekeeping. No sync.

## 1. Commit and push here
1. `git -C ~/infra/toolkits/<kit> status --short`. Other sessions often
   leave uncommitted edits: stage only this change's files.
2. Commit in the repo's message style, no agent attribution.
3. Check `git remote -v` and the branch, then push. base goes to GitHub,
   every other kit to `git@closet:toolkits/<kit>.git`. Push failures are
   usually the YubiKey: ask for a touch.

## 2. Pick targets
1. Find the machines the user keeps a persistent ssh connection to.
   Today that is herdr's saved machines (`herdr machine list`, third
   column is the ssh target); another tool may hold them later, so look
   for whatever is in use.
2. Keep the user's main workstations, minus the machine you are on.
   Skip servers and hosted sites (the git host, a personal web server).
   Unsure about one? Ask.
3. Probe each: `ssh -o BatchMode=yes -o ConnectTimeout=5 <target> true`.
   No answer is "unreachable" (a laptop is often closed); move on.
4. Sync a kit only where it is already cloned:
   `ssh <target> test -d infra/toolkits/<kit>/.git`. Missing means the
   machine does not use that kit. Never clone it there.

## 3. Pull on each target
Non-interactive ssh misses `~/bin` on PATH: start every remote command
with `export PATH=$HOME/bin:$HOME/.local/bin:$PATH;`.

1. If base changed, sync base first: other kits' setup calls its commands.
2. Refuse to touch a dirty or diverged clone: `git status --porcelain`
   must be empty and `git rev-list --count @{upstream}..HEAD` must be 0.
   Otherwise skip and report what is there; do not stash, rebase or reset.
3. Get the new commits there:
   - base is cloned over https: `git pull --ff-only` works anonymously.
   - Kits on closet: the target's own ssh to `git@closet` needs a YubiKey
     that is not there, and `ssh -A` does not help. Relay from here as
     the normal user instead: `git push <target>:infra/toolkits/<kit>
     HEAD:refs/remotes/origin/<branch>`, then on the target
     `git merge --ff-only origin/<branch>`. This also leaves its tracking
     ref matching closet.
4. Install: `toolkit.install <kit>` on the target. Run it twice only if
   the first run reported changes you did not expect.
5. Anything that wants sudo and `sudo -n` refuses: stop on that host and
   report it; the user runs it.

## 4. Report
One line per machine: synced (old..new sha), skipped (why), not cloned,
or unreachable. Nothing else.
