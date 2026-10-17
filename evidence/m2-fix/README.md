# M2 Option A fix: commands and results

Candidate: three product files only (`app/src/editor/view/mod.rs`,
`app/src/code/editor/view/actions.rs`, `app/src/notebooks/editor/view.rs`); the M1 regression in
`crates/integration/src/test/input.rs` is unchanged. Settings-before screenshots were captured
first, on the unchanged build, in `../m2-settings-before/`.

| Log | Command | Result |
| --- | --- | --- |
| `test-option-a.log` | services.yaml `commands.test` (= `test_option_a`) on owned Xvfb `:99` + Openbox | exit 0. 2 run, 2 passed, 337 skipped: `test_ctrl_y_yanks_killed_input` PASS (3.426 s), `test_home_key_should_not_appear_in_input` PASS (2.182 s). No `test_yank_*` cases exist yet |
| `lint-option-a.log` | services.yaml `commands.lint` (= `lint_option_a`): Clippy `-p integration -p warp --features warp/gui --all-targets --tests -- -D warnings`, jobs 1, debug 0, warp nonincremental / 256 codegen units | exit 0, finished in 9m 18s, no warnings or errors. No OOM |
| `format.log` | `./script/format` (once, after tests and Clippy) | exit 0, no file changes |

The M1 red output for the same test remains unchanged in `../m1-regression/`
(expected `"echo ctrl-y-yank-sentinel"`, actual `""`, nextest exit 100).

Only Linux runtime was exercised. Windows and macOS defaults were checked by source inspection only.
