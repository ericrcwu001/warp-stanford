# Narration script (text only, no voice track)

Timed lines a presenter can read aloud over the silent captioned videos. No audio was recorded
or added to any video. Times come from `m3-captions/timeline.json`, which is derived from the
recorded `events-video.tsv` of each run. Each line fits its interval at a natural pace of about
150 words per minute or slower (fastest row: 149 wpm).

## `before-after-captioned.mp4` (side by side, 42.500 s)

Left pane is `01-before.mp4`, right pane is `02-after.mp4` delayed by 0.428 s (its first
frame is held) so matching steps line up. One row per caption pair: both panes show caption n
together, and the row covers the time when both are on screen.

| start - end | caption on screen | line to say aloud | words | seconds | wpm |
| --- | --- | --- | --- | --- | --- |
| 00:00.428 - 00:03.478 | Left: Empty input at the prompt<br>Right: Empty input at the prompt | Before left, after right; both inputs empty. | 7 | 3.05 | 138 |
| 00:03.561 - 00:06.500 | Left: Type 'alpha beta' (cursor at end)<br>Right: Type 'alpha beta' (cursor at end) | Both type alpha beta. | 4 | 2.94 | 82 |
| 00:06.551 - 00:09.546 | Left: Ctrl-Y: all text left of the cursor is deleted<br>Right: Ctrl-Y: 'alpha beta' is unchanged | Ctrl-Y wipes it before; after, nothing changes. | 7 | 2.99 | 140 |
| 00:09.590 - 00:13.561 | Left: Clear input, type 'kill-u-sentinel' (cursor at end)<br>Right: Clear input, type 'kill-u-sentinel' (cursor at end) | Now type a sentinel, cursor at the end. | 8 | 3.97 | 121 |
| 00:13.633 - 00:16.631 | Left: Ctrl-U: the text is removed<br>Right: Ctrl-U: the text is removed | Ctrl-U clears the line in both. | 6 | 3.00 | 120 |
| 00:16.661 - 00:19.635 | Left: Ctrl-Y: input stays empty, 'kill-u-sentinel' is not restored<br>Right: Ctrl-Y: 'kill-u-sentinel' is restored | Ctrl-Y: empty before, restored after. | 5 | 2.97 | 101 |
| 00:19.701 - 00:23.728 | Left: Clear input, type 'kill-k-sentinel', Home moves the cursor to the start<br>Right: Clear input, type 'kill-k-sentinel', Home moves the cursor to the start | Next sentinel, then Home jumps the cursor to the start. | 10 | 4.03 | 149 |
| 00:23.800 - 00:26.728 | Left: Ctrl-K: the text is removed<br>Right: Ctrl-K: the text is removed | Ctrl-K clears it in both. | 5 | 2.93 | 102 |
| 00:26.759 - 00:29.767 | Left: Ctrl-Y: input stays empty, 'kill-k-sentinel' is not restored<br>Right: Ctrl-Y: 'kill-k-sentinel' is restored | Ctrl-Y again: still empty before, restored after. | 7 | 3.01 | 140 |
| 00:29.826 - 00:33.628 | Left: Clear input, type 'first second' (cursor at end)<br>Right: Clear input, type 'first second' (cursor at end) | Last, type first second, cursor at the end. | 8 | 3.80 | 126 |
| 00:33.700 - 00:36.661 | Left: Ctrl-W: the word 'second' is removed<br>Right: Ctrl-W: the word 'second' is removed | Ctrl-W removes the word second. | 5 | 2.96 | 101 |
| 00:36.800 - 00:39.689 | Left: Ctrl-Y: 'first ' is deleted too, 'second' is not restored<br>Right: Ctrl-Y: 'second' is restored, giving 'first second' | Before, Ctrl-Y erases everything; after, second returns. | 7 | 2.89 | 145 |
| 00:39.778 - 00:42.461 | Left: Clear input: end of the demo<br>Right: Clear input: end of the demo | Input cleared. That's the whole demo. | 6 | 2.68 | 134 |

## `01-before-captioned.mp4` (captions from `before.srt`)

