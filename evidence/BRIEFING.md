# Briefing: Ctrl-Y yank fix (warp-stanford #12 / warpdotdev/warp#11743)

Prepared 2026-10-17 for the student who will open and defend the PR. Every result below comes from a file in this `evidence/` directory or from the Git history named here. Where a check did not run or did not finish, this briefing says so.

- Fix branch: `fix/11743-ctrl-y-yank` on `ericrcwu001/warp-stanford`, head `56f3560e9befd95235f9490a18d67956f1b72ac7` (pushed 2026-10-17; see section 5).
- Original base and current `stanford/master`: `f411fbc20e6283a2abcdd1ed64bf5b67df864f82`. The M4 merge of `stanford/master` was already up to date, so no merge commit exists.
- Commits on top of the base:
  1. `c1db7c276` Add failing Ctrl-Y yank integration regression (test only)
  2. `02b29a0de` Make Ctrl-Y yank editable and drop Delete all left Ctrl-Y default (product fix)
  3. `56f3560e9` Add Settings and saved-binding integration tests for editable Yank (tests only)

## 1. Summary

On Linux and Windows, pressing Ctrl-Y in a Warp editor deleted everything to the left of the cursor instead of pasting back the text that Ctrl-U, Ctrl-K or Ctrl-W had just removed ("yank"). Two default bindings used Ctrl-Y in the same editor context: a fixed Yank binding and the editable "Delete all left" binding. The keymap checks editable bindings before fixed ones, so "Delete all left" always won, and Yank could not be found or changed in Settings. The student chose Option A: Yank is now an editable binding, `editor_view:yank` ("Yank (last killed text)"), with Ctrl-Y as its default on all platforms, and "Delete all left" no longer has a Ctrl-Y default on Linux and Windows (its macOS Cmd-Backspace default is unchanged). A user who saved Ctrl-Y for "Delete all left" keeps that behavior. The change touches three product files (12 insertions, 20 deletions); the rest of the diff is integration tests.

## 2. Root cause, linked at the base SHA

All links point at base `f411fbc20`. `TRACE.md` has the full trace, including Settings, persistence and the inventory of other overlaps.

