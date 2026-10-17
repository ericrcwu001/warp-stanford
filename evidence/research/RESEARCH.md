# Prior-work research: Ctrl-Y / yank / Delete All Left / 11743

Run on 2026-10-17. All operations were read-only GETs. Nothing was posted, commented, labeled or reacted to on any repository.

## Method and tools

1. **GitHub search API** through the `gh` CLI, already authenticated as the student's account (`gh auth status`: logged in as `ericrcwu001` via `GH_TOKEN`; the token is not recorded). Each query was a `GET search/issues` call:
   `gh api -X GET search/issues -f q='repo:<repo> is:<issue|pr> "<term>"' -f per_page=100`
   Search without `is:open`/`is:closed` returns both open and closed items. Raw JSON responses are in `raw/` (one file per query) and empty `.err` files show that no call failed.
2. **Item reads**: `GET repos/<repo>/issues/<n>`, `…/comments`, `…/timeline`, and for PRs `pulls/<n>`, `pulls/<n>/reviews` and `pulls/<n>/comments` (review comments). Raw JSON is in `raw/items/`.
3. **WebSearch** with 4 free-text queries (results listed below).
4. **FetchUrl** of the two issue URLs named in the mission: both returned HTTP 200 and matched the API content.

## Query matrix (16 GitHub searches, all exit 0, `incomplete_results=false`)

| Repository | Term | Issues (total) | PRs (total) |
| --- | --- | --- | --- |
| warpdotdev/warp | `"ctrl-y"` | 21 | 5 |
| warpdotdev/warp | `"yank"` | 12 | 9 |
| warpdotdev/warp | `"delete all left"` | 4 | 3 |
| warpdotdev/warp | `"11743"` | 1 | 0 |
| warpdotdev/warp-stanford | `"ctrl-y"` | 1 | 0 |
| warpdotdev/warp-stanford | `"yank"` | 1 | 0 |
| warpdotdev/warp-stanford | `"delete all left"` | 1 | 0 |
| warpdotdev/warp-stanford | `"11743"` | 1 | 0 |

Every result title, state and URL was reviewed (complete lists in `raw/*.json`). Most `ctrl-y` and `yank` hits are unrelated: GitHub's tokenizer matches "ctrl", "y" or "history" in long bodies, or the hits concern Vim yank or the TUI.

## Relevant findings

### The issue itself

