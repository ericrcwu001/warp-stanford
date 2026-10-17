# M1 native Linux reproduction: default Ctrl-Y behavior and Settings workaround

Both runs used the unchanged product source and the normal `warp-oss` binary, genuinely logged out, driven only by OS-level `xdotool` input from `../demo.sh`. The product diff against base `f411fbc20e6283a2abcdd1ed64bf5b67df864f82` outside `crates/integration` is empty at tested HEAD `c1db7c276e82d214277480879b7c41201dfa5651` (the only commit on top of the base is the test-only regression). Binary `target/debug/warp-oss`, built 2026-10-17 02:15 UTC from the base during readiness, sha256 `28023d477b4f12f2fed01ea8f92c97b2679b9020706dc40661be871cb352d721`.

## Environment (both runs)

- Owned Xvfb `:99` at 1600x1000x24 with `-nolisten tcp`, owned Openbox, software Vulkan (llvmpipe). Window resized to fill the 1600x1000 screen after onboarding with `xdotool windowmove/windowsize` (a window-manager operation, not a Warp preference).
- Launched with `services.yaml` `commands.launch_manual` as a managed background job: new `mktemp` HOME and mode-700 `XDG_RUNTIME_DIR` per run, nothing copied in, `WARP_INTEGRATION` unset, `WARP_SHELL_PATH=/usr/bin/zsh`. Each `launch.txt` records the app environment, an empty HOME before onboarding, and the actual child shell: `/usr/bin/zsh`, `zsh 5.9 (x86_64-ubuntu-linux-gnu)`, started by Warp as `-zsh -g --no_rcs`. This manual session is Zsh; the earlier M0 readiness session was Bash.
- Logged-out onboarding: Get started, default keybindings, default theme, Skip for now, confirm Skip. No account, sign-in or credentials.
- The terminal output area shows the host's login banner ("Factory Droid Computer") printed by the system Zsh startup files. No command was typed or run. Return is never pressed after onboarding, so no sentinel was executed.
- Capture: `ffmpeg -f x11grab -framerate 30 -video_size 1600x1000 -an -c:v libx264 -pix_fmt yuv420p -r 30`. Typing uses `xdotool type --delay 90`. The event log shows each typed string took about 50 ms per character (xdotool splits the delay between key press and release).
- Holds: 2 s for idle and Settings navigation steps, 2.5 s after typing, 3 s after each kill or yank.

## Run 1: default preferences (`01-before.mp4`)

Fresh HOME `/tmp/warp-11743-manual-home.XigUFj`; `keybindings.yaml` absent before capture (the script aborts if it exists). Files: `default-before/`. Video: `../01-before.mp4`, 192,808 bytes, 42.467 s, H.264, yuv420p, 1600x1000, 30/1 fps, one video stream and no audio. Video-clock events: `default-before/events-video.tsv` (start offset 0.040 s from the wall-clock log `events.tsv`). Frames are taken at the middle of each hold and were inspected visually.

Reset between probes: `End`, then 30 x `BackSpace` (longest sentinel is 15 characters). BackSpace is not a kill command.

| Step | Input and cursor | Key | Observed input afterwards | Frame (video time) |
| --- | --- | --- | --- | --- |
| Idle | empty | none | empty | `01-before-01-empty-prompt.png` (2.468 s) |
| 1 Direct Ctrl-Y | `alpha beta`, cursor at end | — | `alpha beta` | `01-before-02-typed-alpha-beta.png` (5.207 s) |
| | | Ctrl-Y | empty: everything left of the cursor was deleted | `01-before-03-after-direct-ctrl-y.png` (8.037 s) |
| 2 Ctrl-U probe | `kill-u-sentinel`, cursor at end | — | `kill-u-sentinel` | `01-before-04-typed-kill-u.png` (12.306 s) |
| | | Ctrl-U | empty | `01-before-05-after-ctrl-u.png` (15.125 s) |
| | | Ctrl-Y | empty: `kill-u-sentinel` was **not** restored | `01-before-06-after-ctrl-u-ctrl-y.png` (18.193 s) |
| 3 Ctrl-K probe | `kill-k-sentinel`, then `Home` (cursor at start, visible in frame) | — | `kill-k-sentinel` | `01-before-07-typed-kill-k-cursor-start.png` (22.443 s) |
| | | Ctrl-K | empty | `01-before-08-after-ctrl-k.png` (25.251 s) |
| | | Ctrl-Y | empty: `kill-k-sentinel` was not restored | `01-before-09-after-ctrl-k-ctrl-y.png` (28.320 s) |
| 4 Ctrl-W probe | `first second`, cursor at end | — | `first second` | `01-before-10-typed-first-second.png` (32.394 s) |
| | | Ctrl-W | `first ` (the word `second` removed) | `01-before-11-after-ctrl-w.png` (35.209 s) |
| | | Ctrl-Y | empty: `second` was not restored and the remaining `first ` was deleted | `01-before-12-after-ctrl-w-ctrl-y.png` (38.269 s) |
| Final | after reset | — | empty | `01-before-13-final-reset.png` (41.456 s) |

