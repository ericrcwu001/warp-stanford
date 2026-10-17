# Proposal: fix direction for the Ctrl-Y yank conflict (#12 / warpdotdev/warp#11743)

**Decision update (2026-10-17): the student selected Option A** ("Also, do option A"), after reviewing this proposal at the M1 checkpoint. The rest of this document, including the recommendation of B, is kept as written at that checkpoint. No product code had been changed when this update was published.

**Status at the M1 checkpoint (historical): awaiting the student's decision. No option has been selected or implemented.** The fix branch `fix/11743-ctrl-y-yank` contains only the test-only commit `c1db7c27` (the failing regression). Product source is identical to base `f411fbc20e6283a2abcdd1ed64bf5b67df864f82`. The recommendation at the end is advice for the student, not a choice. The student decides and talks to maintainers.

## The problem in one paragraph

On Linux and Windows two bindings use Ctrl-Y in the same editor context. One is the fixed (not user-editable) `ctrl-y` → Yank. The other is the editable `editor_view:delete_all_left`, whose Linux/Windows default is `ctrl-y`. The keymap lists editable bindings before fixed ones, and the matcher takes the first match, so Ctrl-Y always runs Delete All Left. Yank is not in Settings, and the conflict detector only compares editable rows, so the user gets no warning. Clearing Delete All Left in Settings writes `"editor_view:delete_all_left": none` and makes Ctrl-Y yank. On macOS, Delete All Left is `cmd-backspace`, so Ctrl-Y already yanks there (source reading only). The full trace with base-SHA line links is in `TRACE.md`.

## Facts every option has to respect

- **Real red result:** `m1-regression/red-run-committed.log`. After Ctrl-U emptied the input, Ctrl-Y left it as `""` instead of `"echo ctrl-y-yank-sentinel"` (nextest exit 100, 0 passed / 1 failed). A fix that restores default yank must turn this test green without changing what it checks.
- **Native before-state (Linux, logged out):** `01-before.mp4` and `m1-native/OBSERVATIONS.md`. Ctrl-Y deleted left text. After Ctrl-U, Ctrl-K or Ctrl-W, Ctrl-Y never restored the killed text.
- **Native workaround:** `01-workaround.mp4`. Clearing Delete All Left in Settings made Ctrl-U then Ctrl-Y restore `kill-u-sentinel`. The saved file contains `"editor_view:delete_all_left": none`.
- The editable name `editor_view:delete_all_left` is registered three times, all with Linux/Windows `ctrl-y`: input editor `app/src/editor/view/mod.rs:823-833`, code editor `app/src/code/editor/view/actions.rs:559-569` and notebook editor `app/src/notebooks/editor/view.rs:628-638`. Custom triggers apply by name to all three, and Settings shows one row. Only the input editor has a fixed Yank.
- Delete All Left also emits `Event::DeleteAllLeft`. The terminal input uses that event to switch AI input back to shell mode (`app/src/terminal/input.rs:11574`). Moving the default off Ctrl-Y moves that side effect with it.
- Saved overrides are keyed by name in `keybindings.yaml` (`app/src/keyboard.rs`). Explicit `none` entries and rebinds must keep working. Under `cfg(test)` the load/save functions are no-ops, so unit tests cannot prove disk reload.
- In the inspected boundary, `ctrl-y` is the only fixed/editable overlap with different actions (`TRACE.md` section 3.2). The other overlaps run the same action and are out of scope.

All size estimates below are rough line counts from reading the code. No option was prototyped.

## Option A: make Yank editable and visible, and resolve the default collision

**Change.** Replace the fixed `ctrl-y` Yank (`app/src/editor/view/mod.rs:267-271`) with an `EditableBinding` such as `editor_view:yank`, described as "Yank (paste the last killed text)", default `ctrl-y` on all platforms, context `EditorView & !IMEOpen`. Making Yank editable alone does not fix the default. Two editable rows on Ctrl-Y would then be decided by registration order (`Keymap::editable_bindings()` iterates in reverse). So A must also move Delete All Left's Linux/Windows default off `ctrl-y`, which is the same change as option B, in all three registrations.

