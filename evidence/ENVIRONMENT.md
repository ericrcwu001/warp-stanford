# Environment and baseline (M0)

Issue: warp-stanford #12 / warpdotdev/warp#11743 (Ctrl-Y deletes left instead of yanking on Linux/Windows).

Most facts below were measured during the pre-mission readiness runs on 2026-10-17 between 01:54 and 07:12 UTC. Those runs are **reused, not repeated**. Each one names the retained log it comes from. Values marked "re-checked" were confirmed read-only at 08:42 UTC by the M0 worker.

## Source identity

| Item | Value | Source |
| --- | --- | --- |
| Repository | `/home/factory-user/warp-stanford` | re-checked |
| Work branch | `fix/11743-ctrl-y-yank`, created from local `stanford-master` (never local/origin `master`) | `logs/readiness/validation-readiness-summary-first160.md` § Base |
| Original base SHA | `f411fbc20e6283a2abcdd1ed64bf5b67df864f82` | re-checked: `git rev-parse HEAD stanford-master stanford/master` all print this SHA |
| Fetched Stanford target | `git fetch stanford master` (exit 0). `FETCH_HEAD` = `stanford/master` = base | same § Base |
| Remotes | `origin` = `https://github.com/ericrcwu001/warp-stanford.git` (student fork). `stanford` = `https://github.com/warpdotdev/warp-stanford.git`, used for fetch only; it has a configured push URL, but nothing is ever pushed to it | re-checked `git remote -v` |
| Tracked tree | clean (`git status --porcelain` empty, `git diff --stat` empty) | re-checked |
| Product code changes | none | re-checked |

## Host, toolchain and renderer

| Item | Value | Source |
| --- | --- | --- |
| OS | Ubuntu 24.04.5 LTS | re-checked `/etc/os-release` |
| Kernel | Linux 6.1.158+ x86_64 | re-checked `uname -srm` |
| CPUs | 4 | re-checked `nproc` |
| Rust | rustc 1.92.0 (ded5c06cf 2025-12-08), cargo 1.92.0; rustfmt 1.8.0, Clippy 0.1.92 (matches `rust-toolchain.toml`) | re-checked; `logs/readiness/ctrl-y-dependency-readiness.md` |
| nextest | cargo-nextest 0.9.148 | re-checked |
| Display stack | Xvfb 21.1.12 (package version), Openbox 3.6.1, xdotool 3.20160805.1 | dependency readiness |
| Renderer | Software Vulkan: Mesa 25.2.8 llvmpipe (LLVM 20.1.2). The app log prints `Using Vulkan Cpu (llvmpipe (LLVM 20.1.2, 256 bits))`. The GL fallback was never needed and never attempted | `logs/readiness/manual-app-session.warp-oss.log.old.0:23-32`; `ctrl-y-vulkaninfo.log`, `ctrl-y-glxinfo.log` |
| Media | ffmpeg 6.1.1 with libx264 and libass (H.264 encode actually exercised), ImageMagick 6.9.12-98 | dependency readiness |
| Shells installed | Zsh 5.9, Bash 5.2.21 | re-checked |

### Actual shell (observed, not assumed from `SHELL`)

- **The manual normal `warp-oss` baseline session ran Bash.** It was launched with `SHELL=/usr/bin/zsh`, but the app log shows `Starting shell /bin/bash` and `Successfully spawned child bash process` (`manual-app-session.warp-oss.log.old.0:60,63`). `00-baseline.png` is therefore a Bash session.
- **Automated integration runs ran Zsh 5.9.** These runs set `WARP_SHELL_PATH=/usr/bin/zsh`, and their logs show `Starting shell /usr/bin/zsh` with Zsh 5.9 bootstrapped (`ctrl-y-integration-home.log`, `ctrl-y-integration-undo.log`).
- The manifest's `launch_manual` command now also sets `WARP_SHELL_PATH=/usr/bin/zsh`. M1 manual runs must read the actual shell from their own app log; it is not yet verified for the manual path.

## Resources and constraints

