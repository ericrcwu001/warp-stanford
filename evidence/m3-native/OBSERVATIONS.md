# M3 native Linux after Option A: identical default demo on the fixed build

This run replays `../demo.sh default` unchanged on the Option A build. The script's SHA-256 is `2bcac835a290f6b3756f71a8d33dfd8f34f17674160c073bccd89374c5b06b62` both before and after this run, which is the same hash as the published M1 copy. The script was not edited for this run.

## Identity

- Source: branch `fix/11743-ctrl-y-yank`, HEAD `56f3560e9befd95235f9490a18d67956f1b72ac7`. The product diff against base `f411fbc20` outside `crates/integration` covers exactly `app/src/editor/view/mod.rs`, `app/src/code/editor/view/actions.rs` and `app/src/notebooks/editor/view.rs` (12 insertions, 20 deletions), as recorded in `default-after/launch.txt`.
- Binary: `target/debug/warp-oss`, rebuilt for this candidate with `services.yaml` `commands.build_gui` (`cargo build --locked --offline ... --bin warp-oss --features gui`, jobs 1, debug 0). The build finished in 10m 54s with exit 0. mtime `2026-10-17 21:56:51 UTC`, sha256 `b845a05c06644948abed30872c99a772c907ca9cdbe0222a30a513bcddc17c3a`. The M1 binary hash was `28023d47…`.
- Display and backend: the same as M1. Owned Xvfb `:99` at 1600x1000x24 with `-nolisten tcp`, owned Openbox, and `WGPU_BACKEND=vulkan` (software llvmpipe on this host; no separate adapter measurement was taken in this run).
- Launch: `services.yaml` `commands.launch_manual` as a managed background job (PID 195960). It used a new `mktemp` HOME `/tmp/warp-11743-manual-home.ng2tqa` and a mode-700 runtime directory. Nothing was copied in, `WARP_INTEGRATION` was unset, and `WARP_SHELL_PATH=/usr/bin/zsh` was set. The HOME listing before onboarding contains only files the app created at startup. `keybindings.yaml` was absent before capture; the script aborts if it exists.
- Shell: actual child `/usr/bin/zsh`, `zsh 5.9 (x86_64-ubuntu-linux-gnu)`, started as `-zsh -g --no_rcs`.
- Onboarding: the script's logged-out steps (Get started, default keybindings, default theme, Skip for now, confirm). No account and no sign-in. This is the normal app, not the synthetic integration-test user.
- The workaround was not used. No Settings change was made before or during this run.

## Capture

`../02-after.mp4`: 197,402 bytes, 42.033 s, H.264, yuv420p, 1600x1000, 30/1 fps, one video stream and no audio (`default-after/ffprobe.txt`). The encoded length is 0.43 s shorter than the 42.467 s `01-before.mp4`, because x11grab started 0.388 s after the script's T0 in this run versus 0.040 s in M1 (`video_start_offset_s` in each `launch.txt`). The script's wall-clock capture time was 42.421 s here and 42.507 s in M1.

Timing check: `default-before/events-video.tsv` and `default-after/events-video.tsv` have the same 35 events with identical kinds and details. Measured from each run's `start` event, the largest difference in event time is 0.169 s. Holds were 2 s, 2.5 s and 3 s, and typing used `xdotool type --delay 90`.

## Observed states (frames at the middle of each hold, inspected visually)

| Step | Input and cursor | Key | Observed input afterwards | Frame (video time) | M1 before result |
| --- | --- | --- | --- | --- | --- |
| Idle | empty | none | empty | `02-after-01-empty-prompt.png` (2.123 s) | empty |
| 1 Direct Ctrl-Y | `alpha beta`, cursor at end | — | `alpha beta` | `02-after-02-typed-alpha-beta.png` (4.868 s) | same |
| | | Ctrl-Y | `alpha beta` unchanged. Nothing has been killed yet, so Yank has nothing to insert and nothing is deleted | `02-after-03-after-direct-ctrl-y.png` (7.657 s) | empty (deleted) |
| 2 Ctrl-U probe | `kill-u-sentinel`, cursor at end | — | `kill-u-sentinel` | `02-after-04-typed-kill-u.png` (11.844 s) | same |
| | | Ctrl-U | empty | `02-after-05-after-ctrl-u.png` (14.652 s) | empty |
| | | Ctrl-Y | `kill-u-sentinel` restored exactly, cursor at end | `02-after-06-after-ctrl-u-ctrl-y.png` (17.701 s) | empty |
| 3 Ctrl-K probe | `kill-k-sentinel`, then `Home` (cursor at start) | — | `kill-k-sentinel` | `02-after-07-typed-kill-k-cursor-start.png` (21.957 s) | same |
| | | Ctrl-K | empty | `02-after-08-after-ctrl-k.png` (24.768 s) | empty |
| | | Ctrl-Y | `kill-k-sentinel` restored exactly, cursor at end | `02-after-09-after-ctrl-k-ctrl-y.png` (27.833 s) | empty |
| 4 Ctrl-W probe | `first second`, cursor at end | — | `first second` | `02-after-10-typed-first-second.png` (31.891 s) | same |
| | | Ctrl-W | `first ` (the word `second` removed) | `02-after-11-after-ctrl-w.png` (34.695 s) | `first ` |
| | | Ctrl-Y | `first second`: the killed word `second` restored after `first ` | `02-after-12-after-ctrl-w-ctrl-y.png` (37.755 s) | empty |
| Final | after reset | — | empty | `02-after-13-final-reset.png` (41.024 s) | empty |

`02-after-00-after-onboarding.png` is a live screenshot taken before recording started. It shows the logged-out prompt in the fresh HOME. The caret blinks, so it is not visible in every frame (for example, `02-after-05`).

What this shows: with fresh default preferences on the Option A build, Ctrl-Y no longer deletes text to the left. In each of the three kill probes, Ctrl-Y restored exactly the text that the kill removed, so the original input returned.

## Not covered

Native Windows, macOS, Wayland and real GPU were not run. Bash was not used. Native behavior of an unbound Ctrl-Y after clearing or rebinding Yank was not checked in this run. The automated integration results use a synthetic signed-in test user and are separate from this logged-out manual run.
