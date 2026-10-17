# Integration readiness
## Approved boundary
- Follow-up authorization permitted deletion ONLY of `/home/factory-user/warp-stanford/target/debug/incremental`, generated during this session, followed by one retry of the same existing nextest harness. This scoped cleanup was performed once; no other cleanup. Existing raw failed/blocked logs and all `/tmp` evidence retained.
- User expressly permitted the repository's stock synthetic authenticated test user for AUTOMATED TESTS ONLY. No real credentials, accounts, login, cloud writes, GitHub writes, commits or pushes were used.
- The earlier normal `warp-oss` manual GUI session/evidence remains genuinely logged out. This automated integration screenshot is synthetic-test evidence, not logged-out manual proof.
- Read `/home/factory-user/warp-stanford/.agents/skills/gui-integration-test/SKILL.md`. Used unmodified stock runner/fixtures/tests on clean `fix/11743-ctrl-y-yank` at `f411fbc20e6283a2abcdd1ed64bf5b67df864f82`.
- Runner's Integration channel uses blackhole `http://192.0.2.0:9` / `ws://192.0.2.0:9/graphql/v2`, empty auth API key, and no telemetry/crash/autoupdate config. No real user state or tokens copied.

## Commands and results
- **Latest result: PASS — existing real-display nextest automation is now executable for a mission proposal.** The already-running approved retry continued through an interrupted observation call; no duplicate build, cleanup or display was started when observation resumed.
- Scoped deletion first confirmed that `/home/factory-user/warp-stanford/target/debug/incremental` was a directory, not a symlink, and resolved to exactly that path. High-risk, explicitly authorized deletion affected ONLY that directory. Cleanup log `/tmp/ctrl-y-integration-cleanup.log`; `target/debug/deps`, `target/debug/build`, binaries, sources and earlier evidence retained.
- Fresh outer `HOME=/tmp/ctrl-y-integration-retry-home.JH3EpO`, `XDG_RUNTIME_DIR=/tmp/ctrl-y-integration-retry-runtime.IS1VC7`, mode 700; original Cargo/Rustup caches explicitly preserved. Owned Xvfb :99 and Openbox only. Exact retry from repository after sourcing `/home/factory-user/.cargo/env`:
  ```sh
  export HOME=/tmp/ctrl-y-integration-retry-home.JH3EpO
  export XDG_RUNTIME_DIR=/tmp/ctrl-y-integration-retry-runtime.IS1VC7
  export CARGO_HOME=/home/factory-user/.cargo RUSTUP_HOME=/home/factory-user/.rustup WARP_INTEGRATION=1
  CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0 WARPUI_USE_REAL_DISPLAY_IN_INTEGRATION_TESTS=1 WGPU_BACKEND=vulkan DISPLAY=:99 WARP_SHELL_PATH=/usr/bin/zsh timeout --signal=TERM --kill-after=30s 35m cargo nextest run --offline --config 'profile.dev.package.warp.incremental=false' --config 'profile.dev.package.warp.codegen-units=256' --cargo-profile dev -p integration --test integration --features warp/gui -E 'test(test_home_key_should_not_appear_in_input)' --test-threads 1
  ```
- Full log `/tmp/ctrl-y-integration-nextest-retry.log`: **numeric exit 0**, supervised elapsed **591.57 seconds (9m 51.57s)**; Cargo build 9m 35s. Actual warp compiler observed `--crate-type lib`, no `--test`; only `warp` and `integration` recompiled, remaining dependencies reused. Exact runner output:
  ```text
   Starting 1 test across 1 binary (337 tests skipped)
       PASS [   4.464s] (1/1) integration::integration ui_tests::test_home_key_should_not_appear_in_input
    Summary [   4.486s] 1 test run: 1 passed, 337 skipped
  INTEGRATION_NEXTEST_RETRY_EXIT=0 ELAPSED_SECONDS=591.57 STOP_REASON=None
  ```
