# Evidence index: Ctrl-Y yank conflict (#12 / warpdotdev/warp#11743)

This directory stays untracked on `fix/11743-ctrl-y-yank`. It is to be published only on the separate orphan branch `evidence/11743` of `ericrcwu001/warp-stanford` (https://github.com/ericrcwu001/warp-stanford/tree/evidence/11743), which contains nothing outside `evidence/`. Publication status is recorded in the mission library, not here. The source checkout and the fix branch are not changed by publishing it.

| Path | What it is |
| --- | --- |
| `ENVIRONMENT.md` | Base SHA, OS/kernel/Rust, shell/renderer, resources (host vs cgroup swap), setup, build/test results including failed app lib-test attempts |
| `00-baseline.png` | Reused readiness screenshot: normal `warp-oss`, logged out, usable prompt (Bash session, Vulkan llvmpipe) |
| `logs/readiness/` | Copies of the readiness logs/reports from `/tmp` (originals retained). `validation-readiness-summary-first160.md` is the first 160 lines of the 10 MB original, which ends in a generated-file appendix. **Redacted published copies:** in `manual-app-recovery-instance.warp-oss.log` and `manual-app-session.warp-oss.log.old.0`, the Firebase client API key value on the `Starting warp with channel state` line is replaced with `[REDACTED]` (student-approved), and a note is appended at the end of each file. Every other line, including all results and errors, is unchanged. The unredacted originals stay local only |
| `m1-regression/` | Expected-red real GUI regression `test_ctrl_y_yanks_killed_input`: full failing nextest output, tested commit, lint/format logs, test-only patch |
| `demo.sh` | Reproducible OS-level xdotool script. `default` mode (direct Ctrl-Y plus Ctrl-U/Ctrl-K/Ctrl-W kill-then-Ctrl-Y probes) is replayed unchanged for the fixed build; `workaround` mode clears Delete All Left in Settings. Usage is in its header |
| `01-before.mp4` | Default preferences, unchanged product: Ctrl-Y deletes left text and never restores killed text. 30 fps, H.264, no audio |
| `01-workaround.mp4` | Separate fresh HOME: clearing Delete All Left in Settings, then Ctrl-U and Ctrl-Y restore `kill-u-sentinel` |
| `m1-native/OBSERVATIONS.md` | Literal input, cursor and result for every step, with frame names and video times |
| `m1-native/default-before/`, `m1-native/workaround/` | Per-run launch/identity record, event timelines (wall and video clock), ffprobe output, inspected key frames, saved `keybindings.yaml` for the workaround |
| `TRACE.md` | Root-cause trace with base-SHA line links: registration → editable-first ordering → first-match dispatch → Yank/Delete All Left; Settings visibility, conflict detection, clear/rebind/reset persistence and reload; platform defaults; bounded inventory of other fixed/editable overlaps |
| `research/RESEARCH.md` | Read-only prior-work search: 16 GitHub searches (both repos × `ctrl-y`/`yank`/`delete all left`/`11743` × issues/PRs), item and review reads, WebSearch queries, findings and coverage limits |
| `research/raw/` | Raw JSON from every GitHub search (`*.json`, empty `*.err`) and from issue/PR/comment/review/timeline reads (`items/`) |
| `PROPOSAL.md` | Options A/B/C compared on behavior, files, estimated diff, muscle memory, saved bindings and testability, with a recommendation (historical: B). **Student selected Option A on 2026-10-17; see the decision update in that file** |
| `m2-settings-before/` | Settings > Keyboard shortcuts on the unchanged product before any Option A edit: `Yank` search finds no Yank row; Delete All Left is bound to Ctrl-Y. Script, launch record and README |
| `02-after.mp4` | Option A build, fresh logged-out HOME, actual Zsh 5.9, Vulkan: unchanged `demo.sh default` replay. Ctrl-Y no longer deletes; after Ctrl-U, Ctrl-K and Ctrl-W, Ctrl-Y restores exactly the killed text. 30 fps, H.264, no audio |
| `m3-native/OBSERVATIONS.md` | Fixed-build identity (HEAD, binary hash, three-file product diff, shell, backend), timing comparison with M1, literal per-step results paired with M1 |
| `m3-native/default-after/` | Per-run launch/identity record, event timelines, ffprobe output, inspected key frames for `02-after.mp4` |
| `m3-settings-after/` | Settings on the Option A build: editable "Yank (Last Killed Text)" with default Ctrl-Y, Delete All Left with no Linux shortcut, `ctrl y` search lists only Yank, Yank binding editor (Clear/Default/Cancel/Save). Script, launch record and README |
| `before.srt`, `after.srt` | 13 captions each, derived from the recorded event timelines of `01-before.mp4` and `02-after.mp4`; captions describe only what the input line shows |
| `01-before-captioned.mp4`, `02-after-captioned.mp4` | Raw clips with their SRT and a build label burned in. Same length as the raw clips (42.467 s, 42.033 s), 1600x1000, 30 fps, H.264, no audio |
| `before-after-captioned.mp4` | Side-by-side comparison at normal speed: before left, after right, 3200x1000 (two native panes), 42.500 s, no audio. The after pane starts 0.428 s late by holding its first frame so matching steps line up (largest remaining event mismatch 0.089 s) |
| `NARRATION.md` | Text-only narration table (start - end, caption on screen, line to say aloud), one row per caption for the side-by-side and each captioned clip, paced at about 150 wpm or slower. No voice track exists |
| `m3-captions/` | Generator scripts, cue timeline, MP4 population check (`media-check.md`: every MP4 is one H.264 video stream, no audio, under 25 MB), extracted in-cue frames and inspection sheets with recorded results (`README.md`) |
| `readiness-screenshots/` | Other readiness screenshots. `ctrl-y-integration-readiness.png` shows the synthetic test-user fixture and is not logged-out proof |

M1 status (historical, at the M1 checkpoint): trace, research and proposal are written. The fix direction is not chosen. The next step is the student's decision on `PROPOSAL.md`.

## Decision update (2026-10-17)

After the M1 checkpoint the student replied "Also, do option A" and "Yes, redact and publish the evidence". Option A is selected. The proposal's original recommendation of B is kept unchanged in `PROPOSAL.md` as history. At the time of this publication no product code has been changed; the fix branch still holds only the test-only regression commit. Option A work starts only after the M1 validation run.

The first publication attempt was stopped by a secret scanner on the two readiness logs named above. The student approved replacing only that key value with `[REDACTED]` in the published copies, which is what this branch contains.

## M3 update (2026-10-17)

Option A is implemented on `fix/11743-ctrl-y-yank` (`02b29a0de`, tests `56f3560e9`). `02-after.mp4` replays `demo.sh default` unchanged (same SHA-256 as the M1 copy) on a normal `warp-oss` built from `56f3560e9`, in a fresh logged-out HOME. See `m3-native/OBSERVATIONS.md` and `m3-settings-after/README.md`. These are logged-out manual Linux runs, kept separate from the automated integration tests, which use a synthetic signed-in test user. Native Windows, macOS, Wayland and real GPU were not run.

## M3 captions update (2026-10-17)

`before.srt`, `after.srt`, the two captioned clips, `before-after-captioned.mp4` and `NARRATION.md` were generated from the unchanged `01-before.mp4` and `02-after.mp4` (hashes unchanged) and their event logs; see `m3-captions/README.md`. Frames inside every cue, at both edges and the midpoint, were extracted and inspected in all three captioned videos, including the side-by-side with its 0.428 s pane offset. No footage, voice or audio was added and nothing was sped up. Linux only; native Windows, macOS, Wayland and real GPU were not run.
