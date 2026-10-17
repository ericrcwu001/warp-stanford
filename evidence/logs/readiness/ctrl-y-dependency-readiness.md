# Dependency readiness
## Verified dependencies
| Dependency | Command | Result |
| --- | --- | --- |
| Repository instructions | Read `/home/factory-user/warp-stanford/AGENTS.md` and `CONTRIBUTING.md` | Read. Targeted tests, Clippy, then formatter; no full presubmit unless requested. No app compilation performed. |
| Shared skills | `cd /home/factory-user/warp-stanford && ./script/resolve_common_skills install_common_skills -- --repo-root "$PWD" --project --if-needed --non-interactive` | Exit 0; installed 28 shared skills, installer reports matches lock. Two skill hashes changed in tracked lock; see blockers. |
| Rust toolchain | `. /home/factory-user/.cargo/env; rustc --version; cargo --version; rustfmt --version; cargo clippy --version` from repository | Rust 1.92.0, Cargo 1.92.0, rustfmt 1.8.0-stable, Clippy 0.1.92; matches `rust-toolchain.toml`. |
| Test runner | `cargo nextest --version` | 0.9.148, x86_64-unknown-linux-gnu. |
| Real Cargo dependencies | `CARGO_BUILD_JOBS=2 CARGO_PROFILE_DEV_DEBUG=line-tables-only cargo fetch --locked` then `cargo fetch --locked --offline` from repository | Both exit 0; all locked dependencies available, not merely metadata. Cargo.toml/Cargo.lock unchanged. Fetch log empty on success; caches already warm. |
| Native compiler/linker | `gcc --version; clang --version; cmake --version; command -v make musl-gcc` | GCC 13.3.0; Clang 18.1.3 newly installed; CMake 3.28.3; build-essential, make, musl-tools installed. |
| Bindgen support | `dpkg-query -W libclang-dev; ls /usr/lib/llvm-18/lib/libclang.so*` | libclang-dev 18, shared library and builtin headers installed. |
| Protobuf compiler | `protoc --version` | `/usr/local/bin/protoc`, libprotoc 25.1. Apt protobuf-compiler absent but unnecessary. |
| Native libraries | `pkg-config --modversion openssl freetype2 expat libgit2 fontconfig alsa` | 3.0.13 / 26.1.20 / 2.6.1 / 1.7.2 / 2.15.0 / 1.2.11 respectively; freetype pkg-config API version differs from package 2.13.2. Headers installed. |
| Linux runtime libraries | `dpkg-query -W` against repository Linux runtime dependency list | locales, fontconfig, zlib1g, libx11-6, libxcb1, libxi6, libxcursor1, libxkbcommon-x11-0, libwayland-client0, libwayland-egl1, mesa-vulkan-drivers, libegl1, yaru-theme-icon installed. |
| Additional native tools | `dpkg-query -W` / `command -v` | python-is-python3, jq 1.7.1, brotli 1.1.0, clang-format 18, node, npm present. |
| Xvfb | `dpkg-query -W xvfb; xvfb-run -a -s '-screen 0 1280x800x24' env LIBGL_ALWAYS_SOFTWARE=1 glxinfo -B` | X server package 21.1.12; real temporary X display initialized, command exit 0. `Xvfb -version` is unsupported; use package version, not this flag. |
| Window manager/input | `openbox --version; xdotool --version; command -v xauth` | Openbox 3.6.1; xdotool 3.20160805.1; xauth present. Window manager/input app exercise left to GUI-readiness agent. |
| Software OpenGL | GLX command above | Mesa 25.2.8, llvmpipe LLVM 20.1.2; OpenGL 4.5 and GLES 3.2. Direct rendering yes, accelerated no. |
| Software Vulkan | `xvfb-run -a -s '-screen 0 1280x800x24' vulkaninfo --summary` | Exit 0; Mesa 25.2.8 CPU llvmpipe/lavapipe, device API 1.4.318, Vulkan instance 1.3.275. Nonfatal XDG_RUNTIME_DIR warning. |
| FFmpeg | `ffmpeg -version; ffmpeg -hide_banner -h encoder=libx264; ffmpeg -hide_banner -h filter=subtitles` | 6.1.1; libx264 encoder and libass subtitles filter present. |
| H.264 encoding execution | `ffmpeg -hide_banner -loglevel error -f lavfi -i color=c=black:s=320x240:r=1 -frames:v 1 -c:v libx264 -f null /dev/null` | Exit 0; actual encoded frame, not just advertised encoder. |
| Screenshot tools | `command -v import convert xwd; convert -version` | All present; ImageMagick 6.9.12-98. Actual screenshot capture left to GUI-readiness agent. |
| Shell/test tools | `zsh --version; dpkg-query -W fish shellcheck; /usr/bin/vim.basic --version` | Zsh 5.9, fish 3.7.0, shellcheck 0.9.0; Vim 9.1 newly installed. |
| Rust auxiliary tools | `cargo install --list; wgslfmt --help; diesel --version` | wgslfmt 0.1.0 pinned upstream tag 2025-06-28, commit 7e34f03c; Diesel CLI 2.3.14; cargo-binstall 1.18.1. Existing installations, not changed. wgslfmt has no --version option. |
| Sudo/swap permissions | `sudo -n true; sudo -n swapoff /swapfile; ...; sudo -n swapon /swapfile; swapon --show` | Noninteractive sudo and swap mutation permitted; authorized 16 GiB swapfile active. |

