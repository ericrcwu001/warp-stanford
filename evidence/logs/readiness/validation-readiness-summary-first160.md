# Validation readiness
- **Latest: existing real-display integration automation PASS, now executable for a mission proposal.** After exactly one explicitly authorized deletion of session-generated `/home/factory-user/warp-stanford/target/debug/incremental` (verified directory/not symlink), the existing nextest retry completed with **exit 0** in **591.57s**: `PASS [4.464s] integration::integration ui_tests::test_home_key_should_not_appear_in_input`; summary **1 passed, 337 skipped**. Raw output `/tmp/ctrl-y-integration-nextest-retry.log`. The observation interruption did not stop the managed build; resumed that existing job, no duplicate build/deletion/display.
- Exact source-cargo-env command: `CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0 WARPUI_USE_REAL_DISPLAY_IN_INTEGRATION_TESTS=1 WGPU_BACKEND=vulkan DISPLAY=:99 WARP_SHELL_PATH=/usr/bin/zsh timeout --signal=TERM --kill-after=30s 35m cargo nextest run --offline --config 'profile.dev.package.warp.incremental=false' --config 'profile.dev.package.warp.codegen-units=256' --cargo-profile dev -p integration --test integration --features warp/gui -E 'test(test_home_key_should_not_appear_in_input)' --test-threads 1`. Fresh outer HOME/runtime with Cargo/Rustup cache preserved and WARP_INTEGRATION=1. Normal warp `--crate-type lib`, no app lib-test; only warp/integration rebuilt.
- Cleanup disk free 1,020,641,280 → 18,121,129,984 bytes; only approved incremental cache deleted. Retry peak sampled cgroup RAM/swap ~6.60/2.14 GiB, combined ~8.69 GiB; no new OOM (kills remain 4). Final after display shutdown free disk **16,909,860,864 bytes (~15.75 GiB)**. Logs `/tmp/ctrl-y-integration-cleanup.log` and `/tmp/ctrl-y-integration-nextest-retry-resources.log`. Test exited before owned Openbox/Xvfb teardown; no orphan.
- Synthetic authenticated fixture allowed AUTOMATED TESTS ONLY; manual normal Warp evidence stays genuinely logged out. Source/tests/manifests/config unchanged on `fix/11743-ctrl-y-yank` at `f411fbc20e6283a2abcdd1ed64bf5b67df864f82`. No real account/login, external writes, commits or push. Earlier app-lib-test OOM and possible future Clippy/all-targets/full-presubmit constraints remain recorded, not bypassed. No issue-specific regression/fix before mission approval.
- Detailed current status and intentional-file/deleted-directory accounting: `/tmp/ctrl-y-integration-readiness.md`. Previous failed/blocked history below is retained; its disk-readiness conclusion is superseded by this successful retry.

