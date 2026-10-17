# Factory Environment "warp-stanford" -> Setup script (global).
# Runs once from the home directory at build time, before the repository script.
# No secrets are available here, so it only installs tools.
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y

# Headless X display, input automation, capture, and captioning for the demo:
#   xvfb + openbox    virtual display and a window manager so Warp gets a real window
#   xdotool           scripted keystrokes, so before/after runs are identical
#   ffmpeg            x11grab recording + burning captions into the MP4
#   x11-apps imagemagick  still screenshots (xwd / import)
#   mesa-vulkan-drivers libgl1-mesa-dri  software Vulkan/GL (lavapipe/llvmpipe), no GPU needed
#   fonts-dejavu-core fonts-noto-color-emoji  so text and captions render
#   zsh               the reporter's shell
sudo apt-get install -y \
  xvfb openbox xdotool x11-utils x11-apps imagemagick ffmpeg \
  mesa-vulkan-drivers libgl1-mesa-dri mesa-utils vulkan-tools \
  dbus-x11 fonts-dejavu-core fonts-noto-color-emoji \
  zsh fish unzip jq curl git

# GitHub CLI for pushing the branch and reading issues (no PR creation; see mission).
if ! command -v gh >/dev/null; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -y && sudo apt-get install -y gh
fi

# ---- Repository (cloned here because Factory's repo chooser doesn't list the fork) ----
git clone --filter=blob:none --branch stanford-master https://github.com/ericrcwu001/warp-stanford.git "$HOME/warp-stanford"
cd "$HOME/warp-stanford"
git remote add stanford https://github.com/warpdotdev/warp-stanford.git
# Warp's scripts wrap sudo in a TTY prompt; this makes them non-interactive.
export WARP_SKIP_SUDO_PROMPT=1
export WARP_SKIP_COMMON_SKILLS_INSTALL=1

# Warp's install_rust only passes -y to rustup on GitHub Actions; install it non-interactively here.
# rust-toolchain.toml then pulls Rust 1.92 on first cargo use.
if ! command -v cargo >/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain none
fi
. "$HOME/.cargo/env"

# Build + runtime deps (apt packages, protoc, Rust 1.92 from rust-toolchain.toml, cargo build tools).
./script/linux/install_runtime_deps </dev/null

# Make cargo visible to the rest of this script and to future shells.
. "$HOME/.cargo/env"
grep -q '.cargo/env' "$HOME/.bashrc" || echo '. "$HOME/.cargo/env"' >> "$HOME/.bashrc"

# Test tooling: cargo-nextest and wgslfmt (used by presubmit). Skips gcloud from install_test_deps.
./script/install_cargo_test_deps </dev/null

# Shared Warp agent skills pinned in skills-lock.json, installed into .agents/skills
# (Factory droids read .agents/skills via its compatibility path).
./script/resolve_common_skills install_common_skills -- \
  --repo-root "$PWD" --project --if-needed --non-interactive </dev/null || \
  echo "common-skills install failed; mission will retry at runtime"

# Download crates only. Compiling Warp's `app` crate here gets OOM-killed on Factory's builder,
# so the mission compiles on the Droid Computer with reduced memory settings (see mission.md M0).
cargo fetch