## Setup performed
- Resized existing, unused `/swapfile` from actual 6 GiB (not the approximate 5 GiB supplied) to 16 GiB using `sudo -n swapoff /swapfile && sudo -n fallocate -l 16G /swapfile && sudo -n chmod 600 /swapfile && sudo -n mkswap /swapfile && sudo -n swapon /swapfile`. No fstab changes.
- Added `export CARGO_BUILD_JOBS=2` and `export CARGO_PROFILE_DEV_DEBUG=line-tables-only` to `/home/factory-user/.bashrc`, before its noninteractive early return. Verified by explicitly sourcing in noninteractive bash. Every future build command must explicitly export these values; Execute processes do not inherit exports from earlier calls.
- Rust binaries are not in the initial Execute PATH: source `/home/factory-user/.cargo/env` in each repository build/check/fetch command.
- Ran the exact requested shared-skill installer once. It installed 28 directories (62 files) under `/home/factory-user/warp-stanford/.agents/skills/`; exact file inventory follows below.
- Installer changed `/home/factory-user/warp-stanford/skills-lock.json`: research hash `cef604c7c50f8c6a47cbdbc01fe2e9af7c87c345a275337e0a697b049dbc7669` → `09b957d374c102b3214f5ca934938772890da539fdd56c26e1912afbdb77b140`; skill-doctor hash `30931b68b6fe24705073e0f2a720df286974e9dd097e837e099372e85764a878` → `eae54bb2041744ff27c288e92a4805e9e1beef8ab8e9bd14c4950b8414246f80`. No deliberate skill or Rust dependency upgrade was requested or made outside installer behavior.
- Installed missing bounded native prerequisites with `sudo -n apt-get install -y --no-install-recommends clang vim`: 7 new packages, zero upgrades/removals, 12.9 MB downloaded, 55.4 MB installed. Packages: clang 1:18.0-59~exp2; clang-18 and llvm-18-linker-tools 1:18.1.3-1ubuntu1; libgpm2 1.20.7-11; libpython3.12t64 3.12.3-1ubuntu0.17; vim and vim-runtime 2:9.1.0016-1ubuntu7.20. Package-managed system files/alternatives/databases changed; exact package manifests are available with `dpkg-query -L` for those seven names. No arbitrary upstream installer used beyond the user's explicitly requested skill installer.
- No branch switch, commit, push, GitHub write, app launch/login, account creation, source implementation, application build, or cloud service used. No rustc SIGKILL occurred, since compilation was intentionally not started.
- Direct task artifacts written: `/tmp/ctrl-y-dependency-readiness.md`, `/tmp/ctrl-y-skills-install.log`, `/tmp/ctrl-y-cargo-fetch.log`, `/tmp/ctrl-y-apt-install.log`, `/tmp/ctrl-y-glxinfo.log`, `/tmp/ctrl-y-vulkaninfo.log`. Shared-skill installer also uses npm cache/logs under `/home/factory-user/.npm/`; Cargo fetch uses `/home/factory-user/.cargo/registry/` and `/home/factory-user/.cargo/git/`. Temporary Xvfb auth/socket/lock files are automatically cleaned up by xvfb-run; no persistent display process intentionally retained.