- **Latest approved GUI integration alternative: direct existing tests PASS; outer-nextest readiness BLOCKED by disk.** Stock synthetic authenticated user explicitly authorized for AUTOMATED tests only; normal manual Warp/evidence stays genuinely logged out. No real credentials/accounts/login, code changes, commits or external writes.
- Built normal-library runner successfully with jobs=1/debug=0, package-scoped warp incremental=false/codegen-units=256, `cargo build --locked --offline ... -p integration --bin integration --features warp/gui`: exit 0, Cargo 15m 58s, supervised elapsed 970.51s. Actual warp rustc `--crate-type lib`, no `--test`. Full exact command/compiler output `/tmp/ctrl-y-integration-build.log`.
- Existing `test_home_key_should_not_appear_in_input`: both bootstrap/Home-input assertions succeeded, natural runner termination (numeric direct-launch exit not separately retained). Existing `test_undo_redo`: all six assertions/steps succeeded, captured exit 0 in 3.74s. Logs `/tmp/ctrl-y-integration-home.log` and `/tmp/ctrl-y-integration-undo.log`. Real Xvfb/Vulkan llvmpipe, actual `/usr/bin/zsh` 5.9 verified. Live synthetic-test screenshot inspected at `/tmp/ctrl-y-integration-readiness.png`; not logged-out manual proof.
- Exact outer `cargo nextest run --offline --config 'profile.dev.package.warp.incremental=false' --config 'profile.dev.package.warp.codegen-units=256' --cargo-profile dev -p integration --test integration --features warp/gui -E 'test(test_home_key_should_not_appear_in_input)' --test-threads 1` with jobs=1/debug=0, real-display Vulkan and WARP_SHELL_PATH=/usr/bin/zsh was stopped by the authorized disk guard after 811.11s: `INTEGRATION_NEXTEST_EXIT=-15 ... STOP_REASON=DISK_GUARD: less than 1 GiB free`. Full log `/tmp/ctrl-y-integration-nextest.log`. No test executed under nextest; do not claim full runner/harness readiness. Normal warp library only, no app-lib-test compile.
- Resource samples `/tmp/ctrl-y-integration-resources.log`: build RAM/swap peaks ~6.60/2.06 GiB; outer-harness ~6.60/2.29 GiB. No new OOM (kills remain 4). Disk fell from ~9.25 GiB before build to ~983.66 MiB final; no cache/tree deletion authorized or performed. Need more disk or explicitly approved scoped cleanup before further builds/outer-harness retry. Owned test/WM/Xvfb processes stopped in proper order.
- Full concise integration report with exact commands, results, approved synthetic-user boundary, resources and intentional paths: `/tmp/ctrl-y-integration-readiness.md`. Earlier app-lib-test OOM remains unresolved; future Clippy/all-targets/tests/full-presubmit constraints remain possible blockers, not bypassed or claimed passing. No regression/fix code before mission approval. Branch/source still pristine at verified `f411fbc20e6283a2abcdd1ed64bf5b67df864f82`.

- **Latest corrected/effective nonincremental attempt: BLOCKED**, exit **101** after **394.84 seconds (6m 34.84s)**. Actual rustc flags validated within the opening seconds: `RUSTC_FLAGS_VALIDATED=True INCREMENTAL_PRESENT=False CODEGEN_UNITS_256=True DEBUGINFO_PRESENT=False`. Observed compiler command has `-C codegen-units=256`, no `-C incremental`, and `-C strip=debuginfo`.
  ```sh
  cd /home/factory-user/warp-stanford
  . /home/factory-user/.cargo/env
  CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0 timeout --signal=TERM --kill-after=30s 35m cargo nextest run --offline --config 'profile.dev.package.warp.incremental=false' --config 'profile.dev.package.warp.codegen-units=256' --cargo-profile dev --features gui -p warp --lib -E 'test(test_home_end_keybinding_resolution)' --test-threads 1 -v
  ```
- Complete command/compiler/test-build output: `/tmp/ctrl-y-readiness-effective-nonincremental.log`. The actual rustc command was captured directly from the owned compiler process and retained in full. Exact outcome: `error: could not compile warp (lib test)`; `(signal: 9, SIGKILL: kill)`; child Cargo exited 101 with both `--config` overrides present. `EFFECTIVE_NONINCREMENTAL_EXIT=101 ELAPSED_SECONDS=394.84 RUSTC_FLAGS_VALIDATED=True STOP_REASON=None`. The existing test never executed, so no test pass. No timeout/disk-guard stop and no linker diagnostic.
- Only `warp` compiled; all dependencies were reused. GUI stayed stopped; same target tree, features/default dependencies and linker. One corrected attempt only; stopped after OOM with no retry or further tuning.
- Effective-attempt resource log: `/tmp/ctrl-y-readiness-effective-nonincremental-resources.log`. Highest sampled cgroup RAM 7,091,675,136 bytes (~6.60 GiB), swap 4,109,385,728 bytes (~3.83 GiB), simultaneous combined 11,200,946,176 bytes (~10.43 GiB). OOM kills 3 → 4; OOM events 22 → 23. Free disk before 9,948,700,672 bytes; minimum/final 9,944,928,256 bytes (~9.26 GiB), safely above guard. Cgroup CPU delta 320,838,946 microseconds (~320.84 CPU seconds). After compiler termination: RAM 178,425,856 bytes, swap 145,854,464 bytes. Managed wrapper PID 88139 and session 88143 finished.
- **Concrete user blocker:** even verified nonincremental app-lib test compilation cannot fit within the current ~6.60 GiB RAM/~3.89 GiB swap cgroup. A higher-memory environment or separately approved validation alternative is needed; no executable-plan readiness/test pass claimed. Branch remains clean at `f411fbc20e6283a2abcdd1ed64bf5b67df864f82`; no source/test/manifest/config-file edits, cache cleanup, cgroup mutation, commits, pushes or login.
- Latest intentional writes: created `/tmp/ctrl-y-readiness-effective-nonincremental.log` and `/tmp/ctrl-y-readiness-effective-nonincremental-resources.log`; updated `/tmp/ctrl-y-validation-readiness.md`. Managed output: `/tmp/droid-bg-1792217400687-f2877ff8-4a5f-4a1f-a58e-e8074276c7ac.out`. Cargo updated generated `/home/factory-user/warp-stanford/target/debug/` and `/home/factory-user/.cargo/.global-cache`.