- Same real-display Vulkan/Zsh configuration as successful direct runs; outer harness forwards WARP_ / WARPUI_ / WGPU_ and DISPLAY. Direct logs above/below establish actual Vulkan llvmpipe and `/usr/bin/zsh` 5.9. Successful nextest output is captured without claiming suppressed success logs independently print renderer/shell details.
- Test/app/compile processes exited normally before Openbox PID 115197 and Xvfb PID 115181 were stopped, in that order. Owned wrapper/session/display processes confirmed gone; :99 socket/lock removed. No new source/config/test changes, failing regression, commits, pushes, account/login or cgroup changes. Synthetic automated fixture exception only; earlier manual evidence remains logged out.
- The following earlier blocked attempt and direct/build results are preserved as history.
- Build from `/home/factory-user/warp-stanford` after `. /home/factory-user/.cargo/env`:
  ```sh
  CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0 timeout --signal=TERM --kill-after=30s 35m cargo build --locked --offline --config 'profile.dev.package.warp.incremental=false' --config 'profile.dev.package.warp.codegen-units=256' -p integration --bin integration --features warp/gui
  ```
  **PASS**, exit 0. Cargo: 15m 58s; supervised elapsed 970.51s (sampling/wait overhead included). Full log `/tmp/ctrl-y-integration-build.log`. Observed actual warp rustc: `--crate-type lib`, no `--test`, normal app library with integration_tests rather than app lib-test. Actual full invocation retained in log. Dependencies required by integration features compiled; existing caches reused otherwise. No linker change.
- Owned `Xvfb :99 -screen 0 1600x1000x24 -nolisten tcp` and Openbox. Display free before launch. Outer HOME `/tmp/ctrl-y-integration-home.RFf6QS`, runtime `/tmp/ctrl-y-integration-runtime.Hdwl7H`, both mode 700; preserved `CARGO_HOME=/home/factory-user/.cargo`, `RUSTUP_HOME=/home/factory-user/.rustup`.
- Common automated runtime environment:
  ```sh
  export HOME=/tmp/ctrl-y-integration-home.RFf6QS
  export XDG_RUNTIME_DIR=/tmp/ctrl-y-integration-runtime.Hdwl7H
  export CARGO_HOME=/home/factory-user/.cargo RUSTUP_HOME=/home/factory-user/.rustup
  export WARP_INTEGRATION=1 WARPUI_USE_REAL_DISPLAY_IN_INTEGRATION_TESTS=1
  export WGPU_BACKEND=vulkan DISPLAY=:99 WARP_SHELL_PATH=/usr/bin/zsh
  ```
  Framework further isolated HOME under `target/debug/build/integration-00220792400bd191/out/tmp/<test_name>` with generated shell rc files and preferences; these per-test HOME directories were cleaned by the framework.
- `timeout --signal=TERM --kill-after=10s 3m target/debug/integration test_home_key_should_not_appear_in_input`
  **All assertions PASS**: Wait for bootstrapping; Press home key and verify it doesn't show up in input. Log `/tmp/ctrl-y-integration-home.log`. Run spans approximately 06:41:16–06:41:20 UTC; app terminated naturally and no process remained. Direct launch used managed background execution without a separate exit-code footer, so its numeric exit status was not independently retained. Do not conflate this with an outer-nextest pass.
- `timeout --signal=TERM --kill-after=10s 3m target/debug/integration test_undo_redo`
  **PASS**, captured exit 0, elapsed 3.74s. All six steps succeeded: bootstrap, type `foo`, undo to empty, redo to `foo`, execute/clear, undo remains empty after stack reset. Full log `/tmp/ctrl-y-integration-undo.log`.
- Both actual app logs confirm `Using Vulkan Cpu (llvmpipe (LLVM 20.1.2, 256 bits))`, Mesa 25.2.8 and `Starting shell /usr/bin/zsh`, bootstrapped Zsh 5.9. This resolves actual-shell selection for AUTOMATED tests, not the earlier manual Bash session.
- Screenshot `/tmp/ctrl-y-integration-readiness.png` captured during live undo test and visually inspected: actual Warp integration window, zsh tab, synthetic-user avatar, prompt area. It caught the transitional `Starting zsh...` frame; framework assertions, not this screenshot, establish input behavior. Initial early black screenshot was replaced by this actual-window capture.
- Exact outer-harness attempt with common environment above, after sourcing cargo env:
  ```sh
  CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0 WARPUI_USE_REAL_DISPLAY_IN_INTEGRATION_TESTS=1 WGPU_BACKEND=vulkan DISPLAY=:99 WARP_SHELL_PATH=/usr/bin/zsh timeout --signal=TERM --kill-after=30s 35m cargo nextest run --offline --config 'profile.dev.package.warp.incremental=false' --config 'profile.dev.package.warp.codegen-units=256' --cargo-profile dev -p integration --test integration --features warp/gui -E 'test(test_home_key_should_not_appear_in_input)' --test-threads 1
  ```
  **BLOCKED by disk guard**, elapsed 811.11s. Full log `/tmp/ctrl-y-integration-nextest.log`:
  ```text
  NORMAL_APP_LIBRARY_VALIDATED=True
  DISK_GUARD: less than 1 GiB free
  INTEGRATION_NEXTEST_EXIT=-15 ELAPSED_SECONDS=811.11 STOP_REASON=DISK_GUARD: less than 1 GiB free
  ```
  Supervisor sent TERM to only its owned build session; -15 denotes SIGTERM (managed wrapper reports conventional 143). No test runner output/pass was produced because harness build did not complete. It rebuilt dependencies under integration's dev-dependency feature set and normal warp library; actual warp invocation again verified `--crate-type lib`, not `--test`. No app-lib-test compile was attempted.
