#!/usr/bin/env bash
# Settings-after screenshots on the Option A build. Steps 00-03 repeat settings-before.sh
# (same searches, same timing); step 04 opens the Yank row editor and cancels it without saving.
# Usage: settings-after.sh <launcher-output-file> <app-pid> <out-dir>
set -euo pipefail
LAUNCH_OUT=${1:?}; APP_PID=${2:?}; OUT=${3:?}
export DISPLAY=:99
REPO=/home/factory-user/warp-stanford
BIN=$REPO/target/debug/warp-oss
mkdir -p "$OUT"
APP_HOME=$(sed -n 's/^HOME=\([^\\]*\).*/\1/p' "$LAUNCH_OUT" | head -1)
test -d "$APP_HOME"
test "$(ps -p "$APP_PID" -o comm=)" = warp-oss
if grep -qz '^WARP_INTEGRATION=' "/proc/$APP_PID/environ"; then echo "integration env set" >&2; exit 3; fi
{
  echo "started=$(date -Is) app_pid=$APP_PID app_home=$APP_HOME"
  echo "repo_head=$(git -C "$REPO" rev-parse HEAD) branch=$(git -C "$REPO" branch --show-current)"
  echo "product_diff_vs_base (excluding crates/integration):"
  git -C "$REPO" diff --stat f411fbc20e6283a2abcdd1ed64bf5b67df864f82 -- . ':(exclude)crates/integration' ':(exclude)evidence' | sed 's/^/  /'
  echo "  (end)"
  echo "binary=$BIN mtime=$(stat -c %y "$BIN") sha256=$(sha256sum "$BIN" | cut -d' ' -f1)"
  echo "app_env:"; tr '\0' '\n' < "/proc/$APP_PID/environ" \
    | grep -E '^(HOME|XDG_RUNTIME_DIR|DISPLAY|WGPU_BACKEND|SHELL|WARP_SHELL_PATH)=' | sed 's/^/  /'
  echo "home_contents_before_onboarding:"; (cd "$APP_HOME" && find . -maxdepth 3 | sort | sed 's/^/  /')
} > "$OUT/launch.txt"
WIN=
for _ in $(seq 1 60); do
  WIN=$(xdotool search --onlyvisible --class dev.warp.WarpOss 2>/dev/null | head -1 || true)
  test -n "$WIN" && break; sleep 1
done
test -n "$WIN"; sleep 4
xdotool windowactivate --sync "$WIN"
xdotool key Return; sleep 2
xdotool key Return; sleep 2
xdotool key Return; sleep 2
xdotool mousemove 541 834 click 1; sleep 2
xdotool key Return; sleep 6
xdotool windowmove "$WIN" 0 0 windowsize "$WIN" 1600 1000; sleep 2
import -window root "$OUT/00-after-onboarding.png"
echo "keybindings_yaml=$(test -e "$APP_HOME/.config/warp-oss/keybindings.yaml" && echo present || echo absent)" >> "$OUT/launch.txt"
xdotool mousemove 800 966 click 1; sleep 1
xdotool key ctrl+comma; sleep 2
xdotool mousemove 334 348 click 1; sleep 2
xdotool mousemove 1300 181 click 1; sleep 1
xdotool type --delay 90 'Yank'; sleep 2
import -window root "$OUT/01-settings-search-yank.png"
xdotool key ctrl+a BackSpace; sleep 1
xdotool type --delay 90 'Delete all left'; sleep 2
import -window root "$OUT/02-settings-search-delete-all-left.png"
xdotool key ctrl+a BackSpace; sleep 1
xdotool type --delay 90 'ctrl y'; sleep 2
import -window root "$OUT/03-settings-search-ctrl-y.png"
xdotool key ctrl+a BackSpace; sleep 1
xdotool type --delay 90 'Yank'; sleep 2
xdotool mousemove 1031 244 click 1; sleep 2
import -window root "$OUT/04-yank-row-editor-open.png"
xdotool key Escape; sleep 2
import -window root "$OUT/05-yank-row-after-escape.png"
echo "keybindings_yaml_after=$(test -e "$APP_HOME/.config/warp-oss/keybindings.yaml" && echo present || echo absent)" >> "$OUT/launch.txt"
xdotool mousemove 1573 17 click 1
for i in $(seq 1 20); do sleep 1; if ! ps -p "$APP_PID" >/dev/null; then echo "app_exited_after_close_s=$i" >> "$OUT/launch.txt"; break; fi; done
ps -p "$APP_PID" >/dev/null && echo "app_still_running_after_close=yes" >> "$OUT/launch.txt"
echo "done $(date -Is)" >> "$OUT/launch.txt"