- **Earlier ineffective flag-placement attempt (history): BLOCKED**, exit 101 after **723.01 seconds (12m 03.01s)**. Ran exactly once with GUI stopped; no retries, linker changes, source/config edits, cache deletion, login, commit or push.
  ```sh
  cd /home/factory-user/warp-stanford
  . /home/factory-user/.cargo/env
  CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0 timeout --signal=TERM --kill-after=30s 35m cargo --offline --config 'profile.dev.package.warp.incremental=false' --config 'profile.dev.package.warp.codegen-units=256' nextest run --cargo-profile dev --features gui -p warp --lib -E 'test(test_home_end_keybinding_resolution)' --test-threads 1
  ```
- Complete output: `/tmp/ctrl-y-readiness-nonincremental.log`. Exact error: `error: could not compile warp (lib test)`; rustc terminated `(signal: 9, SIGKILL: kill)`; child Cargo exited 101. `NONINCREMENTAL_EXIT=101 ELAPSED_SECONDS=723.01 DISK_GUARD_STOP=False`. Neither timeout nor disk guard triggered. The existing test never executed; no test pass.
- **Override propagation caveat:** despite the exact requested command, the emitted rustc invocation STILL contains `-C incremental=/home/factory-user/warp-stanford/target/debug/incremental`, contains no explicit `-C codegen-units=256`, and has `-C strip=debuginfo`. The child Cargo invocation printed by nextest contains neither `--config` override. Therefore this run does NOT establish the memory behavior of truly nonincremental compilation; the requested package overrides were not reflected in the actual compiler command. Stopped as instructed rather than trying a corrected argument placement or any additional build.
- Only `Compiling warp v0.1.0 (/home/factory-user/warp-stanford/app)` appeared: dependencies were reused, not rebuilt. Existing `/home/factory-user/warp-stanford/target/debug/` reused; no feature/default-dependency/linker change.
- Resource samples: `/tmp/ctrl-y-readiness-nonincremental-resources.log` (10-second interval). Highest sampled RAM 7,091,675,136 bytes (~6.60 GiB); swap 4,169,969,664 bytes (~3.88 GiB); simultaneous RAM+swap 11,261,222,912 bytes (~10.49 GiB). Cgroup OOM kills increased 2 → 3 and OOM events 21 → 22. Free disk before 10,009,690,112 bytes; minimum/final 9,959,383,040 bytes (~9.28 GiB), safely above 1 GiB stop threshold. Before RAM/swap 580,059,136/11,431,936 bytes; after 271,810,560/32,649,216 bytes. Cgroup CPU delta 464,687,842 microseconds (~464.69 CPU seconds).
- Managed wrapper PID 85805 and child process group 85809 finished. GUI remains stopped. Branch `fix/11743-ctrl-y-yank` stays clean at `f411fbc20e6283a2abcdd1ed64bf5b67df864f82`. Mission approval/implementation/failing regression remain deferred.
- Latest intentional writes: `/tmp/ctrl-y-readiness-nonincremental.log`, `/tmp/ctrl-y-readiness-nonincremental-resources.log`, and summary update to `/tmp/ctrl-y-validation-readiness.md`. Managed output log: `/tmp/droid-bg-1792216557545-21d61ac8-07d4-4d74-b2b4-d0363d392e39.out`. Cargo updated generated `/home/factory-user/warp-stanford/target/debug/` and cache metadata `/home/factory-user/.cargo/.global-cache`; no generated-file enumeration added.