- Stopped after this concrete disk blocker. No cleanup/retry/extra build or fixture/source change. Tests exited before Openbox, then Xvfb were stopped in that order; no display teardown panic in these runs. All owned processes stopped.

## Resources
- Authorized cleanup: free disk **1,020,641,280 → 18,121,129,984 bytes**, reclaiming **17,100,488,704 bytes (~15.93 GiB)** in 2.43s. Logical incremental-cache size before deletion was 17,728,553,623 bytes; filesystem allocation differs. Cargo subsequently recreated a small compiler incremental directory for other package artifacts (108,992,285 logical bytes at final inspection); no second deletion performed.
- Retry samples `/tmp/ctrl-y-integration-nextest-retry-resources.log`: peak sampled RAM **7,091,675,136 bytes (~6.60 GiB)**, swap **2,296,606,720 bytes (~2.14 GiB)**, simultaneous combined **9,335,574,528 bytes (~8.69 GiB)**. No new OOM: events stayed 23, kills stayed 4. Retry CPU delta 537,944,453 microseconds (~537.94 CPU seconds).
- Retry disk free 18,120,847,360 bytes initially; minimum 16,906,432,512 bytes; after test 16,910,241,792 bytes. After display shutdown 16,909,860,864 bytes (~15.75 GiB) free. No guard/timeout triggered. Cgroup after test RAM/swap 5,649,543,168/59,826,176 bytes includes filesystem caches; after display shutdown 5,625,122,816/32,301,056 bytes.
- Historical build/blocked-attempt measurements follow unchanged.
- Effective cgroup unchanged: 7,091,675,136 bytes RAM (~6.60 GiB), 4,171,575,296 bytes swap (~3.89 GiB). Serialized validators maximum 1.
- Resource samples `/tmp/ctrl-y-integration-resources.log`: build sampled every 2s before observing warp library then every 10s; undo every 0.5s; nextest every 1s.
- Runner build peak sampled RAM 7,091,662,848 bytes, swap 2,212,036,608 bytes; peak simultaneous RAM+swap 9,272,913,920 bytes (~8.64 GiB). Disk free 9,931,800,576 → 4,791,840,768 bytes.
- Direct undo peak sampled RAM 5,820,153,856 bytes, swap 63,410,176 bytes; these cgroup figures include build filesystem cache, agent, display and app, not just app RSS. No separate Home-test resource sampler; do not infer its peak from undo.
- Outer harness peak sampled RAM 7,091,675,136 bytes, swap 2,460,200,960 bytes; simultaneous combined 9,516,322,816 bytes (~8.86 GiB). Free disk started 4,791,189,504 bytes and reached 1,049,313,280 bytes at guard (~1000.70 MiB; below 1 GiB=1,073,741,824 bytes). Final inspection free 1,031,438,336 bytes (~983.66 MiB).
- OOM counters unchanged across runner build, both direct tests and outer attempt: OOM events 23, OOM kills 4 (from prior app-lib-test failures). No new OOM. No limits raised, swap changes, cache deletion or artifact cleanup.