### Exact shared-skill files installed

62 files in 28 directories:

- `/home/factory-user/warp-stanford/.agents/skills/brandalf/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/check-impl-against-spec/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/complain/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/complain/evals/evals.json`
- `/home/factory-user/warp-stanford/.agents/skills/complain/submit.py`
- `/home/factory-user/warp-stanford/.agents/skills/council/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/create-pr/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/cross-critique/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/diagnose-ci-failures/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/fix-errors/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/implement-specs/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/migrate-to-factory/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/pr-walkthrough/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/pr-walkthrough/scripts/d3_canvas_runtime.py`
- `/home/factory-user/warp-stanford/.agents/skills/pr-walkthrough/scripts/validate_d3_canvas.py`
- `/home/factory-user/warp-stanford/.agents/skills/readout/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/readout/assets/code-pane.html`
- `/home/factory-user/warp-stanford/.agents/skills/readout/assets/template.html`
- `/home/factory-user/warp-stanford/.agents/skills/readout/references/doc-guide.md`
- `/home/factory-user/warp-stanford/.agents/skills/readout/scripts/embed_snippets.py`
- `/home/factory-user/warp-stanford/.agents/skills/readout/scripts/update_index.py`
- `/home/factory-user/warp-stanford/.agents/skills/reproduce-bug-report/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/research/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/resolve-merge-conflicts/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/resolve-merge-conflicts/scripts/extract_conflict_context.py`
- `/home/factory-user/warp-stanford/.agents/skills/respond-to-pr-comments-in-blocklist/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/review-pr/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/review-pr/scripts/resolve_spec_context.py`
- `/home/factory-user/warp-stanford/.agents/skills/review-pr/scripts/validate_review_json.py`
- `/home/factory-user/warp-stanford/.agents/skills/saga/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/saga/references/continuing-a-saga.md`
- `/home/factory-user/warp-stanford/.agents/skills/saga/references/saga-spec-template.md`
- `/home/factory-user/warp-stanford/.agents/skills/saga/references/validation-strategies.md`
- `/home/factory-user/warp-stanford/.agents/skills/scan-new-specs/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/assets/pierre-diffs.js`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/assets/warp-pixel-icon.svg`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/references/skill-improvements.md`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/references/supported-harnesses.md`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/scorers/code-quality.md`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/scorers/efficiency.md`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/scorers/procedure-compliance.md`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/scorers/verbosity.md`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/scripts/collect_sessions.py`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/scripts/render_report.py`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/scripts/test_collect_sessions.py`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/scripts/test_render_report.py`
- `/home/factory-user/warp-stanford/.agents/skills/skill-doctor/scripts/warp_decoder.py`
- `/home/factory-user/warp-stanford/.agents/skills/spec-driven-implementation/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/suggestion-box/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/suggestion-box/evals/evals.json`
- `/home/factory-user/warp-stanford/.agents/skills/suggestion-box/submit.py`
- `/home/factory-user/warp-stanford/.agents/skills/update-skill/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/update-skill/references/best-practices.md`
- `/home/factory-user/warp-stanford/.agents/skills/validate-changes-match-specs/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/write-feature-docs/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/write-pr-description/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/write-pr-description/evals/evals.json`
- `/home/factory-user/warp-stanford/.agents/skills/write-pr-description/references/plain-language.md`
- `/home/factory-user/warp-stanford/.agents/skills/write-pr-description/references/review-guide.md`
- `/home/factory-user/warp-stanford/.agents/skills/write-product-spec/SKILL.md`
- `/home/factory-user/warp-stanford/.agents/skills/write-tech-spec/SKILL.md`

## Resources
- Ubuntu 24.04.5 LTS, Linux 6.1.158+, x86_64, 4 CPUs.
- `/proc/meminfo`: MemTotal 8,147,608 kB (7.77 GiB). Approximately 7.2 GiB available at inspection.
- Actual process cgroup: `/system.slice/factoryd.service`. `memory.max=7091675136` (6.60 GiB), `memory.swap.max=4171575296` (3.89 GiB). Parent system.slice memory and swap limits are `max`. Do not confuse unrelated `/sys/fs/cgroup/user/memory.max=8208932864` with this process.
- `/swapfile` file size 17,179,869,184 bytes, mode 600, active usable swap approximately 16 GiB. **Effective process swap is still capped at 3.89 GiB by its cgroup.** Adding swap did not lift that constraint.
- Root disk 61,634,854,912 bytes total; final available 36,488,609,792 bytes (33.98 GiB). Initially ~45 GiB free; expansion consumed 10 GiB plus ~55 MB package setup. Cargo registry ~1.9 GiB and git cache ~203 MB already present. No target directory yet. No full GUI build disk-size guarantee is possible without compiling; avoid parallel build trees/profiles and monitor space.
- First build environment: `. /home/factory-user/.cargo/env; export CARGO_BUILD_JOBS=2 CARGO_PROFILE_DEV_DEBUG=line-tables-only`. If rustc is SIGKILLed, retry affected build with `CARGO_BUILD_JOBS=1 CARGO_PROFILE_DEV_DEBUG=0` and report it. This is a future requirement, not a retry already performed.

## Blockers
- Dependency fetch, Rust tools, native headers, software GL/Vulkan and media tooling pass. **Full application build and GUI validation remain deliberately untested**, and must not be represented as complete dependency-to-app readiness.
- Resource caveat: service cgroup still permits only ~6.60 GiB RAM plus ~3.89 GiB swap despite the 16 GiB host swapfile. Build success is not guaranteed under this hard limit; no cgroup limits were changed.
- Installer provenance/pinning caveat: the exact requested installer rewrote two tracked skill hashes. Current git status is only ` M skills-lock.json`; Cargo manifests/lock unchanged. Parent must decide whether to retain the setup-only hash drift or restore/reconcile it before a future implementation commit. Do not accidentally stage it as the ctrl-y fix.
- `XDG_RUNTIME_DIR` was unset/invalid during vulkaninfo; enumeration still succeeded. GUI-readiness agent should create a user-owned mode-700 runtime directory under `/tmp` and export XDG_RUNTIME_DIR for its display/app processes.
- Nonblocking inventory failures: `lsb_release` unavailable (used `/etc/os-release` instead); `Xvfb -version` exit 1 (unsupported flag; dpkg version verified); `wgslfmt --version` exit 1 (unsupported option; cargo install metadata/help verified); initial plain rustc/cargo lookup absent until sourcing cargo env; generic tool guard rejected `vim --version` despite version-only request (verified via `/usr/bin/vim.basic --version`). Apt emitted missing Vim manual-page alternative warnings; executable works.
- `change-keybinding` skill not installed/found after shared installation in repository `.agents`, `.warp`, or user `.agents`/`.warp`; not one of the 28 locked common skills. Report its absence rather than invent guidance. No dependency was bumped to obtain it.
- Optional cloud/gcloud/Oz setup intentionally excluded by mission scope.

## Required skill guidance
- Read/activated `/home/factory-user/warp-stanford/.agents/skills/rust-unit-tests/SKILL.md`: deterministic logic should have behavior/state regression tests in separate `*_tests.rs`; use nextest. Keybinding wiring/real PTY needs GUI integration rather than mocked unit-only proof.
- Read/activated `/home/factory-user/warp-stanford/.agents/skills/gui-integration-test/SKILL.md`: real app, isolated test HOME, generated shell rc/preferences. Register test implementation, module/export, runner entry, and nextest macro list. Poll named observable assertions; wait for shell bootstrap. Real display uses `WARPUI_USE_REAL_DISPLAY_IN_INTEGRATION_TESTS=1`. Run direct named integration binary first, then focused nextest. No tests run in this dependency-only assignment.
- Read/activated `/home/factory-user/warp-stanford/.agents/skills/gui-reproduce-bug-report-local/SKILL.md` and read newly installed `/home/factory-user/warp-stanford/.agents/skills/reproduce-bug-report/SKILL.md`: remain logged out, complete login-free onboarding before repro, baseline screenshot, exact reported version/channel where known, recording plus action/state manifest, exact issue steps first then at most two justified variants. Stop if login required. User's explicit local-only mission overrides generic parent skill's cloud-agent default.
- `change-keybinding`: absent, as noted above.
- `gui-ui-guidelines` not activated because no UI implementation occurred.
- AGENTS validation order overrides broader CONTRIBUTING presubmit wording: targeted tests → relevant Clippy/build checks → applicable mutating formatter once; no post-format re-test or full presubmit unless explicitly required.