| Item | Value | Source |
| --- | --- | --- |
| Host RAM | 8,343,150,592 bytes (~7.77 GiB) | re-checked `free -b` |
| Host swap | `/swapfile`, 17,179,865,088 bytes active swap (16 GiB). It was resized from 6 GiB with user approval; fstab was not changed | re-checked `swapon --show`; dependency readiness § Setup |
| Process cgroup | `/system.slice/factoryd.service` | re-checked `/proc/self/cgroup` |
| **Effective RAM limit** | `memory.max` = 7,091,675,136 bytes (~6.60 GiB) | re-checked |
| **Effective swap limit** | `memory.swap.max` = 4,171,575,296 bytes (~3.89 GiB). **The 16 GiB host swap does not lift this cap** | re-checked |
| OOM counters now | `oom 23`, `oom_kill 4`. All four kills come from the app lib-test compile attempts below | re-checked `memory.events` |
| Disk | 16,891,998,208 bytes (~15.7 GiB) free on `/` | re-checked `df -B1` |
| Build exports | `~/.bashrc` lines 5–6: `export CARGO_BUILD_JOBS=2`, `export CARGO_PROFILE_DEV_DEBUG=line-tables-only` (requested initial values). Heavy builds after the OOMs pass explicit `CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0` plus `--config 'profile.dev.package.warp.incremental=false' --config 'profile.dev.package.warp.codegen-units=256'` on the command line. These are command overrides, not repository profile changes | re-checked `grep`; `services.yaml` |

## Setup commands (readiness, reused)

All from `logs/readiness/ctrl-y-dependency-readiness.md` and `validation-readiness-summary-first160.md`:

1. Shared skills: `./script/resolve_common_skills install_common_skills -- --repo-root "$PWD" --project --if-needed --non-interactive` exited 0 and installed 28 skills (`ctrl-y-skills-install.log`). It rewrote two hashes in tracked `skills-lock.json` (research, skill-doctor). Only those two hashes were restored to their original values, so the tracked tree is clean again. Installed skills were kept.
2. Native packages: `sudo -n apt-get install -y --no-install-recommends clang vim` installed 7 new packages, with no upgrades or removals (`ctrl-y-apt-install.log`).
3. Swap: `sudo -n swapoff /swapfile && sudo -n fallocate -l 16G /swapfile && sudo -n chmod 600 /swapfile && sudo -n mkswap /swapfile && sudo -n swapon /swapfile`.
4. Cargo dependencies: `cargo fetch --locked` then `cargo fetch --locked --offline`, both exit 0 (`ctrl-y-cargo-fetch.log` is empty on success). `Cargo.toml`/`Cargo.lock` unchanged.
5. `change-keybinding` skill: not present after installation, and no guidance from it is invented.

## Build and test results (reused; failures kept)

| Command (from repo, after `. ~/.cargo/env`) | Result | Log |
| --- | --- | --- |
| `CARGO_BUILD_JOBS=2 CARGO_PROFILE_DEV_DEBUG=line-tables-only cargo build --bin warp-oss --features gui` | **PASS**, exit 0, `Finished dev ... in 16m 09s`, wall time 971 s. The `/usr/bin/time` preflight first failed with exit 127 before Cargo started; date-based timing was used instead. Peak sampled cgroup RAM/swap ~6.60/3.47 GiB, OOM kills 0 | `logs/readiness/ctrl-y-baseline-build.log`, `ctrl-y-readiness-resources.log` |
| `cargo nextest list -p warp --lib --features gui --cargo-profile dev -E 'test(test_home_end_keybinding_resolution)'` (jobs 2) | **FAILED**, exit 101 after 585 s. `warp (lib test)` rustc killed by SIGKILL (OOM). The test never ran | `ctrl-y-readiness-nextest-list.log:107-112` |
| Same test, `nextest run`, `CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0` | **FAILED**, exit 101 after 1638.85 s, SIGKILL (OOM). The test never ran | `ctrl-y-readiness-test-fallback.log:1081-1087`, `...-resources.log` |
| Same with `--config` placed before `nextest` (nonincremental intended) | **FAILED**, exit 101 after 723.01 s, SIGKILL. The overrides did **not** reach rustc (`-C incremental` was still present), so this attempt does not test nonincremental compilation | `ctrl-y-readiness-nonincremental.log` |
| Same with `--config` after `nextest run` (overrides verified: no `-C incremental`, `-C codegen-units=256`) | **FAILED**, exit 101 after 394.84 s, SIGKILL; OOM kills went from 3 to 4. The test never ran | `ctrl-y-readiness-effective-nonincremental.log` |
| `cargo build --locked --offline <jobs1/debug0/nonincr256> -p integration --bin integration --features warp/gui` | **PASS**, exit 0, Cargo 15m 58s. warp was compiled as `--crate-type lib`, without `--test` | `ctrl-y-integration-build.log` |
| `WARP_INTEGRATION=1 target/debug/integration test_home_key_should_not_appear_in_input` (real Xvfb/Vulkan, Zsh) | All assertions passed. The numeric exit code was not retained | `ctrl-y-integration-home.log` |
| `target/debug/integration test_undo_redo` | **PASS**, exit 0, 3.74 s | `ctrl-y-integration-undo.log` |
| Outer `cargo nextest run ... -p integration --test integration --features warp/gui -E 'test(test_home_key_should_not_appear_in_input)'` (first attempt) | **BLOCKED** by the disk guard (<1 GiB free), exit -15 after 811.11 s. No test ran | `ctrl-y-integration-nextest.log` |
| Approved one-time deletion of `target/debug/incremental` only | Free space went from 1,020,641,280 to 18,121,129,984 bytes | `ctrl-y-integration-cleanup.log` |
| Same outer nextest, retry (the manifest `test` command) | **PASS**, exit 0: `1 passed, 337 skipped`, test 4.464 s, total 591.57 s. Peak RAM/swap ~6.60/2.14 GiB, no new OOM | `ctrl-y-integration-nextest-retry.log`, `...-resources.log` |