## Base
- Repository: `/home/factory-user/warp-stanford`.
- Ran ONLY `git fetch stanford master` for remote refresh; exit 0. Fetch emitted a nonfatal redirect warning to `https://github.com/warpdotdev/warp-stanford.git/`.
- `FETCH_HEAD`, local `stanford-master`, initial `HEAD`, and final `HEAD` all equal `f411fbc20e6283a2abcdd1ed64bf5b67df864f82`. No ambiguity. Did not use `origin/master` or local `master`.
- Created previously nonexistent `fix/11743-ctrl-y-yank` from `stanford-master`; no existing branch overwritten.
- Freshly read AGENTS, CONTRIBUTING, dependency readiness report, rust-unit-tests, gui-integration-test, gui-reproduce-bug-report-local and its installed parent reproduce-bug-report. Explicit local-only source-build instructions override generic release/cloud defaults.
- Inspected and patched ONLY the two installer-created hashes in `/home/factory-user/warp-stanford/skills-lock.json`: research restored to `cef604c7c50f8c6a47cbdbc01fe2e9af7c87c345a275337e0a697b049dbc7669`; skill-doctor restored to `30931b68b6fe24705073e0f2a720df286974e9dd097e837e099372e85764a878`. Installed skills retained. Final tracked working tree clean; sources, tests, manifests and lockfiles unchanged from baseline.

## Build commands and results
- Confirmed `/home/factory-user/warp-stanford/script/run` defaults to `FEATURES=gui`, detects no `warp-channel-config` on PATH, and on Linux invokes `cargo run --bin warp-oss --features gui`. Baseline build has exact target/feature parity.
- From repository:
  ```sh
  . /home/factory-user/.cargo/env
  export CARGO_BUILD_JOBS=2 CARGO_PROFILE_DEV_DEBUG=line-tables-only
  cargo build --bin warp-oss --features gui
  ```
- PASS: exit 0, Cargo elapsed `16m 09s`, timed wall elapsed 971 seconds. Full log: `/tmp/ctrl-y-baseline-build.log`. Real binary: `/home/factory-user/warp-stanford/target/debug/warp-oss`.
- Initial timing-wrapper preflight failed with `bash: line 1: /usr/bin/time: No such file or directory` (exit 127), before Cargo ran. Preserved that line in the same full log and used date-based timing; no install/source workaround. Actual GUI build ran once and succeeded. No GUI-build SIGKILL, no GUI-build retry or `/tmp/ctrl-y-baseline-build-retry.log`.
- Existing narrow test source: `/home/factory-user/warp-stanford/app/src/editor/view/mod_tests.rs:2954`.
  ```sh
  . /home/factory-user/.cargo/env
  export CARGO_BUILD_JOBS=2 CARGO_PROFILE_DEV_DEBUG=line-tables-only
  cargo nextest list -p warp --lib --features gui --cargo-profile dev \
    -E 'test(test_home_end_keybinding_resolution)'
  ```
- BLOCKED: exit 101 after 585 seconds. Exact relevant diagnostics:
  ```text
  error: could not compile `warp` (lib test)
  process didn't exit successfully: ... rustc --crate-name warp ... --test ... (signal: 9, SIGKILL: kill)
  error: command `.../cargo '--color=auto' test --no-run --message-format json-render-diagnostics --package warp --lib --features gui --profile dev` exited with code 101
  NEXTEST_LIST_EXIT=101 ELAPSED_SECONDS=585
  ```
  Full unabridged rustc invocation/error: `/tmp/ctrl-y-readiness-nextest-list.log:107-112`.
- Initial listing reused the same dev profile and target directory, but its app-lib test compiler was OOM-killed. The user subsequently explicitly authorized the single-job/debug=0 fallback below.
- Authorized fallback attempted the actual existing narrow test (not just listing), with all GUI stopped and the existing target directory reused:
  ```sh
  cd /home/factory-user/warp-stanford
  . /home/factory-user/.cargo/env
  CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0 cargo nextest run -p warp --lib --features gui --cargo-profile dev -E 'test(test_home_end_keybinding_resolution)' --test-threads 1
  ```