`01-before-00-after-onboarding.png` is a live screenshot taken before recording started.

What this shows: with default Linux preferences, Ctrl-Y acts as Delete All Left. In every probe, Ctrl-Y after a kill did not bring the killed text back. This run does not show why; the source trace is a separate M1 item.

## Run 2: Settings workaround (`01-workaround.mp4`)

A separate fresh HOME `/tmp/warp-11743-manual-home.Q7TYuT`, launched after run 1 had exited. `keybindings.yaml` absent before capture. Files: `workaround/`. Video: `../01-workaround.mp4`, 234,296 bytes, 30.200 s, H.264, yuv420p, 1600x1000, 30/1 fps, one video stream and no audio. Video-clock events: `workaround/events-video.tsv` (offset 0.027 s).

| Step | Action | Observed | Frame (video time) |
| --- | --- | --- | --- |
| Idle | — | empty prompt | `01-workaround-01-empty-prompt.png` (2.483 s) |
| W1 | Ctrl-, | Settings opens in a tab (Account page) | `01-workaround-02-settings-open.png` (4.533 s) |
| | click Keyboard shortcuts | "Configure keyboard shortcuts" list | `01-workaround-03-keyboard-shortcuts-page.png` (6.695 s) |
| | click search, type `Delete all left` | one row: **Delete All Left — Ctrl Y** | `01-workaround-04-delete-all-left-ctrl-y.png` (9.818 s) |
| | click the row | editor with Clear, Default, Cancel, Save | `01-workaround-05-binding-editor-open.png` (12.238 s) |
| | click Clear | Delete All Left row shows no shortcut | `01-workaround-06-delete-all-left-cleared.png` (14.861 s) |
| W2 | click the session tab, click the input, type `kill-u-sentinel` (cursor at end) | `kill-u-sentinel` | `01-workaround-07-typed-kill-u.png` (20.084 s) |
| | Ctrl-U | empty | `01-workaround-08-after-ctrl-u.png` (22.898 s) |
| | Ctrl-Y | `kill-u-sentinel` restored exactly | `01-workaround-09-after-ctrl-u-ctrl-y.png` (25.971 s) |
| Final | reset | empty | `01-workaround-10-final-reset.png` (29.190 s) |

Clear wrote the preference immediately (no Save needed). Copy of the resulting file: `workaround/keybindings.yaml`, containing exactly `"editor_view:delete_all_left": none`.

Isolation: the workaround HOME was created by its own launcher call and is never passed to a default-mode run. `demo.sh default` refuses to start if `keybindings.yaml` exists in the app's HOME. This is a user workaround, not a product fix.

## Other runs (not evidence)

Before these recorded runs, one manual exploration session and one rehearsal of each `demo.sh` mode ran, each in its own fresh HOME, to find screen coordinates, confirm the reset keys and debug the script. Their outputs stayed under `/tmp` (`/tmp/w11743-*`). They showed the same behavior. They are not part of this evidence.

## Not covered

Native Windows, macOS, Wayland and real GPU were not run. Bash was not used in these runs. Cursor blinking means the caret is visible only in some frames.