| start - end | caption on screen | line to say aloud | words | seconds | wpm |
| --- | --- | --- | --- | --- | --- |
| 00:00.000 - 00:03.478 | Empty input at the prompt | Default settings, unchanged build. The input is empty. | 8 | 3.48 | 138 |
| 00:03.478 - 00:06.500 | Type 'alpha beta' (cursor at end) | Type alpha beta, cursor at the end. | 7 | 3.02 | 139 |
| 00:06.500 - 00:09.546 | Ctrl-Y: all text left of the cursor is deleted | Ctrl-Y deletes everything left of the cursor. | 7 | 3.05 | 138 |
| 00:09.546 - 00:13.633 | Clear input, type 'kill-u-sentinel' (cursor at end) | Clear the input and type the Ctrl-U sentinel. | 8 | 4.09 | 117 |
| 00:13.633 - 00:16.631 | Ctrl-U: the text is removed | Ctrl-U removes the text. | 4 | 3.00 | 80 |
| 00:16.631 - 00:19.701 | Ctrl-Y: input stays empty, 'kill-u-sentinel' is not restored | Ctrl-Y should bring it back. It doesn't. | 7 | 3.07 | 137 |
| 00:19.701 - 00:23.800 | Clear input, type 'kill-k-sentinel', Home moves the cursor to the start | Clear, type the Ctrl-K sentinel, then press Home. | 8 | 4.10 | 117 |
| 00:23.800 - 00:26.759 | Ctrl-K: the text is removed | Ctrl-K removes the text. | 4 | 2.96 | 81 |
| 00:26.759 - 00:29.826 | Ctrl-Y: input stays empty, 'kill-k-sentinel' is not restored | Ctrl-Y again: nothing comes back. | 5 | 3.07 | 98 |
| 00:29.826 - 00:33.700 | Clear input, type 'first second' (cursor at end) | Clear, then type first second. | 5 | 3.87 | 77 |
| 00:33.700 - 00:36.800 | Ctrl-W: the word 'second' is removed | Ctrl-W removes the word second. | 5 | 3.10 | 97 |
| 00:36.800 - 00:39.778 | Ctrl-Y: 'first ' is deleted too, 'second' is not restored | Ctrl-Y erases first too; second never returns. | 7 | 2.98 | 141 |
| 00:39.778 - 00:42.467 | Clear input: end of the demo | Input cleared. End of the demo. | 6 | 2.69 | 134 |

## `02-after-captioned.mp4` (captions from `after.srt`)

| start - end | caption on screen | line to say aloud | words | seconds | wpm |
| --- | --- | --- | --- | --- | --- |
| 00:00.000 - 00:03.133 | Empty input at the prompt | Option A build. The input is empty. | 7 | 3.13 | 134 |
| 00:03.133 - 00:06.123 | Type 'alpha beta' (cursor at end) | Type alpha beta, cursor at the end. | 7 | 2.99 | 140 |
| 00:06.123 - 00:09.162 | Ctrl-Y: 'alpha beta' is unchanged | Ctrl-Y leaves alpha beta alone. | 5 | 3.04 | 99 |
| 00:09.162 - 00:13.133 | Clear input, type 'kill-u-sentinel' (cursor at end) | Clear the input and type the Ctrl-U sentinel. | 8 | 3.97 | 121 |
| 00:13.133 - 00:16.233 | Ctrl-U: the text is removed | Ctrl-U removes the text. | 4 | 3.10 | 77 |
| 00:16.233 - 00:19.207 | Ctrl-Y: 'kill-u-sentinel' is restored | Ctrl-Y brings the sentinel back. | 5 | 2.97 | 101 |
| 00:19.207 - 00:23.300 | Clear input, type 'kill-k-sentinel', Home moves the cursor to the start | Clear, type the Ctrl-K sentinel, then press Home. | 8 | 4.09 | 117 |
| 00:23.300 - 00:26.300 | Ctrl-K: the text is removed | Ctrl-K removes the text. | 4 | 3.00 | 80 |
| 00:26.300 - 00:29.339 | Ctrl-Y: 'kill-k-sentinel' is restored | Ctrl-Y restores it again. | 4 | 3.04 | 79 |
| 00:29.339 - 00:33.200 | Clear input, type 'first second' (cursor at end) | Clear, then type first second. | 5 | 3.86 | 78 |
| 00:33.200 - 00:36.233 | Ctrl-W: the word 'second' is removed | Ctrl-W removes the word second. | 5 | 3.03 | 99 |
| 00:36.233 - 00:39.261 | Ctrl-Y: 'second' is restored, giving 'first second' | Ctrl-Y puts second back after first. | 6 | 3.03 | 119 |
| 00:39.261 - 00:42.033 | Clear input: end of the demo | Input cleared. End of the demo. | 6 | 2.77 | 130 |
