#!/usr/bin/env bash
# Reproducible OS-level input for warp #11743 (Ctrl-Y yank conflict) on native Linux warp-oss.
#
# Usage:
#   1. Start the owned Xvfb :99 and Openbox services from services.yaml.
#   2. Launch a fresh logged-out app with services.yaml `launch_manual` as a background job and
#      keep its output file (it prints the fresh HOME) and PID.
#   3. demo.sh <default|workaround> <label> <launcher-output-file> <app-pid> <out-dir>
#      e.g. demo.sh default 01-before /tmp/launch.out 12345 evidence/m1-native/default-before
#
# Modes:
#   default     Fresh default preferences. Direct Ctrl-Y deletion, then three isolated
#               kill-then-Ctrl-Y probes (Ctrl-U at end, Ctrl-K at start, Ctrl-W at end).
#               Replay this mode unchanged for the fixed-build comparison.
#   workaround  Separate fresh HOME. Clears "Delete All Left" in Settings, then Ctrl-U/Ctrl-Y.
#               Its preferences must never be reused for a default-state run.
#
# Return is never pressed after onboarding, so sentinels are never executed as commands.
set -euo pipefail

MODE=${1:?mode}; LABEL=${2:?label}; LAUNCH_OUT=${3:?launcher output}; APP_PID=${4:?app pid}
OUT=${5:?out dir}
case "$MODE" in default|workaround) ;; *) echo "unknown mode $MODE" >&2; exit 2 ;; esac

export DISPLAY=:99
REPO=/home/factory-user/warp-stanford
BASE_SHA=f411fbc20e6283a2abcdd1ed64bf5b67df864f82
BIN=$REPO/target/debug/warp-oss
TYPE_DELAY_MS=90
HOLD_TYPED=2.5
HOLD_RESULT=3
HOLD_STEP=2

# Screen coordinates on the 1600x1000 display. Onboarding is shown in the app's initial
# 1280x800 window at (160,100); everything else runs after resizing it to fill the screen.
ONBOARDING_SKIP_X=541; ONBOARDING_SKIP_Y=834
INPUT_X=800; INPUT_Y=966
SETTINGS_KEYBOARD_X=334; SETTINGS_KEYBOARD_Y=348
SETTINGS_SEARCH_X=1300; SETTINGS_SEARCH_Y=181
SETTINGS_ROW_X=1031; SETTINGS_ROW_Y=244
SETTINGS_CLEAR_X=1259; SETTINGS_CLEAR_Y=310
SESSION_TAB_X=80; SESSION_TAB_Y=97
CLOSE_X=1573; CLOSE_Y=17

mkdir -p "$OUT/frames"
EVENTS=$OUT/events.tsv
LAUNCH=$OUT/launch.txt

now() { date +%s.%N; }
rel() { awk -v a="$1" -v b="$T0" 'BEGIN { printf "%.3f", a - b }'; }
ev() { printf '%s\t%s\t%s\n' "$(rel "$(now)")" "$1" "$2" >> "$EVENTS"; }
hold() { printf '%s\thold\t%s\t%s\n' "$(rel "$(now)")" "$1" "$2" >> "$EVENTS"; sleep "$2"; }
typ() { ev type "$1"; xdotool type --delay "$TYPE_DELAY_MS" "$1"; }
key() { ev key "$1"; xdotool key "$1"; }
click() { ev click "$1 at $2,$3"; xdotool mousemove "$2" "$3" click 1; }
# Moves to the end and erases more characters than any sentinel holds. BackSpace is not a
# kill command, so it leaves the kill buffer alone.
reset_input() { ev reset "End, BackSpace x30"; xdotool key End; xdotool key --delay 20 --repeat 30 BackSpace; }

APP_HOME=$(sed -n 's/^HOME=\([^\\]*\).*/\1/p' "$LAUNCH_OUT" | head -1)
test -n "$APP_HOME" && test -d "$APP_HOME"
test "$(ps -p "$APP_PID" -o comm=)" = warp-oss
grep -qz "^HOME=$APP_HOME\$" "/proc/$APP_PID/environ"
if grep -qz '^WARP_INTEGRATION=' "/proc/$APP_PID/environ"; then echo "integration env set" >&2; exit 3; fi