- **FALLBACK BLOCKED:** exit 101 after 1638.85 seconds (27m 18.85s). Exact relevant diagnostics:
  ```text
  error: could not compile `warp` (lib test)
  process didn't exit successfully: ... rustc --crate-name warp ... --test ... (signal: 9, SIGKILL: kill)
  error: command `/home/factory-user/.rustup/toolchains/1.92.0-x86_64-unknown-linux-gnu/bin/cargo '--color=auto' test --no-run --message-format json-render-diagnostics --package warp --lib --features gui --profile dev` exited with code 101
  FALLBACK_EXIT=101 ELAPSED_SECONDS=1638.85 DISK_GUARD_STOP=False
  ```
  Complete output, including full rustc invocation: `/tmp/ctrl-y-readiness-test-fallback.log` (error at lines 1081–1087). The test runner could not start because its binary did not compile; the test has NOT passed or executed.
- Fallback resource log: `/tmp/ctrl-y-readiness-test-fallback-resources.log`. The compiler again exhausted cgroup memory/swap and incurred one additional OOM kill. Disk remained sufficient (~10.02 GB free); the 1 GiB disk safety guard was not triggered. No retry loop, cleanup, cgroup change, GUI rerun, or further compilation was performed after this failure. Executable-plan readiness remains blocked on obtaining a passing existing test.
- No regression test, bug fix, source edits, formatter, Clippy, full presubmit, commits, push, PR, credentials, account creation or login.

## GUI and capture checks
- Follow-up fallback compilation did not rerun GUI; all previously owned GUI/display processes remained stopped throughout.
- PASS: real native Linux OSS GUI visually observed under managed `Xvfb :99 -screen 0 1600x1000x24 -nolisten tcp` and Openbox. Display was free before creation; no unrelated process killed.
- Isolated fresh `HOME=/tmp/ctrl-y-readiness-home.PByhuN` and `XDG_RUNTIME_DIR=/tmp/ctrl-y-readiness-runtime.RHYD6n`, both mode 700. No existing app state copied.
- Exact launch environment and command from repository:
  ```sh
  . /home/factory-user/.cargo/env
  export RUSTUP_HOME=/home/factory-user/.rustup CARGO_HOME=/home/factory-user/.cargo
  export HOME=/tmp/ctrl-y-readiness-home.PByhuN
  export XDG_RUNTIME_DIR=/tmp/ctrl-y-readiness-runtime.RHYD6n DISPLAY=:99
  export SHELL=/usr/bin/zsh WARP_SKIP_COMMON_SKILLS_INSTALL=1 WARP_SKIP_SUDO_PROMPT=1
  export CARGO_BUILD_JOBS=2 CARGO_PROFILE_DEV_DEBUG=line-tables-only WGPU_BACKEND=vulkan
  ./script/run
  ```
- Script reused dev build in 2.48s and launched `target/debug/warp-oss`. Internal channel installer correctly reported no SSH access and skipped; no internal package installed.
- Vulkan PASS. Original application log now rotated to `/tmp/ctrl-y-readiness-home.PByhuN/.local/state/warp-oss/warp-oss.log.old.0:23-32` identifies `Backends(VULKAN)`, CPU llvmpipe LLVM 20.1.2, Mesa 25.2.8, and `Using Vulkan Cpu (llvmpipe (LLVM 20.1.2, 256 bits)) for rendering new window.` Successful visible rendering means GL fallback was not needed and was NOT attempted.
- Login-free path exercised: Get started → accept default keybindings → accept default theme → Skip for now → confirm Skip for now. Terminal usable; remained logged out. Settings Account showed Sign up rather than authenticated account details.
- Used real xdotool typing, not programmatic app events:
  - `printf 'readiness-ok\n'` + Return; screenshot visibly shows `readiness-ok` output and next prompt.
  - Ctrl+, opened Settings; clicked Keyboard shortcuts. Visible `Configure keyboard shortcuts` and action/keybinding list; no settings changed.
  - Clicked the terminal session to return to prompt.
  - During recording, typed `printf 'capture-ok\n'` + Return; extracted video frame visibly shows `capture-ok` and returned prompt.
