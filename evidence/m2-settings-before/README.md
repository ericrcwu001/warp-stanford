# Settings before Option A (unchanged product)

Captured 2026-10-17 before any product source change, on the normal logged-out `warp-oss` build
(`launch.txt` records the binary SHA-256, `repo_head` c1db7c276 and an empty product diff versus
base f411fbc20, excluding the test-only `crates/integration` change). Fresh HOME, owned Xvfb `:99`
1600x1000 with Openbox, logged-out onboarding ("Skip for now"), Settings > Keyboard shortcuts.
`settings-before.sh` is the exact xdotool sequence. No keybindings.yaml existed before or after.

| File | Search text | Observed |
| --- | --- | --- |
| `00-after-onboarding.png` | n/a | Fresh logged-out prompt after onboarding |
| `01-settings-search-yank.png` | `Yank` | No Yank row. Only fuzzy matches "Join Our Slack Community (Opens External Link)" and "View Privacy Policy (Opens External Link)" are listed |
| `02-settings-search-delete-all-left.png` | `Delete all left` | One row, "Delete All Left", bound to `Ctrl` `Y` |
| `03-settings-search-ctrl-y.png` | `ctrl y` | Only "Delete All Left" with `Ctrl` `Y`; fixed Yank is not listed |

The earlier M1 frame `m1-native/workaround/frames/01-workaround-04-delete-all-left-ctrl-y.png`
shows the same Delete All Left Ctrl-Y row from the M1 workaround run.