{
  echo "mode=$MODE label=$LABEL started=$(date -Is)"
  echo "app_pid=$APP_PID app_home=$APP_HOME"
  echo "launcher_output:"; sed 's/^/  /' "$LAUNCH_OUT"; echo
  echo "app_env:"; tr '\0' '\n' < "/proc/$APP_PID/environ" \
    | grep -E '^(HOME|XDG_RUNTIME_DIR|DISPLAY|WGPU_BACKEND|SHELL|WARP_SHELL_PATH)=' | sed 's/^/  /'
  echo "repo_head=$(git -C "$REPO" rev-parse HEAD) branch=$(git -C "$REPO" branch --show-current)"
  echo "product_diff_vs_base (excluding crates/integration):"
  git -C "$REPO" diff --stat "$BASE_SHA" HEAD -- . ':(exclude)crates/integration' | sed 's/^/  /'
  echo "  (end)"
  echo "binary=$BIN mtime=$(stat -c %y "$BIN") sha256=$(sha256sum "$BIN" | cut -d' ' -f1)"
  echo "display_geometry=$(xdotool getdisplaygeometry)"
  echo "home_contents_before_onboarding:"; (cd "$APP_HOME" && find . -maxdepth 3 | sort | sed 's/^/  /')
} > "$LAUNCH"

WIN=
for _ in $(seq 1 60); do
  WIN=$(xdotool search --onlyvisible --class dev.warp.WarpOss 2>/dev/null | head -1 || true)
  test -n "$WIN" && break; sleep 1
done
test -n "$WIN"
sleep 4

# Logged-out onboarding: Get started, default keybindings, default theme, Skip for now, confirm.
xdotool windowactivate --sync "$WIN"
xdotool key Return; sleep 2
xdotool key Return; sleep 2
xdotool key Return; sleep 2
xdotool mousemove "$ONBOARDING_SKIP_X" "$ONBOARDING_SKIP_Y" click 1; sleep 2
xdotool key Return; sleep 6
xdotool windowmove "$WIN" 0 0 windowsize "$WIN" 1600 1000; sleep 2
import -window root "$OUT/frames/$LABEL-00-after-onboarding.png"

descendants() {
  local frontier=$1 all=
  while test -n "$frontier"; do
    local next=
    for p in $frontier; do next="$next $(ps -o pid= --ppid "$p" | tr '\n' ' ' || true)"; done
    all="$all $next"; frontier=$(echo $next)
  done
  echo $all
}
SHELL_PID=
for _ in $(seq 1 30); do
  for p in $(descendants "$APP_PID"); do
    case "$(ps -p "$p" -o comm= 2>/dev/null)" in zsh|bash|fish) SHELL_PID=$p ;; esac
  done
  test -n "$SHELL_PID" && break; sleep 1
done
{
  echo "child_shell_pid=$SHELL_PID"
  echo "child_shell_cmd=$(ps -p "$SHELL_PID" -o args=)"
  echo "child_shell_exe=$(readlink "/proc/$SHELL_PID/exe")"
  echo "child_shell_version=$("$(readlink "/proc/$SHELL_PID/exe")" --version | head -1)"
  echo "keybindings_yaml_before_capture=$(test -e "$APP_HOME/.config/warp-oss/keybindings.yaml" && echo present || echo absent)"
} >> "$LAUNCH"
case "$(ps -p "$SHELL_PID" -o comm=)" in zsh) ;; *) echo "child shell is not zsh" >&2; exit 4 ;; esac
if test "$MODE" = default && test -e "$APP_HOME/.config/warp-oss/keybindings.yaml"; then
  echo "default run has custom keybindings" >&2; exit 5
fi

xdotool mousemove "$INPUT_X" "$INPUT_Y" click 1; sleep 1

VIDEO=$OUT/$LABEL.mp4
printf 't_rel_s\tkind\tdetail\thold_s\n' > "$EVENTS"
T0=$(now)
ffmpeg -nostdin -hide_banner -loglevel warning -y -f x11grab -framerate 30 -video_size 1600x1000 \
  -i :99.0 -an -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p -r 30 \
  -movflags +faststart "$VIDEO" > "$OUT/ffmpeg.log" 2>&1 &
FFMPEG_PID=$!
echo "ffmpeg_pid=$FFMPEG_PID t0_epoch=$T0" >> "$LAUNCH"
sleep 1.5
ev start "capture running, empty input at prompt"
hold empty-prompt "$HOLD_STEP"

if test "$MODE" = default; then
  ev section "1 direct Ctrl-Y: input 'alpha beta', cursor at end"
  typ 'alpha beta'
  hold typed-alpha-beta "$HOLD_TYPED"
  key ctrl+y
  hold after-direct-ctrl-y "$HOLD_RESULT"
  reset_input

  ev section "2 Ctrl-U probe: input 'kill-u-sentinel', cursor at end"
  typ 'kill-u-sentinel'
  hold typed-kill-u "$HOLD_TYPED"
  key ctrl+u
  hold after-ctrl-u "$HOLD_RESULT"
  key ctrl+y
  hold after-ctrl-u-ctrl-y "$HOLD_RESULT"
  reset_input

  ev section "3 Ctrl-K probe: input 'kill-k-sentinel', cursor moved to start with Home"
  typ 'kill-k-sentinel'
  key Home
  hold typed-kill-k-cursor-start "$HOLD_TYPED"
  key ctrl+k
  hold after-ctrl-k "$HOLD_RESULT"
  key ctrl+y
  hold after-ctrl-k-ctrl-y "$HOLD_RESULT"
  reset_input

  ev section "4 Ctrl-W probe: input 'first second', cursor at end"
  typ 'first second'
  hold typed-first-second "$HOLD_TYPED"
  key ctrl+w
  hold after-ctrl-w "$HOLD_RESULT"
  key ctrl+y
  hold after-ctrl-w-ctrl-y "$HOLD_RESULT"
  reset_input
  hold final-reset "$HOLD_STEP"
