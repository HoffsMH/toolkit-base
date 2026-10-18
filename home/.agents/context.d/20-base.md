# This machine (base toolkit)

## Toolkits

- The machine is built from toolkits: `~/infra/toolkits/<name>`, each its
  own git repo (base on GitHub, the rest on closet). A file in `$HOME` that
  is a symlink belongs to the toolkit its link points into.
- Before changing a dotfile, find its owner with `readlink -f`. Change the
  toolkit's copy, never a built file (one whose first line says "Built by
  pieces.build").
- How toolkits work and how to change them: the `toolkit` skill, and
  `~/infra/toolkits/base/README.md`.
- Available toolkits: `ssh closet ls /mnt/app-data/git/toolkits`.

## Keyboard

- **Mac-on-Linux keyboard.** Left-of-spacebar physical key sends
  Ctrl (Mac Cmd-equivalent on Linux) via xremap. Caps + bottom-left
  ctrl send Alt (shell readline M-keys, Alt+hjkl arrows). Right-of-
  spacebar is a HYPER chord (Ctrl+Alt+Super). When porting Mac
  configs, translate `cmd -> alt` on the source side.
- Layering: xremap, then ghostty, then herdr or tmux. A key xremap remaps
  never reaches the layers after it.

## Shell

- Commands run in `bash`, but the interactive shell is `zsh` where all
  aliases, functions, and some PATH additions live.
- Most utilities (`runlog`, `trm`, etc.) are standalone scripts in
  `~/bin/` or `~/.local/bin/` — they work in either shell.
- When adapting commands the user pastes from their zsh session,
  strip zsh-specific syntax/aliases and translate to bash equivalents.

## Runlog

- `runlog` (in `~/bin`) pipes a command's stdout+stderr to
  `../<dirname>-<command>.log`, skipping wrapper commands (bundle,
  npx, yarn, etc.) when naming the file.
- Use it when output will be too large and would pollute the context window AND
  you'll need to grep it repeatedly (test suites, builds, etc.).
- After running, **grep the log** instead of re-running the command.
- Don't blanket every command — just the noisy ones.

## Snips and screenshotting

- `snip [category]` saves the clipboard into
  `~/personal/00-cap-md/snip-<category>` (default `main`) as a
  timestamped, content-addressed file.
- Piped stdin overrides the clipboard and always saves as text:
  `echo "some plan" | snip plans`. Conventional categories: **`plans`**
  (hand-off plan docs) and **`prompt`** (agent launch prompts) -- see
  "Handing off work to another agent" below. Use this to save plans/notes
  for the user without touching their clipboard.

- `ss` means inspect my recent screenshot run in
  `~/personal/00-cap-md/snip-screenshot/`. Start with the newest and work
  backward until timestamps, image content, or this conversation show where
  the run began. Inspect every relevant image, including saved annotations.
  State the oldest screenshot included and why you stopped there.
  `ss N` (for example, `ss 1` or `ss 3`) means the run ends at or before
  the Nth newest screenshot. Inspect at most N screenshots; stop sooner if
  the run boundary is clear. Never inspect screenshot N+1 to check.
  `ss <category>` uses `snip-<category>` instead.
- `sf <category>` means inspect the newest file in `snip-<category>`.
- `ssc` means inspect the current clipboard image.

### `ssc` clipboard-image workflow

- `ssc` means: inspect the current image in the system clipboard. If it
  starts a longer prompt, inspect the image before investigating the rest.
- `ssc` reads the live system clipboard; `ss` reads saved files.
- Do not ask what `ssc` means.
- `ssc` does not imply archiving. Prefer direct inspection:
  1. Use the cross-platform helper:
     `ext="$(iclip type)" && iclip save "/tmp/omp-clipboard.${ext}"`
  2. Verify the file is nonempty.
  3. Use the image-capable `read` tool on the saved path.

- If `iclip` fails or finds no image, check the newest file in
  `snip-screenshot`; my screenshot shortcut saves there. If its timestamp
  is within a few minutes, inspect it and say that is what you did.
  Otherwise report that no image is available and quote iclip's error,
  which tells "no image on clipboard" apart from "backend unavailable".
- Do not inspect an existing file at the `iclip save` target path. A stale file
  from an earlier capture is not the image I asked about.
- Chain clipboard capture and validation with `&&`, not `;`, and use a fresh
  temporary path when possible.
- Prefer `iclip` because it abstracts Wayland, X11, and macOS clipboard
  implementations. Use a platform-specific command only if `iclip` is
  unavailable.
- Do not use text clipboard APIs or send binary image data through a text
  pathway.
- The screenshot shortcut and notification editor save directly to
  `snip-screenshot`; do not archive those captures again. Use `snip screenshot`
  only for a clipboard image that has not already been saved.
- When using `snip screenshot`, invoke it directly with no piped stdin:
  `snip screenshot`
- Never pipe binary image output into `snip` or an equivalent text pathway.
  Piped stdin forces `snip` into its text-input path.
- Do not substitute a newly captured desktop screenshot for the requested
  clipboard image.