| Dimension | Assessment |
| --- | --- |
| User-visible behavior | Default Ctrl-Y yanks on Linux/Windows. Settings gains a "Yank" row the user can rebind or clear. Delete All Left has no Linux/Windows default (or a new one, see B). macOS keeps Ctrl-Y yank and Cmd-Backspace Delete All Left. If a user later assigns the same key to both rows, the existing editable-row conflict warning appears, because both are now editable. |
| Files | `app/src/editor/view/mod.rs` (remove fixed Yank, add editable Yank, change Delete All Left default); `app/src/code/editor/view/actions.rs` and `app/src/notebooks/editor/view.rs` (same default change); possibly `app/src/resource_center/utils.rs` (list of editor binding names) if the new row should appear there; tests. |
| Estimated diff | About 20–35 product lines across 3–4 files, plus about 40–80 test lines. |
| Muscle-memory risk | Medium. Linux/Windows users who use Ctrl-Y for IntelliJ-style "delete line left" (the reason in the source comment at `mod.rs:829-831`) lose it by default. Readline/Emacs users gain the expected Ctrl-Y. |
| Saved-binding risk | Medium. A new name has no saved entries, and `delete_all_left: none` or rebinds keep working. Edge case: a user who explicitly saved `"editor_view:delete_all_left": ctrl-y` and the new editable Yank on `ctrl-y` would conflict. Which one wins depends on registration order, and Settings would show both as conflicting. The design must decide this case deliberately and test it. |
| Testability | Good. The existing red integration test should pass unchanged. Added cases: Yank appears as an editable binding; clearing or rebinding Yank changes dispatch; macOS defaults unchanged (code check only, no native macOS run). The persisted explicit `ctrl-y` case needs an integration run that seeds `keybindings.yaml` before launch, because unit tests cannot reload from disk. Whether the integration fixture supports pre-seeding that file has not been checked yet. |

## Option B: move the Linux/Windows Delete All Left default off Ctrl-Y

**Change.** In the three `editor_view:delete_all_left` registrations, remove `.with_linux_or_windows_key_binding("ctrl-y")` (no default on Linux/Windows, like `editor_view:delete_all_right`, which is macOS-only at `mod.rs:815-822`) or replace it with another key. Update the source comment. Yank stays fixed and hidden.

| Dimension | Assessment |
| --- | --- |
| User-visible behavior | Default Ctrl-Y yanks on Linux/Windows, which matches the reporter's goal and the native workaround result. Delete All Left stays in Settings with no shortcut (or the new key). Yank stays invisible in Settings and cannot be rebound. macOS is unchanged. |
| Files | `app/src/editor/view/mod.rs`, `app/src/code/editor/view/actions.rs`, `app/src/notebooks/editor/view.rs`; tests. Changing all three keeps the de-duplicated Settings row consistent. |
| Estimated diff | About 3–10 product lines (one builder call and a comment per registration), plus about 20–50 test lines. Choosing a new key adds a conflict check. For example, `ctrl-shift-backspace` is already the Linux/Windows default for `input:clear_and_reset_ai_context_menu_query` (`app/src/terminal/input.rs:2334-2341`), and the source comment rules out `ctrl-shift-K`. |
| Muscle-memory risk | Medium, the same loss as A for Ctrl-Y-as-delete users. They can assign any key in Settings. |
| Saved-binding risk | Low. Users with no entry get the new default. `none` entries and rebinds are untouched. A user who explicitly saved `ctrl-y` for Delete All Left keeps it and keeps shadowing Yank, which respects their explicit choice. |
| Testability | Best. The existing red test should turn green with no test change. Add a check that Delete All Left has no `ctrl-y` default on Linux/Windows, or has the chosen key. The persisted-override case has the same disk-reload limitation as A. |

## Option C: keep defaults and warn when an editable binding shadows a fixed one

**Change.** Extend the Settings conflict check (`app/src/settings_view/keybindings.rs`, `ConflictMap` at L105-147, populated at L795-801) to also look at fixed bindings, for example through `Matcher::get_bindings()`/`bindings_for_context`. Show a message such as "Shadows built-in Yank (Ctrl-Y)" on the Delete All Left row.