else
  ev section "W1 open Settings > Keyboard shortcuts and clear Delete All Left"
  key ctrl+comma
  hold settings-open "$HOLD_STEP"
  click keyboard-shortcuts "$SETTINGS_KEYBOARD_X" "$SETTINGS_KEYBOARD_Y"
  hold keyboard-shortcuts-page "$HOLD_STEP"
  click search-box "$SETTINGS_SEARCH_X" "$SETTINGS_SEARCH_Y"
  typ 'Delete all left'
  hold delete-all-left-ctrl-y "$HOLD_TYPED"
  click delete-all-left-row "$SETTINGS_ROW_X" "$SETTINGS_ROW_Y"
  hold binding-editor-open "$HOLD_STEP"
  click clear-button "$SETTINGS_CLEAR_X" "$SETTINGS_CLEAR_Y"
  hold delete-all-left-cleared "$HOLD_RESULT"

  ev section "W2 back to prompt: input 'kill-u-sentinel', cursor at end"
  click session-tab "$SESSION_TAB_X" "$SESSION_TAB_Y"
  sleep 1
  click input "$INPUT_X" "$INPUT_Y"
  sleep 0.5
  typ 'kill-u-sentinel'
  hold typed-kill-u "$HOLD_TYPED"
  key ctrl+u
  hold after-ctrl-u "$HOLD_RESULT"
  key ctrl+y
  hold after-ctrl-u-ctrl-y "$HOLD_RESULT"
  reset_input
  hold final-reset "$HOLD_STEP"
fi

ev stop "stopping capture"
T_STOP=$(now)
# Background jobs of a non-interactive shell ignore SIGINT; ffmpeg also finalizes on TERM.
kill -TERM "$FFMPEG_PID"
wait "$FFMPEG_PID" || true
echo "capture_wall_s=$(rel "$T_STOP")" >> "$LAUNCH"

if test -e "$APP_HOME/.config/warp-oss/keybindings.yaml"; then
  cp "$APP_HOME/.config/warp-oss/keybindings.yaml" "$OUT/keybindings.yaml"
fi

# Normal window close; a TERM triggers crash recovery instead of a clean exit.
xdotool mousemove "$CLOSE_X" "$CLOSE_Y" click 1
for i in $(seq 1 20); do
  sleep 1
  if ! ps -p "$APP_PID" > /dev/null; then echo "app_exited_after_close_s=$i" >> "$LAUNCH"; break; fi
done
ps -p "$APP_PID" > /dev/null && echo "app_still_running_after_close=yes" >> "$LAUNCH"

ffprobe -v error -show_entries format=duration,size:stream=codec_type,codec_name,pix_fmt,width,height,r_frame_rate,nb_frames \
  -of default=noprint_wrappers=1 "$VIDEO" > "$OUT/ffprobe.txt"

# x11grab starts recording a little after T0, so event times are shifted onto the video clock
# by the difference between capture wall time and encoded duration.
DURATION=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO")
OFFSET=$(awk -v w="$(rel "$T_STOP")" -v d="$DURATION" 'BEGIN { o = w - d; if (o < 0) o = 0; printf "%.3f", o }')
echo "video_duration_s=$DURATION video_start_offset_s=$OFFSET" >> "$LAUNCH"
awk -F'\t' -v o="$OFFSET" 'BEGIN { OFS = "\t" }
  NR == 1 { print "t_video_s", $2, $3, $4; next }
  { printf "%.3f\t%s\t%s\t%s\n", $1 - o, $2, $3, $4 }' "$EVENTS" > "$OUT/events-video.tsv"

# One frame per hold, at its midpoint on the video clock.
n=0
while IFS=$'\t' read -r t kind name secs; do
  test "$kind" = hold || continue
  n=$((n + 1))
  at=$(awk -v t="$t" -v s="$secs" 'BEGIN { printf "%.3f", t + s / 2 }')
  ffmpeg -nostdin -hide_banner -loglevel error -y -ss "$at" -i "$VIDEO" -frames:v 1 \
    "$OUT/frames/$LABEL-$(printf %02d "$n")-$name.png"
  printf '%s\t%s\n' "$(printf %02d "$n")-$name" "$at" >> "$OUT/frames.tsv"
done < <(tail -n +2 "$OUT/events-video.tsv")
echo "done $(date -Is)" >> "$LAUNCH"