- Screenshot PASS: `/tmp/ctrl-y-readiness-baseline.png` (1600x1000) opened and visually inspected. Settings proof `/tmp/ctrl-y-readiness-keybindings.png` inspected. Final prompt `/tmp/ctrl-y-readiness-final-prompt.png`.
- Silent capture PASS:
  ```sh
  ffmpeg -hide_banner -loglevel warning -f x11grab -framerate 10 \
    -video_size 1600x1000 -i :99.0 -t 6 -an -c:v libx264 \
    -preset ultrafast -pix_fmt yuv420p /tmp/ctrl-y-readiness-capture.mp4
  ```
  ffprobe confirms H.264, 1600x1000, 60 frames, 6.000000 seconds, 114998 bytes, video-only/no audio. Extracted frame at second 4 to `/tmp/ctrl-y-readiness-capture-frame.png` and visually inspected. Nonfatal FFmpeg warning: `Stream #0: not enough frames to estimate rate; consider increasing probesize`.
- This is readiness evidence ONLY, not issue #11743 reproduction or M1 bug proof; Ctrl-Y was not tested and no fix selected.
- Important shell caveat: although launch SHELL was `/usr/bin/zsh` exactly as requested, app chose OS-default `/bin/bash` (log.old.0:60), version 5.2.21. Native input proof is Bash, not Zsh. No shell settings modified. A Zsh-specific mission must explicitly select Zsh and verify actual child shell.
- All processes started with managed fireAndForget, never shell `&`. Managed launch PIDs: build 3630, sampler 3849, Xvfb 36076 (actual Xvfb 36078), Openbox 36092 (actual 36094), app wrapper 36095 (script 36097, app 36113), capture 36821, nextest listing 37081. Build, sampler, capture and nextest finished; GUI/display explicitly stopped; final ps confirms none of these remain.
- Shutdown caveat: TERM to app triggered a recovery relaunch; teardown of owned Xvfb then caused an X11-connection shutdown panic in that recovery instance. Current `/tmp/ctrl-y-readiness-home.PByhuN/.local/state/warp-oss/warp-oss.log:33`: `Failed to translate window coordinates: Connection(IoError(Custom { kind: Other, error: UnknownError }))`. Original successful session log is `.old.0`. No app/display process remains. This happened after successful evidence capture, not during the readiness interaction. Prefer GUI Quit and wait for all recovery processes before future display teardown.
- Nonblocking desktop-service messages: no Secret Service provider/D-Bus session; org.freedesktop.Application service unavailable; Wayland clipboard fallback to X11. These did not prevent logged-out input/Settings/Vulkan capture. Do not infer credential storage or session-bus coverage.

