#!/usr/bin/env bash
set -euo pipefail

plugin_root=$(cd "$(dirname "$0")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT

cat >"$test_root/herdr" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
runtime=${TEST_HERDR_RUNTIME:?}
case "$1 $2" in
  "api snapshot")
    IFS=$'\t' read -r workspace tab <"$runtime/focus"
    jq -nc --arg workspace "$workspace" --arg tab "$tab" \
      '{result:{snapshot:{focused_workspace_id:$workspace,focused_tab_id:$tab}}}'
    ;;
  "workspace focus")
    IFS=$'\t' read -r _ tab <"$runtime/focus"
    printf '%s\t%s\n' "$3" "$tab" >"$runtime/focus"
    printf '%s\n' "$3" >>"$runtime/workspace-focuses"
    ;;
  "tab focus")
    IFS=$'\t' read -r workspace _ <"$runtime/focus"
    printf '%s\t%s\n' "$workspace" "$3" >"$runtime/focus"
    printf '%s\n' "$3" >>"$runtime/tab-focuses"
    ;;
  *) exit 64 ;;
esac
EOF
chmod +x "$test_root/herdr"
mkdir -p "$test_root/state" "$test_root/runtime"
printf 'w1\tt1\n' >"$test_root/runtime/focus"

export HERDR_BIN_PATH="$test_root/herdr"
export HERDR_PLUGIN_STATE_DIR="$test_root/state"
export TEST_HERDR_RUNTIME="$test_root/runtime"

"$plugin_root/last-focus" startup
HERDR_PLUGIN_EVENT_JSON='{"event":"tab_created","data":{"tab":{"workspace_id":"w1","tab_id":"t2"}}}' \
  "$plugin_root/last-focus" track
printf 'w1\tt2\n' >"$test_root/runtime/focus"
HERDR_WORKSPACE_ID=w1 HERDR_TAB_ID=t2 "$plugin_root/last-focus" last-tab
HERDR_WORKSPACE_ID=w1 HERDR_TAB_ID=t1 "$plugin_root/last-focus" last-tab

HERDR_PLUGIN_EVENT_JSON='{"event":"workspace_focused","data":{"workspace_id":"w2"}}' \
  "$plugin_root/last-focus" track
printf 'w2\tt9\n' >"$test_root/runtime/focus"
HERDR_WORKSPACE_ID=w2 "$plugin_root/last-focus" last-workspace
HERDR_WORKSPACE_ID=w1 "$plugin_root/last-focus" last-workspace

diff -u <(printf 't1\nt2\n') "$test_root/runtime/tab-focuses"
diff -u <(printf 'w1\nw2\n') "$test_root/runtime/workspace-focuses"
echo 'last-focus tests passed'