## Limitations
- **Existing direct and outer-nextest integration paths are now verified executable.** Earlier disk blocker resolved by the one explicitly authorized cache deletion; historical blocked raw log retained. This is readiness for an integration-based mission proposal, not issue #11743 proof or approval to implement.
- Earlier giant app lib-test compilation still OOMs, including genuinely nonincremental jobs=1/debug=0. Successful normal-library integration is an approved alternative test level, not a claim that app lib-tests pass.
- Relevant Clippy/build checks for future implementation, especially `--all-targets --tests`, may encounter the same app-lib-test/resource constraints. Full presubmit was not run and must not be silently bypassed/represented as passing; AGENTS requires it only when explicitly requested. Future mission needs an explicit executable validation strategy.
- API-key-deserialization warnings are from empty synthetic fixture state; D-Bus desktop service absent. Teardown logged an attempted local queued-telemetry flush with missing test HOME after cleanup; channel telemetry config is None and no real telemetry endpoint/account was configured. These messages did not fail direct assertions.
- No regression/failing test or bug fix written; no issue #11743 proof or implementation conclusion. Manual genuinely logged-out evidence and synthetic automated evidence must remain distinct.

## Files
- Latest follow-up intentional created/modified files:
  - `/tmp/ctrl-y-integration-cleanup.log`
  - `/tmp/ctrl-y-integration-nextest-retry.log`
  - `/tmp/ctrl-y-integration-nextest-retry-resources.log`
  - `/tmp/ctrl-y-integration-retry-xvfb.log`
  - `/tmp/ctrl-y-integration-retry-openbox.log`
  - `/tmp/ctrl-y-integration-readiness.md`
  - `/tmp/ctrl-y-validation-readiness.md`
- Latest managed output logs:
  - `/tmp/droid-bg-1792220436653-218f9794-a6a8-4355-b7c9-2b1e3bbbb247.out`
  - `/tmp/droid-bg-1792220442516-f6c9fa66-42b0-434f-b14b-80e38eb53098.out`
  - `/tmp/droid-bg-1792220456455-ac688632-faa4-478a-95d2-69e9e148b97c.out`
- Approved deleted directory: `/home/factory-user/warp-stanford/target/debug/incremental` (later recreated by Cargo, not deleted again).
- Latest generated state: `/home/factory-user/warp-stanford/target/debug/`, `/home/factory-user/.cargo/.global-cache`, `/tmp/ctrl-y-integration-retry-home.JH3EpO/`, `/tmp/ctrl-y-integration-retry-runtime.IS1VC7/`; framework action log `/tmp/warp_integration_test_artifacts/test_home_key_should_not_appear_in_input/2026-10-17T07-10-45/recording.log`. Other tracked/source files unchanged.
- Earlier files/history:
- Intentional created/modified paths:
  - `/tmp/ctrl-y-integration-build.log`
  - `/tmp/ctrl-y-integration-resources.log`
  - `/tmp/ctrl-y-integration-home.log`
  - `/tmp/ctrl-y-integration-undo.log`
  - `/tmp/ctrl-y-integration-nextest.log`
  - `/tmp/ctrl-y-integration-xvfb.log`
  - `/tmp/ctrl-y-integration-openbox.log`
  - `/tmp/ctrl-y-integration-readiness.png`
  - `/tmp/ctrl-y-integration-readiness.md`
  - `/tmp/ctrl-y-validation-readiness.md`
- Managed output logs:
  - `/tmp/droid-bg-1792218199044-3dbea63e-180b-40a2-9a37-e67e9bb31580.out`
  - `/tmp/droid-bg-1792219267713-ebcfcadf-62de-4e6c-a0b0-df66e87b93f7.out`
  - `/tmp/droid-bg-1792219275821-27746ba6-0c28-4c94-92b2-b1c9786cbe1d.out`
  - `/tmp/droid-bg-1792219276039-a229456b-ef02-425d-bdb7-e530f8a34ee6.out`
  - `/tmp/droid-bg-1792219329236-b5d8b5a5-7fb8-46f4-abef-23bd4b8871cb.out`
- Generated state/cache trees: `/home/factory-user/warp-stanford/target/debug/`, `/home/factory-user/.cargo/.global-cache`, `/tmp/ctrl-y-integration-home.RFf6QS/` (Openbox/Mesa cache), `/tmp/ctrl-y-integration-runtime.Hdwl7H/`. No generated-file enumeration.
- Framework action logs:
  - `/tmp/warp_integration_test_artifacts/test_home_key_should_not_appear_in_input/2026-10-17T06-41-19/recording.log`
  - `/tmp/warp_integration_test_artifacts/test_undo_redo/2026-10-17T06-41-49/recording.log`
- Tracked repository files remain unchanged. Installed skills and reconciled skills-lock retained. No new source/config files, credentials or account state.