| Dimension | Assessment |
| --- | --- |
| User-visible behavior | **Default Ctrl-Y still deletes left text.** Users who open Settings see a warning and can clear the row themselves, the same workaround the reporter already found. This partly meets the reporter's first ask ("At least warn a user"). |
| Files | `app/src/settings_view/keybindings.rs` (conflict model and row rendering); probably `app/src/util/bindings.rs` or warpui keymap helpers to expose fixed bindings with their descriptions/contexts; tests. UI work would follow `gui-settings-ui` / `gui-ui-guidelines`. |
| Estimated diff | About 60–150 product lines. Fixed bindings have no names and mostly no descriptions, and keystroke equality alone gives false positives across unrelated views (`enter`, `escape`, `tab` are fixed in many views). A correct check has to restrict itself to bindings whose context predicates can hold together, which the current code does not model. |
| Muscle-memory risk | None. Nothing changes by default. |
| Saved-binding risk | None. No defaults or persisted data change. |
| Testability | Weak in this environment. The red regression stays red, so it cannot serve as the acceptance test. Settings-view logic lives in the `warp` app crate, whose unit-test binary repeatedly ran out of memory here (see `ENVIRONMENT.md`). A real-GUI integration test of the warning is possible but heavier. |

**Limitation of warning-only C:** C alone does not deliver the default kill-then-yank flow. Ctrl-U then Ctrl-Y would still lose the text unless the user finds the warning and clears the binding. If the student picks C, the mission's original acceptance goal (default Ctrl-Y yanks; the M1 regression turns green) would have to change, and the orchestrator must ask before rewriting it. C can also be combined with A or B as a later follow-up.

## Side-by-side

| | A: editable Yank + collision fix | B: change Delete All Left default | C: warning only |
| --- | --- | --- | --- |
| Default Ctrl-Y yanks on Linux/Windows | Yes | Yes | **No** |
| Yank visible/rebindable in Settings | Yes | No | No (only a warning) |
| Product diff (estimate) | ~20–35 lines, 3–4 files | ~3–10 lines, 3 files | ~60–150 lines, 1–2+ files plus UI |
| Muscle-memory risk | Medium | Medium | None |
| Saved-binding risk | Medium (explicit `ctrl-y` override vs new editable Yank) | Low | None |
| M1 red test turns green | Yes | Yes | No |
| Testability here | Good | Best | Weak |

## Recommendation (for the student to accept or reject)

I recommend **B** as the first PR, with **A** as the alternative if maintainers want Yank to be rebindable.

Reasoning:
1. B is the smallest change that restores the reporter's default flow. That flow was reproduced natively and is captured by the real failing test. B changes only what the reporter's own workaround already changes: Delete All Left is no longer on Ctrl-Y.
2. B respects saved choices. Existing `none` entries, rebinds and explicit `ctrl-y` overrides keep working as written.
3. A meets the reporter's second ask ("let user change the internal hard-coded bindings") but contains B anyway. It also adds the explicit-override ordering question and a new Settings row, which a maintainer may want to weigh in on first. The GUI would then match the TUI front-end, which already has an editable `ctrl-y` yank (`crates/warp_tui/src/editor_interaction.rs:351-357`).
4. C does not fix the default behavior and is the largest change, so it fits better as an optional follow-up.

Risks the student should raise with maintainers whatever the choice: whether Linux/Windows Delete All Left should have no default or a new key, the loss of the IntelliJ-style Ctrl-Y for some users, and the `Event::DeleteAllLeft` AI-to-shell side effect moving with the key.

**Next step:** the student reviews this proposal, discusses it on the fork issue or with maintainers if they want, and replies with the chosen option (A, B, C or a variant). Until then no M2 work will start.

## Decision update (2026-10-17)

The student chose **Option A**. The recommendation above (B first, A as the alternative) is kept as the historical advice. M2 implements A within the scope described in the Option A section, after M1 validation.