1. **Two bindings on one key.** The fixed `ctrl-y` → `EditorAction::Yank` binding is at [`app/src/editor/view/mod.rs:267-271`](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/app/src/editor/view/mod.rs#L267-L271). The editable `editor_view:delete_all_left` binding is at [`mod.rs:823-833`](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/app/src/editor/view/mod.rs#L823-L833); it adds `ctrl-y` only on Linux/Windows at [L833](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/app/src/editor/view/mod.rs#L833). Both use the context `EditorView & !IMEOpen`.
2. **Platform selection.** `with_linux_or_windows_key_binding` sets the trigger only on Linux or Windows ([`crates/warpui_core/src/keymap.rs:701-713`](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/crates/warpui_core/src/keymap.rs#L701-L713)); `with_mac_key_binding` only on macOS ([L688-697](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/crates/warpui_core/src/keymap.rs#L688-L697)). That is why macOS (Cmd-Backspace for Delete all left) is not affected.
3. **Editable bindings come first.** `Keymap::bindings()` returns all editable bindings, in reverse registration order, before any fixed binding ([`keymap.rs:441-464`](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/crates/warpui_core/src/keymap.rs#L441-L464)).
4. **First match wins.** `Matcher::push_keystroke` returns the first binding whose keystrokes and context match ([`crates/warpui_core/src/keymap/matcher.rs:306-344`](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/crates/warpui_core/src/keymap/matcher.rs#L306-L344)). It does not report duplicates. So Ctrl-Y always ran Delete all left.
5. **Delete all left does not fill the kill buffer.** `DeleteAllLeft` calls `delete_all(Left, cut = false)` ([`mod.rs:8595-8598`](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/app/src/editor/view/mod.rs#L8595-L8598), plain edit branch [L6259-6294](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/app/src/editor/view/mod.rs#L6259-L6294)). Yank inserts `internal_clipboard` ([L4301-4314](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/app/src/editor/view/mod.rs#L4301-L4314)), which only `ShellCut` from Ctrl-U/Ctrl-K/Ctrl-W fills ([L7642-7645](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/app/src/editor/view/mod.rs#L7642-L7645)).
6. **Settings could not help users find the problem.** The Keyboard shortcuts page lists only editable bindings ([`app/src/settings_view/keybindings.rs:749-793`](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/app/src/settings_view/keybindings.rs#L749-L793)), and the conflict map is built from that same list ([L105-147](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/app/src/settings_view/keybindings.rs#L105-L147), [L795-801](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/app/src/settings_view/keybindings.rs#L795-L801)). Fixed Yank had no row and never produced a conflict warning. Clearing Delete all left (saved as `none`) was the reporter's workaround: an empty trigger never matches ([`matcher.rs:324`](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/crates/warpui_core/src/keymap/matcher.rs#L324)), so the fixed Yank became reachable.
7. **Same default in two more editors.** `editor_view:delete_all_left` is also registered by the code editor ([`app/src/code/editor/view/actions.rs:559-569`](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/app/src/code/editor/view/actions.rs#L559-L569)) and the notebook editor ([`app/src/notebooks/editor/view.rs:628-638`](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/app/src/notebooks/editor/view.rs#L628-L638)), both with Linux/Windows `ctrl-y`. A saved custom trigger applies by name to every registration ([`keymap.rs:422-433`](https://github.com/warpdotdev/warp-stanford/blob/f411fbc20e6283a2abcdd1ed64bf5b67df864f82/crates/warpui_core/src/keymap.rs#L422-L433)), so Settings shows one row for all three.

## 3. The diff, hunk by hunk

Full diff: `git diff f411fbc20..56f3560e9` (8 files, 550 insertions, 21 deletions). Product files: 3 files, 12 insertions, 20 deletions.

### 3.1 `app/src/editor/view/mod.rs`, hunk `@@ -264,11 +264,6 @@` (removes 5 lines)

Removes `FixedBinding::new("ctrl-y", EditorAction::Yank, id!("EditorView") & !id!("IMEOpen"))`. Needed because Yank becomes editable in the next hunk. Keeping both would leave a hidden fixed Ctrl-Y fallback, so clearing Yank in Settings would not actually turn it off (`test_yank_settings_clear_then_reset` and `test_yank_saved_none` check that it is really off).

### 3.2 `app/src/editor/view/mod.rs`, hunk `@@ -820,17 +815,22 @@` (adds the editable Yank, edits Delete all left)

- Adds `EditableBinding::new("editor_view:yank", "Yank (last killed text)", EditorAction::Yank)` with the same context and `.with_key_binding("ctrl-y")` (all platforms), at [fix `mod.rs:818-826`](https://github.com/ericrcwu001/warp-stanford/blob/56f3560e9befd95235f9490a18d67956f1b72ac7/app/src/editor/view/mod.rs#L818-L826). Settings shows it as "Yank (Last Killed Text)" (`m3-settings-after/01-settings-search-yank.png`).
- It is registered **immediately before** `editor_view:delete_all_left`. Because editable bindings are checked in reverse registration order, a user's saved `"editor_view:delete_all_left": ctrl-y` is checked before Yank and still wins. The two-line comment above the binding records this reason. `test_yank_saved_delete_all_left_ctrl_y` and `test_yank_settings_conflict_warning` check it.
- On `editor_view:delete_all_left` it removes `.with_linux_or_windows_key_binding("ctrl-y")` and the three-line IntelliJ/VS Code comment that justified it. `.with_mac_key_binding("cmd-backspace")` stays.

### 3.3 `app/src/code/editor/view/actions.rs`, hunk `@@ -562,11 +562,7 @@`

Removes the Linux/Windows `ctrl-y` default and the same comment from the code editor's `editor_view:delete_all_left` (action `CodeEditorViewAction::DeleteLineLeft`). Keeps Cmd-Backspace on macOS.

### 3.4 `app/src/notebooks/editor/view.rs`, hunk `@@ -631,11 +631,7 @@`

Same change for the notebook editor's registration (`EditorViewAction::DeleteLineLeft`).

Why 3.3 and 3.4 are needed: all three registrations share one name and one Settings row. If only the input editor's default changed, the row's default would differ by editor, Reset to default would restore Ctrl-Y in two editors, and the conflict map would still list Delete all left on Ctrl-Y. The tests assert the effective and default triggers of all three registrations (`DELETE_ALL_LEFT_REGISTRATIONS = 3`).

### 3.5 Test-only hunks

- `crates/integration/src/test/input.rs` `@@ -12,7 +12,8 @@`: imports `assert_input_editor_contents`. `@@ -223,6 +224,42 @@`: adds `test_ctrl_y_yanks_killed_input` (commit `c1db7c276`, unchanged since).
- `crates/integration/src/test/yank.rs` (new, 480 lines): the eight `test_yank_*` cases and their helpers (commit `56f3560e9`).
- `crates/integration/src/test.rs` `@@ -43,6 +43,7 @@` and `@@ -208,6 +209,7 @@`: `mod yank;` and `pub use yank::*;`.
- `crates/integration/src/bin/integration.rs` `@@ -443,6 +443,15 @@` and `crates/integration/tests/integration/ui_tests.rs` `@@ -340,6 +340,15 @@`: register the nine new tests with the runner and with nextest, following the existing `register_test!` / `integration_tests!` pattern.

### 3.6 Scope concerns a reviewer may raise

- **Linux/Windows users lose a default.** Delete all left has no default key on Linux/Windows after this change, in the input, code and notebook editors. Users who relied on Ctrl-Y to delete a line must bind a key themselves. No replacement key was added, by design of Option A.
- **Code and notebook editors.** On Linux/Windows, Ctrl-Y there used to run Delete line left; that default is gone. The new editable Yank keeps the old fixed Yank's `EditorView && !IMEOpen` context, so this change does not add a Yank binding of its own to those editors. What Ctrl-Y does in them now was not checked at runtime (see section 6).
- **macOS users see a new Settings row.** Yank was fixed Ctrl-Y on macOS too. Now it is an editable Ctrl-Y row there as well. The default key is the same, but macOS behavior was checked in source only.
- **Other fixed/editable overlaps remain.** `TRACE.md` section 3.2 lists five more overlaps in the same function (`ctrl-right`, `meta-f`, `meta-b`, `ctrl-shift-up`, `ctrl-g`). They run the same action on both bindings, so they were left alone.
- **Test file size.** `yank.rs` is 480 lines for 8 cases. A reviewer may ask to trim it.

## 4. Tests: what each asserts, commands and verbatim output

All tests are GUI integration tests in `crates/integration`. They send physical `KeyDown` events through the normal keymap and check the exact input text. None calls `EditorAction::Yank` directly. They run as the stock synthetic signed-in integration test user (approved for automated tests only; no real account). App unit tests (`warp --lib`) were not used because that test binary was OOM-killed under this machine's ~6.6 GiB memory limit (`ENVIRONMENT.md`).

Command for all ten Option A cases (`services.yaml` `commands.test_option_a`, with owned Xvfb `:99` and Openbox, fresh HOME):

```sh
CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0 WARPUI_USE_REAL_DISPLAY_IN_INTEGRATION_TESTS=1 \
WGPU_BACKEND=vulkan DISPLAY=:99 WARP_SHELL_PATH=/usr/bin/zsh \
cargo nextest run --offline --config 'profile.dev.package.warp.incremental=false' \
  --config 'profile.dev.package.warp.codegen-units=256' --cargo-profile dev \
  -p integration --test integration --features warp/gui \
  -E 'test(test_ctrl_y_) | test(test_yank_) | test(test_home_key_should_not_appear_in_input)' --test-threads 1
```

The single-case red/green command is the same with `-E 'test(test_ctrl_y_yanks_killed_input)'` (`commands.test_regression`).

### 4.1 `test_ctrl_y_yanks_killed_input` (regression, in `input.rs`)

Types `echo ctrl-y-yank-sentinel`, presses Ctrl-U and asserts `""`, presses Ctrl-Y and asserts exactly `echo ctrl-y-yank-sentinel`.

**Red** at `c1db7c276` (test only, product unchanged), from `m1-regression/red-run-committed.log`:

```
Test step 'Yank the killed input with ctrl-y' failed after 1 attempts: assertion failed: `Incorrect input box contents:
Expected "echo ctrl-y-yank-sentinel"
Actual: ""`
```
```
     Summary [  13.066s] 1 test run: 0 passed, 1 failed, 338 skipped
        FAIL [  13.055s] (1/1) integration::integration ui_tests::test_ctrl_y_yanks_killed_input
error: test run failed
```

nextest exit status 100. The first four steps passed, so this is the assertion failing after bootstrap, not a build or setup error.

**Green** at `02b29a0de` (product fix, before the `test_yank_*` cases existed), from `m2-fix/test-option-a.log`:

```
        PASS [   3.426s] (1/2) integration::integration ui_tests::test_ctrl_y_yanks_killed_input
        PASS [   2.182s] (2/2) integration::integration ui_tests::test_home_key_should_not_appear_in_input
────────────
     Summary [   5.620s] 2 tests run: 2 passed, 337 skipped
```

### 4.2 The eight `test_yank_*` cases (in `yank.rs`)

These were written after the fix (commit `56f3560e9`). **They have no red run**: none was run against the base, and several reference `editor_view:yank`, which does not exist there. Each case also asserts the effective and default trigger of every registration through `ctx.editable_bindings()`.

| Test | Setup | Key assertions |
| --- | --- | --- |
| `test_yank_settings_rebind` | Settings: search "Yank (last killed text)", top row is `editor_view:yank` on `ctrl-y`; capture `ctrl-alt-y`, Save | Ctrl-Y gives literal `y` (unbound, see below); `ctrl-alt-y` restores the sentinel |
| `test_yank_settings_clear_then_reset` | Settings: Clear the Yank row | Trigger is empty; Ctrl-Y gives `y`, so no hidden fixed fallback. After Default, Ctrl-Y restores the sentinel |
| `test_yank_settings_conflict_warning` | Settings: bind Delete all left to `ctrl-y` | Screenshots of both rows; all 3 Delete all left registrations become `ctrl-y`; Ctrl-Y deletes the typed sentinel (`""`) |
| `test_yank_saved_delete_all_left_none` | `keybindings.yaml`: `"editor_view:delete_all_left": none` | All 3 registrations empty; Ctrl-Y restores the sentinel |
| `test_yank_saved_delete_all_left_rebound` | `"editor_view:delete_all_left": ctrl-alt-y` | `ctrl-alt-y` deletes; Ctrl-Y restores the sentinel |
| `test_yank_saved_delete_all_left_ctrl_y` | `"editor_view:delete_all_left": ctrl-y` | Ctrl-Y deletes the typed sentinel; after Ctrl-U, Ctrl-Y leaves `""` (Delete all left still wins) |
| `test_yank_saved_none` | `"editor_view:yank": none` | Ctrl-Y gives `y` then Backspace gives `""`; no yank |
| `test_yank_saved_custom_trigger` | `"editor_view:yank": ctrl-alt-y` | Ctrl-Y gives `y`; `ctrl-alt-y` restores the sentinel |

Saved-file cases write `keybindings.yaml` in `Builder.with_setup` before the app starts. Settings cases use the page's own `KeybindingsViewAction` variants (the same ones its buttons dispatch) after a real click on the row and a physical key capture.

"Unbound Ctrl-Y gives `y`": the integration harness builds synthetic `KeyDown` events whose typed character defaults to the key name, so an unhandled Ctrl-Y inserts `y`. The tests assert that exact `y` before Backspace, so an unwanted yank would fail the step. This is harness behavior, not proof of what a native unbound Ctrl-Y does.

The conflict-warning screenshots are `m2-option-a/artifacts/test_yank_settings_conflict_warning/2026-10-17T21-21-00/delete_all_left_ctrl_y_conflict.png` and `yank_ctrl_y_conflict.png`. Both show "This shortcut conflicts with other keybinds". They come from the synthetic automated fixture on Xvfb, not from a manual run.

**Green, all ten cases** at `56f3560e9`. Final M4 run (`m4-final-validation/nextest-option-a.log`):

```
    Starting 10 tests across 1 binary (337 tests skipped)
        PASS [   2.651s] ( 1/10) integration::integration ui_tests::test_ctrl_y_yanks_killed_input
        PASS [   2.264s] ( 2/10) integration::integration ui_tests::test_home_key_should_not_appear_in_input
        PASS [   2.773s] ( 3/10) integration::integration ui_tests::test_yank_saved_custom_trigger
        PASS [   3.115s] ( 4/10) integration::integration ui_tests::test_yank_saved_delete_all_left_ctrl_y
        PASS [   2.480s] ( 5/10) integration::integration ui_tests::test_yank_saved_delete_all_left_none
        PASS [   2.852s] ( 6/10) integration::integration ui_tests::test_yank_saved_delete_all_left_rebound
        PASS [   3.154s] ( 7/10) integration::integration ui_tests::test_yank_saved_none
        PASS [   4.821s] ( 8/10) integration::integration ui_tests::test_yank_settings_clear_then_reset
        PASS [   3.987s] ( 9/10) integration::integration ui_tests::test_yank_settings_conflict_warning
        PASS [   3.556s] (10/10) integration::integration ui_tests::test_yank_settings_rebind
────────────
     Summary [  31.655s] 10 tests run: 10 passed, 337 skipped
nextest_exit=0
```

The same ten passed in M2 (`m2-option-a/logs/yank-m2-run2.log`, 10 passed, 337 skipped).

### 4.3 Lint, format and presubmit

- Clippy, `cargo clippy --offline ... -p integration -p warp --features warp/gui --all-targets --tests -- -D warnings` (`commands.lint_option_a`): exit 0, no warnings, 9m 18s (`m2-fix/lint-option-a.log`, at `02b29a0de`). After the test commit, `m2-option-a/logs/yank-m2-clippy.log` shows only the `integration` crate recompiling and finishing; the M2 and M3 validators also reran this Clippy successfully.
- `./script/format`: exit 0, no file changes (`m2-fix/format.log`, `m2-option-a/logs/yank-m2-format*.log`, both empty).
- **`./script/presubmit` did not complete.** One attempt ran after the M4 merge (`m4-final-validation/presubmit.log`). `./script/format --check` and the inline test module check passed. Workspace Clippy was still compiling dependencies, with no warning or error printed yet, when free disk fell to 1180 MiB. The mission's disk guard (stop before 1 GiB free) terminated it. The log has no exit line. These presubmit steps never ran: workspace Clippy to completion, GUI `cargo clippy -p warp`, clang-format, factory-files validator, wgslfmt, ShellCheck, PSScriptAnalyzer, `cargo nextest run --workspace` and `cargo test --doc`. It was not retried. Expect CI to be the first full run.

## 5. Manual environment, steps and evidence

Environment (`ENVIRONMENT.md`): Ubuntu 24.04.5, Linux 6.1.158+, 4 CPUs, Rust 1.92.0, normal `warp-oss` debug build (`cargo build --bin warp-oss --features gui`), owned Xvfb `:99` 1600x1000x24 with `-nolisten tcp`, Openbox, software Vulkan (Mesa llvmpipe). Each manual run used a new empty HOME and a mode-700 runtime directory, went through onboarding with "Skip for now", and stayed logged out. No account or credentials were used. The manual runs used Zsh 5.9 (`m1-native/OBSERVATIONS.md`, `m3-native/OBSERVATIONS.md`); the M0 baseline screenshot `00-baseline.png` is a Bash session.

Steps: `demo.sh default` types with `xdotool type --delay 90` and holds each state 2–3 s: direct Ctrl-Y on `alpha beta`; Ctrl-U then Ctrl-Y on `kill-u-sentinel`; Home, Ctrl-K then Ctrl-Y on `kill-k-sentinel`; Ctrl-W then Ctrl-Y on `first second`. The same unchanged script (same SHA-256) ran on the base build and on the fix build.

| Evidence | What it shows |
| --- | --- |
| `01-before.mp4`, `m1-native/` | Base build: Ctrl-Y deletes `alpha beta`; after each kill, Ctrl-Y never restores the text; after Ctrl-W it also deletes the remaining `first ` |
| `01-workaround.mp4` | Base build, separate HOME: clearing Delete All Left in Settings, then Ctrl-U and Ctrl-Y restore `kill-u-sentinel` |
| `02-after.mp4`, `m3-native/` | Fix build: Ctrl-Y leaves `alpha beta` unchanged; after Ctrl-U, Ctrl-K and Ctrl-W, Ctrl-Y restores exactly `kill-u-sentinel`, `kill-k-sentinel` and `first second` |
| `before-after-captioned.mp4` | Side-by-side at normal speed, 42.5 s, no audio, captions from the event logs |
| `01-before-captioned.mp4`, `02-after-captioned.mp4`, `before.srt`, `after.srt`, `NARRATION.md` | Captioned clips, subtitle files and a text narration script |
| `m2-settings-before/` | Base build Settings: no Yank row; Delete All Left on Ctrl-Y |
| `m3-settings-after/` | Fix build Settings: "Yank (Last Killed Text)" on Ctrl-Y; Delete All Left with no Linux shortcut; searching `ctrl y` lists only Yank |
| `m2-option-a/artifacts/.../*.png` | Conflict warning when Delete all left is bound to Ctrl-Y (synthetic automated fixture) |

Publication (actual results):

- `git push --dry-run origin HEAD` from the fix branch: exit 0, `* [new branch] HEAD -> fix/11743-ctrl-y-yank`.
- `git push -u origin fix/11743-ctrl-y-yank`: exit 0, `* [new branch] fix/11743-ctrl-y-yank -> fix/11743-ctrl-y-yank`; `git ls-remote` shows `56f3560e9befd95235f9490a18d67956f1b72ac7`. https://github.com/ericrcwu001/warp-stanford/tree/fix/11743-ctrl-y-yank
- Evidence lives only on the orphan branch `evidence/11743` of the same fork (https://github.com/ericrcwu001/warp-stanford/tree/evidence/11743), updated with normal commits and pushes. The fix branch contains no `evidence/` files.
- No pull request, issue, comment, label or reaction was created anywhere. Nothing was pushed to `warpdotdev/*`.

## 6. Not verified

- **Windows, macOS, Wayland and real GPUs were not run.** Windows and macOS defaults were checked by reading the source only. All runtime results are Linux on Xvfb with software Vulkan.
- **Native unbound Ctrl-Y** after clearing or rebinding Yank was not checked in the real app. The automated tests show the harness's literal `y` fallback, not what the OS and app do natively.
- **Code editor and notebook editor at runtime.** Their Delete all left triggers are asserted through `editable_bindings()`, but no test or manual run pressed Ctrl-Y or Cmd-Backspace inside those editors.
- **Writing `keybindings.yaml` from Settings, and reload after relaunch.** Tests disable keybinding saves by default and only test reading a pre-written file. No native relaunch after a Settings change was made.
- **Native conflict warning for a Yank/Delete all left collision.** Only the synthetic automated screenshots show it. `m3-settings-after/05-yank-row-after-escape.png` shows the same warning for an unsaved `ESC` capture, which is a different case.
- **Full presubmit** (section 4.3), app unit tests (`warp --lib`, OOM) and doc tests did not run.
- IME-open state, AI/Agent input mode and the TUI front-end were not exercised.

## 7. Likely reviewer questions

1. **Why not move only the Linux/Windows Delete all left default away from Ctrl-Y (Option B)?** That is a smaller diff and also restores Ctrl-Y yank. It leaves Yank fixed and invisible in Settings, so users still could not rebind it and the conflict detector would still miss future clashes. `PROPOSAL.md` originally recommended B; the student chose A.
2. **Why not keep both defaults and warn about shadowed fixed bindings (Option C)?** A warning does not change what Ctrl-Y does by default, so the bug stays. It also needs Settings conflict changes for fixed bindings.
3. **Why does registration order matter, and what breaks if it changes?** Editable bindings are matched in reverse registration order. Yank is registered before Delete all left, so Delete all left is checked first. A user who saved Ctrl-Y for Delete all left keeps deletion. If the order were swapped, that saved choice would silently turn into Yank. `test_yank_saved_delete_all_left_ctrl_y` would fail.
4. **Should Delete all left get a new Linux/Windows default (for example Ctrl-Shift-K or Ctrl-Shift-Backspace)?** The removed comment says Ctrl-Shift-K clears blocks. This PR adds no replacement, to avoid creating a new clash; that can be a follow-up decision.
5. **What happens to Ctrl-Y in the code and notebook editors?** Their Linux/Windows Ctrl-Y default for Delete line left is gone. The editable Yank uses the same `EditorView && !IMEOpen` context as the old fixed Yank. Reviewers may want a different default there. Ctrl-Y in those editors was not tested at runtime.
6. **Does this change saved user settings?** No. The keybinding file format and parsing are unchanged. Saved `none`, rebinds and Ctrl-Y for Delete all left are read as before (the `test_yank_saved_*` cases). The new name `editor_view:yank` has no saved entries yet.
7. **Why GUI integration tests instead of keymap unit tests?** The bug comes from production registration plus matcher order, so the tests drive real key events through the real app keymap. The `warp` lib-test binary could not be built here within memory limits.
8. **Why is presubmit not green?** One attempt was made and stopped by the disk guard during workspace Clippy before any diagnostic. Targeted Clippy for `integration` and `warp` with `-D warnings` passed. CI will be the first full presubmit-equivalent run.

## 8. Explain-it-back questions with answers

1. **Q: Before the fix, why did Ctrl-Y delete text on Linux but not on macOS?**
   A: On Linux/Windows, editable Delete all left defaulted to Ctrl-Y in the same context as fixed Yank. Editable bindings are checked first and the first match wins. On macOS, Delete all left defaults to Cmd-Backspace, so nothing shadowed Yank.
2. **Q: Why did clearing Delete all left in Settings work around the bug?**
   A: Clearing saves `none`, which becomes an empty trigger. Empty triggers never match, so the matcher reached the fixed Yank on Ctrl-Y.
3. **Q: Why was Ctrl-Y after Ctrl-U unable to restore the text before the fix?**
   A: Ctrl-U put the text in the kill buffer, but Ctrl-Y ran Delete all left, which deletes without cut and never reads the kill buffer. Yank, which inserts the kill buffer, never ran.
4. **Q: Why does the fix change three files instead of one?**
   A: Delete all left is registered under one name by the input, code and notebook editors. They share one Settings row and one saved trigger, so all three defaults must match.
5. **Q: How do the tests prove that clearing Yank really disables it, rather than falling back to an old binding?**
   A: The fixed Yank was removed. After clearing, the tests press Ctrl-U to fill the kill buffer, then Ctrl-Y, and assert the input is exactly `y` (the harness's unhandled-key character), not the sentinel. A hidden fallback would have restored the sentinel and failed the step.

## 9. Reproduce from a fresh checkout

The build needs the Linux native libraries from `./script/install_cargo_build_deps` and about 10 GiB RAM+swap with one Cargo job. The Cargo flags below are the ones used here to stay within memory; they are command-line overrides, not repository changes.

```sh
git clone https://github.com/ericrcwu001/warp-stanford.git && cd warp-stanford
git fetch https://github.com/warpdotdev/warp-stanford.git master
git checkout fix/11743-ctrl-y-yank
git merge-base --is-ancestor f411fbc20e6283a2abcdd1ed64bf5b67df864f82 HEAD && echo base-ok
git diff --stat f411fbc20..HEAD      # 8 files: 3 product files, 5 integration test files

# Display for the GUI tests and the manual demo (no TCP listener)
Xvfb :99 -screen 0 1600x1000x24 -nolisten tcp &
DISPLAY=:99 openbox &
# Fresh HOME for the app under test; keep the real Cargo/rustup locations first
export CARGO_HOME=${CARGO_HOME:-$HOME/.cargo} RUSTUP_HOME=${RUSTUP_HOME:-$HOME/.rustup}
export PATH=$CARGO_HOME/bin:$PATH
export HOME=$(mktemp -d) XDG_RUNTIME_DIR=$(mktemp -d) && chmod 700 "$HOME" "$XDG_RUNTIME_DIR"

# Green: all ten cases on the fix
CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0 WARPUI_USE_REAL_DISPLAY_IN_INTEGRATION_TESTS=1 \
WGPU_BACKEND=vulkan DISPLAY=:99 WARP_SHELL_PATH=/usr/bin/zsh \
cargo nextest run --offline --config 'profile.dev.package.warp.incremental=false' \
  --config 'profile.dev.package.warp.codegen-units=256' --cargo-profile dev \
  -p integration --test integration --features warp/gui \
  -E 'test(test_ctrl_y_) | test(test_yank_) | test(test_home_key_should_not_appear_in_input)' --test-threads 1

# Red: the regression on the test-only commit (expect 1 failed, exit 100)
git checkout c1db7c276
CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0 WARPUI_USE_REAL_DISPLAY_IN_INTEGRATION_TESTS=1 \
WGPU_BACKEND=vulkan DISPLAY=:99 WARP_SHELL_PATH=/usr/bin/zsh \
cargo nextest run --offline --config 'profile.dev.package.warp.incremental=false' \
  --config 'profile.dev.package.warp.codegen-units=256' --cargo-profile dev \
  -p integration --test integration --features warp/gui \
  -E 'test(test_ctrl_y_yanks_killed_input)' --test-threads 1
git checkout fix/11743-ctrl-y-yank

# Lint (as run here)
CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0 cargo clippy --offline \
  --config 'profile.dev.package.warp.incremental=false' --config 'profile.dev.package.warp.codegen-units=256' \
  -p integration -p warp --features warp/gui --all-targets --tests -- -D warnings

# Evidence branch in a separate worktree
git fetch origin evidence/11743
git worktree add ../warp-stanford-evidence origin/evidence/11743
```

Drop `--offline` on a machine that has not fetched the crates yet.

Manual demo: build `cargo build --bin warp-oss --features gui`, launch it with a new empty HOME on `DISPLAY=:99` (the launch used here is `services.yaml` `launch_manual` in the mission records: `WGPU_BACKEND=vulkan`, `WARP_SHELL_PATH=/usr/bin/zsh`, `WARP_INTEGRATION` unset), then run `evidence/demo.sh default <label> <launcher-output-file> <app-pid> <out-dir>` from the evidence worktree. `demo.sh` hardcodes `REPO=/home/factory-user/warp-stanford`; change that line to your checkout path. Its screen coordinates assume the 1600x1000 display.

Optional caption regeneration overwrites the generated SRTs, captioned MP4s, `NARRATION.md` and the inspection files. Run it from `evidence/`, not the repository root, because the side-by-side subtitle filter uses SRT paths relative to the working directory:

```sh
(cd evidence && python3 m3-captions/make_captions.py && python3 m3-captions/inspect_frames.py && python3 m3-captions/make_narration.py)
```

It needs Python 3, `ffmpeg`/`ffprobe` built with libass and libx264, ImageMagick and DejaVu fonts.
