# Settings after Option A (fixed build)

Captured 2026-10-17 on the normal logged-out `warp-oss` built from HEAD `56f3560e9` (Option A). `launch.txt` records the binary SHA-256 `b845a05c…`, the three-file product diff and the app environment. The run used a fresh HOME `/tmp/warp-11743-manual-home.GY8ECt`, separate from the default demo HOME, on the same owned Xvfb `:99` 1600x1000 display with Openbox and Vulkan. Onboarding was logged out ("Skip for now"), followed by Settings > Keyboard shortcuts.

`settings-after.sh` is the exact xdotool sequence. Steps 00–03 repeat `../m2-settings-before/settings-before.sh` with the same searches and timing. The script then searches `Yank` again, clicks its row, and presses Escape. No Save was clicked, and `keybindings.yaml` was absent both before and after the run.

| File | Search text | Observed | Before (`../m2-settings-before/`) |
| --- | --- | --- | --- |
| `00-after-onboarding.png` | n/a | Fresh logged-out prompt after onboarding | same |
| `01-settings-search-yank.png` | `Yank` | A **Yank (Last Killed Text)** row bound to `Ctrl` `Y`, above the two fuzzy external-link matches | No Yank row; only the two fuzzy matches |
| `02-settings-search-delete-all-left.png` | `Delete all left` | One row, "Delete All Left", with **no shortcut** shown (Linux default removed) | "Delete All Left" bound to `Ctrl` `Y` |
| `03-settings-search-ctrl-y.png` | `ctrl y` | Only "Yank (Last Killed Text)" with `Ctrl` `Y` | Only "Delete All Left" with `Ctrl` `Y` |
| `04-yank-row-editor-open.png` | `Yank`, row clicked | The Yank row opens the normal binding editor: "Press new keyboard shortcut" with Clear, Default, Cancel and Save. Yank is editable | not applicable (row did not exist) |
| `05-yank-row-after-escape.png` | Escape pressed in the editor | The editor recorded `ESC` as an unsaved pending shortcut and shows the native warning "This shortcut conflicts with other keybinds". The window was then closed without saving, and no `keybindings.yaml` was written | not applicable |

Notes:
- `05` is an incidental capture. It shows the existing conflict warning for a pending `ESC` trigger, not an explicit Yank/Delete All Left collision. The required collision warning evidence comes from the separate M2 automated screenshots, which use the synthetic integration user.
- Only Linux was run. The Windows default removal and the unchanged macOS Cmd-Backspace default for Delete All Left were checked in source only; they were not verified at runtime.
