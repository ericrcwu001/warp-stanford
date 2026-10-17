<!-- Local draft for the student to edit and open. It has not been posted anywhere. Title suggestion: "Make Ctrl-Y yank editable and drop the Linux/Windows Delete all left Ctrl-Y default" -->

## Description

On Linux and Windows, Ctrl-Y in the terminal input deleted everything left of the cursor instead of yanking the text that Ctrl-U, Ctrl-K or Ctrl-W had killed. Fixed `Yank` and editable `editor_view:delete_all_left` both defaulted to Ctrl-Y in the `EditorView && !IMEOpen` context. The keymap checks editable bindings before fixed ones, so Delete all left always won. Yank was also missing from Settings, so the conflict warning never showed.

This PR:
- Replaces the fixed Ctrl-Y Yank with an editable binding, `editor_view:yank` ("Yank (last killed text)"), default Ctrl-Y on all platforms, same context.
- Removes the Linux/Windows Ctrl-Y default from the three `editor_view:delete_all_left` registrations (input, code and notebook editors). They share one Settings row, so their defaults must match. The actions and the macOS Cmd-Backspace default do not change.
- Registers Yank before Delete all left. Editable bindings match in reverse registration order, so a user who saved Ctrl-Y for Delete all left keeps that behavior.

Behavior changes to check:
- Delete all left has no default key on Linux/Windows. This PR adds no replacement key. Ctrl-Shift-K, the alternative named in the removed comment, clears blocks.
- In the code and notebook editors, Ctrl-Y no longer runs Delete line left on Linux/Windows.
- macOS gets an editable Yank row with the same Ctrl-Y default.

Alternatives considered: only moving the Delete all left default (Yank stays hidden and cannot be rebound), or adding a shadowing warning (the default bug remains).

## Linked Issue
Fixes #12
Upstream report: warpdotdev/warp#11743

- [ ] The linked issue is labeled `ready-to-spec` or `ready-to-implement`. (Not checked: the label was not confirmed.)
- [ ] Where appropriate, screenshots or a short video of the implementation are included below (especially for user-visible or UI changes). (Check after attaching the media below.)

## Testing

New GUI integration tests in `crates/integration` send real key events through the app keymap and assert the exact input text. They run as the integration framework's synthetic test user.
- `test_ctrl_y_yanks_killed_input`: types text, Ctrl-U, Ctrl-Y, expects the text back. It failed on the unchanged product (`Expected "echo ctrl-y-yank-sentinel"`, `Actual: ""`) and passes with the fix.
- Eight `test_yank_*` cases: rebind, clear and reset Yank in Settings; the conflict warning when Delete all left is bound to Ctrl-Y; and saved `keybindings.yaml` files (`none`, a rebind, or Ctrl-Y for Delete all left, plus `none` or a custom key for Yank). These were written after the fix and have no failing run.

Results on Linux (Ubuntu 24.04, Xvfb, software Vulkan):
- `cargo nextest run -p integration --test integration --features warp/gui -E 'test(test_ctrl_y_) | test(test_yank_) | test(test_home_key_should_not_appear_in_input)'`: 10 passed, 337 skipped.
- `cargo clippy -p integration -p warp --features warp/gui --all-targets --tests -- -D warnings`: passed.
- `./script/format`: no changes.
- `./script/presubmit`: did not complete. Format check and inline-test check passed. The run was stopped for low disk space during workspace Clippy, before Clippy printed any diagnostic. Later steps did not run (GUI Clippy, clang-format, wgslfmt, ShellCheck, PSScriptAnalyzer, workspace nextest, doc tests).

Manual: a logged-out `warp-oss` debug build (`cargo build --bin warp-oss --features gui`, not `./script/run`) with the same scripted xdotool input before and after the fix. Before: Ctrl-Y deleted the input and never restored killed text. After: Ctrl-Y restored the text killed by Ctrl-U, Ctrl-K and Ctrl-W, and did nothing to plain input.

Not tested: Windows, macOS, Wayland, real GPU; Ctrl-Y in the code and notebook editors; native behavior of an unbound Ctrl-Y; writing `keybindings.yaml` from Settings and reloading it.

- [ ] I have manually tested my changes locally with `./script/run` (Not checked: manual testing used a `warp-oss` build on Linux, as described above.)

### Screenshots / Videos
<!-- Attach from the evidence branch: https://github.com/ericrcwu001/warp-stanford/tree/evidence/11743/evidence -->
- [VIDEO: before-after-captioned.mp4 — side-by-side, before left, after right, 42.5 s, no audio]
- [SCREENSHOT: m2-settings-before/02-settings-search-delete-all-left.png — before: Delete All Left on Ctrl-Y]
- [SCREENSHOT: m3-settings-after/01-settings-search-yank.png — after: Yank (Last Killed Text) on Ctrl-Y]
- [SCREENSHOT: m3-settings-after/02-settings-search-delete-all-left.png — after: Delete All Left with no Linux shortcut]
- [SCREENSHOT: m2-option-a/artifacts/test_yank_settings_conflict_warning/2026-10-17T21-21-00/delete_all_left_ctrl_y_conflict.png — conflict warning when Delete all left is set to Ctrl-Y (automated test capture)]

## Agent Mode
- [ ] Warp Agent Mode - This PR was created via Warp's AI Agent Mode

<!--
## Changelog Entries for Stable

The entries below will be used when constructing a soft-copy of the stable release changelog. Leave blank or remove the lines if no entry in the stable changelog is needed. Entries should be on the same line, without the `{{` `}}` brackets. You can use multiple lines, even of the same type. The valid suffixes are:

- NEW-FEATURE: for new, relatively sizable features. Features listed here will likely have docs / social media posts / marketing launches associated with them, so use sparingly.
- IMPROVEMENT: for new functionality of existing features.
- BUG-FIX: for fixes related to known bugs or regressions.
- IMAGE: the image specified by the URL (hosted on GCP) will be added to Dev & Preview releases. For Stable releases, see the pinned doc in the #release Slack channel.
- OZ: Oz-related updates. Use `CHANGELOG-OZ`. At most 4 Oz updates are shown in-app per release.
- TUI: updates that impact Warp Agent CLI users, including shared Agent capabilities. Use `CHANGELOG-TUI` for text that should appear in the TUI zero state. It may be used alongside another changelog entry when a change affects multiple surfaces.
- NONE: Explicitly opt out of changelog inclusion. Use `CHANGELOG-NONE` for PRs that should never appear in the changelog (e.g. refactors, internal tooling, CI changes). This prevents the changelog agent from inferring an entry.
-->
CHANGELOG-BUG-FIX: On Linux and Windows, Ctrl-Y in the input now yanks the last killed text instead of deleting to the start of the line. Yank can be changed in Settings > Keyboard shortcuts, and Delete all left no longer has a Ctrl-Y default.
