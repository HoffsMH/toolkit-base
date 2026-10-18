-- Clipboard that follows the terminal you are attached to rather than the host
-- nvim runs on: every copy is an OSC 52 write to our own tty, which ghostty
-- turns into that machine's clipboard - through tmux or herdr, local or remote.
-- So yanking in a herdr pane on office, driven from xps, lands on xps.
--
-- Two herdr/nvim details this leans on:
--   * herdr bridges only the "c" selection, so * is routed there too rather
--     than to OSC 52's "p" (primary), which herdr drops.
--   * paste never queries the terminal. An unanswered OSC 52 read blocks nvim
--     for 10s (see :h vim.ui.clipboard.osc52). Locally we read wl-paste;
--     over SSH we hand back what we last copied. To paste the attached
--     machine's real clipboard there, use the terminal's own paste.
local M = {}

function M.setup()
  -- '+' selects the "c" selection in nvim's own osc52 helper; '*' would be "p".
  local emit = require("vim.ui.clipboard.osc52").copy("+")
  local last = { { "" }, "v" }

  local function copy(lines, regtype)
    last = { lines, regtype }
    emit(lines)
  end

  -- Local session: the Wayland clipboard is the terminal's clipboard, so read it.
  -- Remote (SSH): it would be the far machine's, so fall back to our last copy.
  local local_wayland = vim.env.WAYLAND_DISPLAY ~= nil
    and vim.env.SSH_CONNECTION == nil
    and vim.fn.executable("wl-paste") == 1

  -- A herdr pane inherits the server's env, so SSH_CONNECTION misses a remote
  -- client attached via `herdr --remote`. Its bridge process gives it away.
  local function herdr_remote_attached()
    if vim.env.HERDR_PANE_ID == nil then
      return false
    end
    vim.fn.system({ "pgrep", "-f", "^[^ ]*/herdr remote-client-bridge$" })
    return vim.v.shell_error == 0
  end

  local function paste()
    if not local_wayland or herdr_remote_attached() then
      return last
    end
    local lines = vim.fn.systemlist({ "wl-paste", "--no-newline" }, "", 1)
    return vim.v.shell_error == 0 and lines or last
  end

  vim.g.clipboard = {
    name = "osc52",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end

return M