- **[warpdotdev/warp#11743](https://github.com/warpdotdev/warp/issues/11743)**, "ctrl + y does only "delete all left"". Open, created 2026-05-27 by `tlapik123` on Linux (Manjaro, zsh 5.9, `v0.2026.05.20.09.21.stable_03`). Labels: `bug, triaged, repro:high, os:linux, area:settings-keybindings, area:terminal-input, warp:auto-triage-review, warp:tracking`. The reporter's expectation: "At least warn a user about this in some way. Or let user change the internal "hard-coded" bindings."
  - The only comment is the automated triage by `warp-for-oss[bot]` (Oz). It matches this mission's trace: fixed `ctrl-y` Yank, editable Linux/Windows `ctrl-y` Delete All Left, editable-first ordering, first-match dispatch, and clearing persisted as an empty trigger. It lists three possible directions: "removing/remapping the conflicting Linux/Windows default, making the internal yank action editable/visible, or adding conflict/warning behavior that accounts for fixed bindings." The bot calls this "my automated analysis and may be incorrect." It is not maintainer feedback.
  - Timeline: labels added by the bot. `kevinchevalier` added `warp:auto-triage-review` (2026-05-27) and `warp:tracking` (2026-06-16). There are no human comments, no linked or cross-referenced PRs, and 0 reactions.
- **[warpdotdev/warp-stanford#12](https://github.com/warpdotdev/warp-stanford/issues/12)**, "ctrl-y runs "Delete all left" instead of yank on Linux/Windows". Open, created 2026-10-16. It mirrors #11743 and says the author will post a proposed direction before opening a PR. It has 0 comments and no timeline cross-references.

### Prior attempts or fixes

**None found.** No PR in either repository mentions `11743`. `warpdotdev/warp-stanford` returned no PRs for any term. The 17 PR hits in `warpdotdev/warp` (15 distinct PRs) were screened by title and state. None is about the GUI Ctrl-Y / Delete All Left conflict. The three below were read in full, including bodies, reviews and review comments, because they touch keybindings or kill/yank:
- [#13064](https://github.com/warpdotdev/warp/pull/13064) (merged), TUI input view milestone 1. It adds the TUI's own Ctrl-K/U/W + Ctrl-Y kill/yank. The only kill-related review comment, from the bot, concerned a TUI Ctrl-K off-by-one deletion range. Human reviewer `harryalbert` approved with "Overall LGTM… approving to unblock". Nothing about the GUI keymap.
- [#9415](https://github.com/warpdotdev/warp/pull/9415) (merged), bundled Agent Mode `change-keybinding` skill. Reviewer feedback that matters here: the bot flagged examples using `editor:delete_all_left`, because the registered name is `editor_view:delete_all_left` and the wrong name "would create inert custom entries". The author fixed the examples. Maintainer `alokedesai` approved ("Thank you for contributing!"). This supports the trace: persisted overrides are keyed by the exact editable name, and `none` is the removal value.
- [#14841](https://github.com/warpdotdev/warp/pull/14841) (open, bot-authored), macOS editing shortcuts in alt-screen TUIs. Matched because it mentions `cmd-backspace`. It is about terminal-view context predicates, not this conflict.
- [#10459](https://github.com/warpdotdev/warp/pull/10459) (open), spec for configurable word delimiters. Matched "delete all left" in text only.

### Related history (issues)

- [#61](https://github.com/warpdotdev/warp/issues/61) (closed 2021-08-11): "Ctrl + U/K doesn't cut to clipboard". A user (`chriskrycho`) pointed out that yank should use a kill ring separate from the system clipboard. Warp released a fix. This is the origin of the separate internal buffer used by `yank`.
- [#1902](https://github.com/warpdotdev/warp/issues/1902) (closed 2023-04-28): Ctrl-W/Ctrl-Y interaction with the clipboard on macOS, fixed in `v0.2023.04.25`. Ctrl-Y yanking was working on macOS then.
- [#4567](https://github.com/warpdotdev/warp/issues/4567) (closed as duplicate of #537): Linux "Cut All Left" shortcut does nothing. A member (`dannyneira`) closed it as a duplicate of rc-file `bindkey` support. The reporter replied that it was about Warp's own binding, and a 2025-12-28 comment says it still exists. This is a separate Linux kill-command report and was not investigated here.
- [#4228](https://github.com/warpdotdev/warp/issues/4228) (open): "Emacs and Vi users need full Readline support". It is a broad request and does not discuss Ctrl-Y.
- [#579](https://github.com/warpdotdev/warp/issues/579), [#100](https://github.com/warpdotdev/warp/issues/100): older umbrella issues about keybindings and Emacs bindings.

## WebSearch queries

| Query | Relevant results |
| --- | --- |
| `warpdotdev warp ctrl-y yank "delete all left" linux` | Only docs.warp.dev Keyboard Shortcuts page (page content not fetched; FetchUrl is limited to user-supplied URLs) |
| `github warpdotdev/warp issue 11743 ctrl+y delete all left` | Did not return #11743. It returned #15702 (Ctrl+Shift+Left/Right deletes instead of selecting, open, Linux), #12989, #1398, #10348 and docs pages |
| `warp terminal ctrl+y yank not working linux keybinding` | Unrelated keybinding issues (#6526, #16418, #4729, #14128, #16377), Discussion #500, docs |
| `warpdotdev warp-stanford ctrl-y yank` | Repository home pages and warp-stanford#2 ("test"). Did not return #12 |

WebSearch did not find either target issue, so it is not reliable coverage for GitHub issues. The GitHub search API is the main source here.

## Coverage limits

- GitHub search depends on its index and tokenizer. Quoted `"ctrl-y"` still matched documents containing only "ctrl" and "y". Items that spell the key differently ("Ctrl+Y", "C-y", "control-y") may be missed. Empty or limited results do not prove that no prior work exists.
- Discussions, Linear/internal trackers, Slack/Discord and private forks were not searched. Warp issue bodies mention internal Linear labels, which are not accessible.
- Commit messages and code history were not searched. `git log -S` for the `ctrl-y` registration was not run.
- The warpdotdev/warp-stanford search covered its issues and PRs. The repository has very few items.
- The docs.warp.dev keyboard shortcuts page was not read, so whether public docs list Ctrl-Y as Delete All Left on Linux/Windows is unverified.
- No human maintainer feedback on this specific conflict exists in the material read. The only analysis on #11743 is automated.