**No app unit (`warp --lib`) test has ever compiled or executed in this environment.** The approved alternative is the real GUI `integration` package. Clippy (`--all-targets --tests`), `./script/format` and `./script/presubmit` have not been run yet.

`target/debug/warp-oss` (mtime 2026-10-17 02:15:21 UTC, sha256 `28023d47…d721`) is the binary from the PASS build above. The source has not changed since that build, so M0 did not rebuild it.

## Baseline screenshot: `00-baseline.png`

- **Reused** byte-for-byte from the readiness capture `/tmp/ctrl-y-readiness-baseline.png` (sha256 `3c34c6338d7479e08d5f3f4786e54e200fa19ffc9cf371406a81ce7a051d1739`, PNG 1600x1000, 53,959 bytes). It was captured at about 02:18 UTC. M0 did not take a new screenshot.
- Display: owned `Xvfb :99 -screen 0 1600x1000x24 -nolisten tcp` with Openbox (`ctrl-y-readiness-xvfb.log`, `ctrl-y-readiness-openbox.log`).
- Fresh `HOME=/tmp/ctrl-y-readiness-home.PByhuN`, `XDG_RUNTIME_DIR=/tmp/ctrl-y-readiness-runtime.RHYD6n`, both mode 700. No app state, preferences or authentication was copied. `CARGO_HOME`/`RUSTUP_HOME` were set explicitly to the original locations.
- Launch: `./script/run` with `DISPLAY=:99 WGPU_BACKEND=vulkan SHELL=/usr/bin/zsh WARP_SKIP_COMMON_SKILLS_INSTALL=1 WARP_SKIP_SUDO_PROMPT=1`. It reused the dev build in 2.48 s and executed `target/debug/warp-oss` (normal OSS, not the integration fixture).
- Logged-out onboarding: Get started → default keybindings → default theme → Skip for now → confirm Skip. The app log records `LoginSlideAction::ShowSkipDialog` and then `ConfirmSkip` (`manual-app-session.warp-oss.log.old.0:42-43`). Settings → Account shows a **Sign up** button (`readiness-screenshots/ctrl-y-readiness-settings.png`).
- Usable input: `printf 'readiness-ok\n'` was typed with real xdotool and run with Return. The screenshot shows the command, the `readiness-ok` output and a fresh prompt below it. M0 re-inspected the image visually.
- Shell: Bash 5.2.21 (see above). Renderer: Vulkan llvmpipe.
- This screenshot is **not** synthetic integration evidence. The automated screenshot `readiness-screenshots/ctrl-y-integration-readiness.png` uses the stock synthetic authenticated test user, so it is not logged-out proof.
- Shutdown caveat: sending TERM to the app triggered crash-recovery relaunch, and stopping Xvfb then produced an X11 panic in that recovery instance (`manual-app-recovery-instance.warp-oss.log:33`). This happened after the capture. Future runs should quit through the GUI before stopping the display.

## Not covered

Native Windows, macOS, Wayland and real-GPU behavior are not verified. Readiness capture `/tmp/ctrl-y-readiness-capture.mp4` (10 fps) is readiness-only and is not bug evidence. Ctrl-Y was not exercised during readiness.
