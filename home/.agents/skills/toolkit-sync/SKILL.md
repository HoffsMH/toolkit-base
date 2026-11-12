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

## Policy: where the YubiKey is
- git over ssh (`git@closet`, `git@github.com`) needs the user's
  YubiKey. It is plugged into one machine at a time, usually the one the
  user sits at.
- On that machine, push and pull as git normally. A failure there is
  usually a touch or an expired PIN cache: ask for a touch, then retry.
- On every other machine, assume git over ssh fails, even if it worked
  there last time: the key may have moved. Use the anonymous and relay
  routes in step 3. Do not try `ssh -A`; it does not help.
- If the key is on a different machine than the one you run on, say so
  and ask whether to push from there instead.

## Policy: uncommitted changes you did not make
A clone (here or on a target) often holds edits from other sessions.
Never stash, discard, reset or commit them on your own. Commit only this
session's files, then ask the user which of these to do:
1. **Track for later.** Add one to-do item per change (file and a
   one-line guess at what it is) in the harness's to-do tracker, to
   review and sync later. Carry on syncing what is clean.
2. **Review now.** Find what made each change: search this and past
   agent sessions (the memory tool if there is one, else the harness's
   transcripts on that machine) for edits to those files. Walk the user
   through them one at a time: what changed, which session, why. For
   each, the user picks commit and sync, keep local, or drop.

A dirty target can still take a fast-forward if the incoming commits do
not touch its dirty files; git refuses otherwise. Either way, report the
dirty files.

## 1. Commit and push here
1. `git -C ~/infra/toolkits/<kit> status --short`. Anything not from
   this session: see the uncommitted-changes policy.
2. Commit in the repo's message style, no agent attribution.
3. Check `git remote -v` and the branch, then push. base goes to GitHub,
   every other kit to `git@closet:toolkits/<kit>.git`.

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
2. Check the clone: `git status --porcelain` (dirty: see the policy) and,
   after step 3's fetch, `git rev-list --count origin/<branch>..HEAD`
   must be 0. Ahead or diverged: skip and report; never rebase or reset.
3. Get the new commits there (the YubiKey is not on the target):
   - base is public: fetch anonymously into the tracking ref,
     `git fetch https://github.com/<owner>/<repo>.git
     +<branch>:refs/remotes/origin/<branch>`, then
     `git merge --ff-only origin/<branch>`.
   - Kits on closet: relay from the machine with the YubiKey as the
     normal user, `git push <target>:infra/toolkits/<kit>
     HEAD:refs/remotes/origin/<branch>`, then on the target
     `git merge --ff-only origin/<branch>`. Its tracking ref then
     matches closet.
4. Install: `toolkit.install <kit>` on the target.
5. `toolkit.install` stops at its packages step when sudo wants a
   password. Run `links.set <kit>` there instead (links and rebuilds
   pieces, no root), and report that the full install is still owed.

## 4. Report
One line per machine: synced (old..new sha), skipped (why), dirty files
left alone, not cloned, or unreachable. Nothing else.