## Resource measurements
- Serial GUI validators maximum = **1**. Never overlap GUI validators or nextest compile with the live GUI.
- Effective cgroup `/system.slice/factoryd.service`: RAM limit 7,091,675,136 bytes (~6.60 GiB), swap limit 4,171,575,296 bytes (~3.89 GiB). Host has 16 GiB swap, but effective process swap remains capped. No limits/swap/system configuration changed.
- Initial host memory: total 8,343,150,592 bytes, available 7,665,508,352; swap used 0. Root free 36,487,294,976 bytes. 94 OS processes in initial snapshot; cgroup memory current 1,897,238,528 bytes; initial OOM kills 0.
- Build sampled memory/CPU/process/disk every 30 seconds: `/tmp/ctrl-y-readiness-resources.log`. Summary below is computed from samples.
- Build peak cgroup memory: 7,091,900,416 bytes; highest sampled swap: 3,721,371,648 bytes; sampled OS process count range 95–104. Build itself had OOM kills 0.
- Before GUI stop: app RSS 1,164,292 KiB, app lifetime CPU 38.9%; Xvfb RSS 79,908 KiB, Openbox RSS 20,416 KiB; cgroup memory 6,941,851,648 bytes (includes build cache), swap 23,592,960 bytes; 108 OS processes. GUI snapshot CPU usage counter 1,678,658,475 microseconds (cumulative cgroup usage, not instantaneous percentage).
- Optional test compile reached memory ~7.09 GB plus the entire 4,171,575,296-byte cgroup swap allowance; OOM events 14 and OOM kills 1 after rustc termination.
- Before the authorized fallback: cgroup memory 577,720,320 bytes, swap 20,303,872 bytes, 90 OS processes, disk free 17,938,341,888 bytes, OOM kills 1.
- Authorized fallback sampled every 20 seconds: maximum observed memory 7,091,675,136 bytes and swap 4,171,575,296 bytes, hitting both effective limits. After failure: memory 475,611,136 bytes, swap 23,228,416 bytes, 95 OS processes (snapshot includes monitoring), disk free 10,021,892,096 bytes. Disk decreased 7,916,449,792 bytes (~7.37 GiB). Cumulative OOM kills rose 1 → 2; OOM events 14 → 21. Cgroup CPU usage increased 1,435,421,643 microseconds (~1435.42 CPU seconds). Full samples: `/tmp/ctrl-y-readiness-test-fallback-resources.log`.
- Managed fallback wrapper PID 49275 and compiler process group 49279 finished; final process check shows no fallback wrapper remains. GUI remained stopped. No artifacts/caches deleted and no system limits changed.

## Blockers
- **Baseline GUI build, logged-out native interaction, Vulkan rendering, Settings keybindings reachability, screenshot and silent capture are verified.**
- **Automated test readiness remains BLOCKED after the explicitly authorized fallback**: actual `cargo nextest run` with jobs=1/debug=0 still lost the app-lib test compiler to `(signal: 9, SIGKILL: kill)`, exit 101 after 1638.85 seconds. One additional cgroup OOM kill confirms memory exhaustion. The test never executed. No further retry is authorized; a higher-memory execution environment or a separately approved alternative validation strategy is required before a passing existing test/executable plan can be claimed.
- Zsh behavior remains unverified because app selected `/bin/bash` despite requested launch SHELL. Future shell-specific validation must inspect the actual child shell.
- Shutdown recovery/X11 panic is isolated to stopping the display after TERM; future lifecycle should use normal GUI Quit and wait before stopping Xvfb.
- M1 reproduction/failing regression, implementation and final verification intentionally await mission approval. No issue-specific conclusion.

## Files changed
- Follow-up intentional writes only: created `/tmp/ctrl-y-readiness-test-fallback.log` and `/tmp/ctrl-y-readiness-test-fallback-resources.log`; updated the summary sections of `/tmp/ctrl-y-validation-readiness.md`. Managed stdout: `/tmp/droid-bg-1792204440528-1c184642-c38e-4b2f-8ef2-75d182bb2c49.out`. Cargo updated its existing generated tree `/home/factory-user/warp-stanford/target/debug/` and cache metadata `/home/factory-user/.cargo/.global-cache`; generated files are not individually re-enumerated for the fallback. The historical inventory below is unchanged and predates this fallback.
- Tracked file touched then reconciled exactly: `/home/factory-user/warp-stanford/skills-lock.json`; final diff empty. All source/tests/Cargo manifests/lock unchanged. Existing installed skills retained, not rewritten.
- Branch/fetch metadata changed only locally. No external write/push/login. Cargo builds and app write generated local state as listed below.
- Direct task artifacts (exact paths):
  - `/tmp/ctrl-y-baseline-build.log`
  - `/tmp/ctrl-y-readiness-app-vulkan.log`
  - `/tmp/ctrl-y-readiness-baseline.png`
  - `/tmp/ctrl-y-readiness-capture-frame.png`
  - `/tmp/ctrl-y-readiness-capture.mp4`
  - `/tmp/ctrl-y-readiness-ffmpeg.log`
  - `/tmp/ctrl-y-readiness-final-prompt.png`
  - `/tmp/ctrl-y-readiness-initial.png`
  - `/tmp/ctrl-y-readiness-keybindings.png`
  - `/tmp/ctrl-y-readiness-nextest-list.log`
