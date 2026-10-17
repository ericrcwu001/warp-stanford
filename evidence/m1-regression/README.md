# M1 expected-red regression: `test_ctrl_y_yanks_killed_input`

This is an intentionally failing regression that demonstrates the bug. It is not a passing product test. No fix has been implemented.

## What the test does

Source: `crates/integration/src/test/input.rs` (`test_ctrl_y_yanks_killed_input`), registered in `crates/integration/src/bin/integration.rs` (`register_test!`) and in the nextest list `crates/integration/tests/integration/ui_tests.rs`.

1. `wait_until_bootstrapped_single_pane_for_tab(0)`.
2. Asserts the input is exactly `""` (`assert_input_editor_contents`).
3. Types `echo ctrl-y-yank-sentinel` (`with_typed_characters`) and asserts exactly that text.
4. Sends `ctrl-u` through `with_keystrokes` (`Event::KeyDown` → window callback → normal keymap dispatch) and asserts `""`.
5. Sends `ctrl-y` the same way and asserts the input is exactly `echo ctrl-y-yank-sentinel` again.

The test does not call `EditorAction::Yank` directly, mock the matcher, change defaults or install custom bindings. It uses the stock integration fixture (approved synthetic authenticated test user, automated tests only; no real account or credentials).

## Result on unchanged product source

Tested revision: `c1db7c276e82d214277480879b7c41201dfa5651` (original base `f411fbc20e6283a2abcdd1ed64bf5b67df864f82` plus this test-only commit; no files outside `crates/integration/` differ from base). Working tree had only the untracked `evidence/` directory.

Steps 1–4 succeeded. Step 5 failed at the final assertion:

```
Test step 'Yank the killed input with ctrl-y' failed after 1 attempts: assertion failed: `Incorrect input box contents:
Expected "echo ctrl-y-yank-sentinel"
Actual: ""`
```

nextest: `1 test run: 0 passed, 1 failed, 338 skipped`, exit status 100. The shell was `/usr/bin/zsh` (log: `Starting shell /usr/bin/zsh`). This is a real assertion failure after bootstrap, not a compile, setup, display or timeout failure. Ctrl-Y left the input empty because the Linux/Windows editable `editor_view:delete_all_left` default (`ctrl-y`) matched before the fixed `ctrl-y` → `Yank` binding.

## Command and environment

`services.yaml` `commands.test_regression`, with an owned Xvfb `:99` (1600x1000x24, `-nolisten tcp`) and Openbox, plus a fresh HOME/XDG_RUNTIME_DIR (mode 700):

```sh
export CARGO_HOME=/home/factory-user/.cargo RUSTUP_HOME=/home/factory-user/.rustup
export PATH=/home/factory-user/.cargo/bin:$PATH
export HOME=$(mktemp -d /tmp/warp-11743-m1-red2-home.XXXXXX)
export XDG_RUNTIME_DIR=$(mktemp -d /tmp/warp-11743-m1-red2-runtime.XXXXXX)
chmod 700 "$HOME" "$XDG_RUNTIME_DIR"
cd /home/factory-user/warp-stanford && . /home/factory-user/.cargo/env && \
CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0 WARPUI_USE_REAL_DISPLAY_IN_INTEGRATION_TESTS=1 \
WGPU_BACKEND=vulkan DISPLAY=:99 WARP_SHELL_PATH=/usr/bin/zsh \
cargo nextest run --offline --config 'profile.dev.package.warp.incremental=false' \
  --config 'profile.dev.package.warp.codegen-units=256' --cargo-profile dev \
  -p integration --test integration --features warp/gui \
  -E 'test(test_ctrl_y_yanks_killed_input)' --test-threads 1
```

The test binary was compiled first with the same flags and `--no-run`, with no display or app running.

## Files

| File | Contents |
| --- | --- |
| `red-run-committed.log` | Complete output of the run at commit `c1db7c27…` (canonical red evidence) |
| `red-run-precommit.log` | Complete output of the first run, on base `f411fbc2…` with the same test as uncommitted changes. That tree differed from the commit only by one missing blank line between functions. Same failure |
| `build.log`, `build-committed.log` | `--no-run` compile output for each run (both exit 0) |
| `clippy.log` | `cargo clippy -p integration --features warp/gui --all-targets --tests -- -D warnings` (manifest `lint`), exit 0 |
| `format.log` | `./script/format`, exit 0; it changed no files beyond the test diff |
| `test-only.patch` | `git show` of the test-only commit |

## Separate green sanity evidence (reused, not rerun here)

The environment sanity check is the existing `test_home_key_should_not_appear_in_input` (manifest `commands.test`). It passed earlier with 1 passed, 337 skipped, exit 0. See `../logs/readiness/` and the M0 scrutiny logs. That check is unrelated to this red result and was not rerun for this feature.
