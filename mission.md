# Mission: fix the Linux/Windows `ctrl-y` yank conflict in Warp (warp-stanford #12)

## Goal

On Linux and Windows, `ctrl-y` in Warp's input editor runs **Delete all left** instead of
**Yank** (pasting what `ctrl-u`/`ctrl-k`/`ctrl-w` killed). Yank is reachable only after the user
deletes the Delete-all-left binding in Settings > Keybindings. Fix this so a kill-then-yank flow
works, test it, record before/after evidence on Linux, and hand a human a branch plus a briefing
they can fully explain and defend.

- Fork issue (where the PR will go): https://github.com/warpdotdev/warp-stanford/issues/12
- Original report and Oz triage: https://github.com/warpdotdev/warp/issues/11743
- Working repo in this Environment: `ericrcwu001/warp-stanford` (the student's fork in the Warp network). Its branch
  `stanford-master` mirrors `warpdotdev/warp-stanford@master` (f411fbc). Base all work on `stanford-master`, never `master`.
  Add `git remote add stanford https://github.com/warpdotdev/warp-stanford.git` (fetch only).
- Checkout location: `~/warp-stanford` (cloned by the Environment's setup script over public HTTPS, because
  Factory's repo chooser doesn't list this fork). `origin` = ericrcwu001/warp-stanford, `stanford` = warpdotdev/warp-stanford.
  Before the first push, check that push auth works (`git push --dry-run origin HEAD`). If it fails, keep working
  locally and report the exact error at the next checkpoint; the student will add a `GH_TOKEN` secret.
- Work branch: `fix/11743-ctrl-y-yank`

## Who reviews this

A Stanford CS 146S student submits this to Warp's maintainers. The course zeroes any
contribution the maintainers call "slop": code the author can't explain, PRs that don't build or
pass tests, hallucinated APIs, invented results, padded descriptions, changes nobody asked for.
Treat every claim you write as something a Warp engineer will check.

## Hard rules (not negotiable)

1. **No GitHub writes except `git push` of `fix/11743-ctrl-y-yank` and `evidence/11743` to `origin` (the student's fork).**
   Never open, comment on, label, or react to issues/PRs in any repo. Never push to `warpdotdev/*`.
   Warp requires humans to talk to maintainers; the student does all of that.
2. **Stop at the decision gate after Milestone 1** and wait for a human reply. Do not pick a fix
   direction on your own.
3. Keep Warp **logged out**. Do not create accounts, sign in, or use any credentials in the app.
4. No changes outside the fix: no drive-by refactors, formatting of untouched files, dependency
   bumps, or new feature flags unless the chosen design requires one.
5. Never state a result you did not observe. If something failed or was skipped, say so with the
   command and output. "Should work" is not evidence.
6. Read and follow `AGENTS.md`, `CONTRIBUTING.md`, and the relevant skills in `.agents/skills/`
   (at minimum `rust-unit-tests`, `gui-integration-test`, `gui-reproduce-bug-report-local`,
   `change-keybinding` if present, and `gui-ui-guidelines` if any UI changes).

## Known starting points (verify, don't trust)

From the Oz triage on #11743. Confirm each against current `master` and record file:line:
- `app/src/editor/view/mod.rs`: fixed binding `ctrl-y` -> `EditorAction::Yank` (~L268) and editable
  `editor_view:delete_all_left` with `.with_linux_or_windows_key_binding("ctrl-y")` (~L824-833).
- `crates/warpui_core/src/keymap.rs`: editable bindings are returned before fixed ones;
  `crates/warpui_core/src/keymap/matcher.rs` dispatches the first match.
- `app/src/settings_view/keybindings.rs` / `app/src/keyboard.rs`: clearing a binding persists an
  empty custom trigger, which is why the reporter's workaround works.
- On macOS Delete all left is `cmd-delete`, so the conflict should be Linux/Windows only. Confirm.

## Running the GUI headlessly (use this for repro and evidence)

```bash
. "$HOME/.cargo/env"
export DISPLAY=:99 WARP_SKIP_COMMON_SKILLS_INSTALL=1 WARP_SKIP_SUDO_PROMPT=1
Xvfb :99 -screen 0 1600x1000x24 -nolisten tcp & sleep 1
openbox & sleep 1
# Try Vulkan (lavapipe) first; if wgpu finds no adapter, retry with WGPU_BACKEND=gl LIBGL_ALWAYS_SOFTWARE=1
SHELL=/usr/bin/zsh ./script/run > /tmp/warp-run.log 2>&1 &
```

- Use a throwaway `HOME` (e.g. `HOME=$(mktemp -d)`) per run so settings from one run don't
  leak into the next, and complete the logged-out onboarding path.
- Drive input with `xdotool` (`search --sync --name Warp`, `windowactivate`, `type`, `key ctrl+u`,
  `key ctrl+y`). Script every keystroke in `evidence/demo.sh` so before and after runs are identical.
- Record with `ffmpeg -f x11grab -framerate 30 -video_size 1600x1000 -i :99 -c:v libx264 -pix_fmt yuv420p`.
- Screenshots with `import -window root` or `xwd -root | convert xwd:- png:-`.
- If Warp's GUI cannot render under Xvfb after trying Vulkan and GL, stop and report it at the
  next checkpoint with the log tail. Do not fake evidence with mockups.

## Milestones

### M0: Environment baseline
- The Environment build only downloads crates; nothing is compiled yet. Compiling Warp's `app` crate was
  OOM-killed (SIGKILL) on Factory's builder, so before the first build on this machine:
  - check memory (`free -g`, `nproc`); if under 16 GB, add swap:
    `sudo fallocate -l 16G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile`
  - `export CARGO_BUILD_JOBS=2 CARGO_PROFILE_DEV_DEBUG=line-tables-only` (put both in `~/.bashrc`).
  - If rustc is still killed, retry with `CARGO_BUILD_JOBS=1` and `CARGO_PROFILE_DEV_DEBUG=0`, and report it.
- Install Warp's shared agent skills (the Environment skipped them):
  `./script/resolve_common_skills install_common_skills -- --repo-root "$PWD" --project --if-needed --non-interactive`
- `git fetch stanford master && git checkout -b fix/11743-ctrl-y-yank stanford/master`; record the base SHA.
- Build `warp-oss`, launch it under Xvfb, finish logged-out onboarding, save
  `evidence/00-baseline.png`. Record OS, kernel, Rust version, renderer backend that worked.
- Validation: screenshot exists and shows a usable Warp input prompt.

### M1: Reproduce and explain, then STOP
1. Reproduce on unmodified `master` with the issue's steps (type text, `ctrl-y` deletes left;
   remove the binding, `ctrl-u` then `ctrl-y` yanks). Record `evidence/01-before.mp4` and
   key-frame PNGs.
2. Write a **failing** automated test that captures the bug at the lowest level that can see it
   (keymap/dispatch unit test if possible; integration test only if a unit test truly can't).
   Show the failure output.
3. Trace the root cause with file:line references: how bindings are registered, why the editable
   binding shadows the fixed one, and whether the keybindings settings UI can see fixed bindings
   at all (does conflict detection consider them?).
4. Check for related behavior: are other fixed editor bindings shadowed by Linux/Windows editable
   defaults the same way? List any you find; do **not** fix them in this mission.
5. Search open/closed PRs and issues in `warpdotdev/warp` and `warpdotdev/warp-stanford` for prior
   attempts (`ctrl-y`, `yank`, `delete all left`, `11743`). Summarize what reviewers said.
6. Write `evidence/PROPOSAL.md` with 2-3 fix options. For each: the user-visible behavior, files
   touched, approximate diff size, risk to existing users' muscle memory and saved keybindings,
   testability, and your recommendation with reasons. Options to evaluate at least:
   - A. Make Yank an editable binding so it shows in Settings > Keybindings and participates in
     conflict detection, and resolve the default `ctrl-y` collision.
   - B. Change the Linux/Windows default of Delete all left away from `ctrl-y`.
   - C. Keep defaults but warn in the keybindings UI when an editable binding shadows a fixed one.
- **Decision gate:** post the PROPOSAL summary to the human in Mission Control and pause. Also push
  `evidence/11743` at this point so the student can read PROPOSAL.md on GitHub from their phone.
  The student will post the chosen direction on the fork issue and tell you which option to build.

### M2: Implement the chosen option
- Smallest change that delivers the chosen behavior. Match surrounding code style and comment
  density. Persisted user keybindings must keep working (someone who already rebound or cleared
  `ctrl-y` must not regress); add a test for that if the design touches persistence.
- Make the M1 failing test pass. Add tests for the edge cases the design introduces.
- Validation, in this order (per AGENTS.md): targeted `cargo nextest run -p <pkg>` for the touched
  crates; `cargo clippy -p <pkg> --all-targets --tests -- -D warnings`; `./script/format` once at the end.

### M3: Evidence on Linux
- Re-run the identical `evidence/demo.sh` on the fixed build: `evidence/02-after.mp4` + PNGs.
- If settings UI changed, screenshot Settings > Keybindings before and after.
- Produce **captioned** versions: write `evidence/before.srt` and `evidence/after.srt` from the
  script's known timestamps (e.g. "Typed: echo hello world", "Pressed ctrl-u: line killed",
  "Pressed ctrl-y: text deleted instead of pasted (bug)" / "...killed text pasted back (fixed)").
  Burn them in: `ffmpeg -i in.mp4 -vf subtitles=in.srt -c:a copy out-captioned.mp4`.
  Also produce one side-by-side or back-to-back `evidence/before-after-captioned.mp4`, under 60 s.
  Captions must describe only what is visibly on screen. **No audio track** (`-an`): the student
  records a voiceover later.
- Pace the demo for narration: hold each step 2-4 s on screen and type at human speed
  (`xdotool type --delay 90`), so each caption can be read aloud at ~150 words/min.
- Write `evidence/NARRATION.md`: a table of `start - end | caption on screen | line to say aloud`,
  one row per caption, each spoken line short enough to fit its window at a natural cadence.
  The student reads these over the silent captioned MP4.
- Validation: watch-check via extracted frames (`ffmpeg -ss T -frames:v 1`) that each caption
  matches the frame it sits on.

### M4: Final checks and handoff
- Merge latest `stanford/master` and re-run the targeted tests.
- Run `./script/presubmit` once. If any part can't run in this environment, report exactly which
  and why.
- Commit with a plain, specific message (no AI attribution trailers). `git push -u origin fix/11743-ctrl-y-yank`.
- Evidence must not be in the PR diff. Put `evidence/` on a separate orphan branch
  `evidence/11743` (`git switch --orphan evidence/11743`, add only `evidence/`, commit) and push
  that branch to `origin` too, so the student can download it. Keep each MP4 under 25 MB.
- Write `evidence/BRIEFING.md` (below) and `evidence/PR_DRAFT.md`.

## BRIEFING.md (for the student, so they can defend every line)

1. **One-paragraph summary** of the bug and the fix, in plain words.
2. **Root cause walkthrough** with file:line links on the base SHA: registration -> keymap lookup
   order -> matcher dispatch -> why `ctrl-y` deleted text.
3. **The diff, hunk by hunk:** what each hunk does and why it's needed. Flag anything a reviewer
   might call out of scope.
4. **Tests:** each new test, what it asserts, the command, and the actual before (failing) and
   after (passing) output.
5. **Manual verification:** environment (OS, renderer, Warp commit), exact steps, links to each
   evidence file, and what each one proves.
6. **What I did not verify:** e.g. Windows, Wayland, real GPU, macOS unaffected-ness. Be explicit.
7. **Likely reviewer questions** (5-8) with honest answers, including "why not option X?".
8. **Explain-it-back quiz:** 5 questions the student should be able to answer without notes,
   with answers.
9. **Commands to reproduce** everything from a fresh checkout.

## PR_DRAFT.md (the student edits and opens the PR; you never open it)

Follow `.github/pull_request_template.md` exactly: Description, Linked Issue
(`Fixes #12`, and reference warpdotdev/warp#11743), Testing with real
commands and results, Screenshots/Videos placeholders naming the evidence files, and a
`CHANGELOG-BUG-FIX:` line. Short and factual: no "comprehensive", "robust", "seamless", no emoji,
no claims beyond what BRIEFING.md shows. Leave the Agent Mode box unchecked.

## Done when

- Branch `fix/11743-ctrl-y-yank` is pushed to the student's fork and contains only the fix + tests.
- Failing-then-passing test output, clippy, format, and presubmit results are recorded verbatim.
- `evidence/` contains baseline, before, after PNGs/MP4s, captioned silent before/after MP4,
  NARRATION.md, PROPOSAL.md, BRIEFING.md, PR_DRAFT.md.
- No issue, PR, or comment was created anywhere.
