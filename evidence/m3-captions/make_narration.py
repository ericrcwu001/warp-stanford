#!/usr/bin/env python3
"""Writes NARRATION.md from timeline.json and checks every MP4 under evidence/ (media-check.md)."""
import hashlib
import json
import pathlib
import subprocess

EV = pathlib.Path(__file__).resolve().parent.parent
OUT = EV / "m3-captions"
TL = json.loads((OUT / "timeline.json").read_text())
MAX_WPM = 165
MAX_BYTES = 25 * 1000 * 1000

LINES = {
    "combined": [
        "Before left, after right; both inputs empty.",
        "Both type alpha beta.",
        "Ctrl-Y wipes it before; after, nothing changes.",
        "Now type a sentinel, cursor at the end.",
        "Ctrl-U clears the line in both.",
        "Ctrl-Y: empty before, restored after.",
        "Next sentinel, then Home jumps the cursor to the start.",
        "Ctrl-K clears it in both.",
        "Ctrl-Y again: still empty before, restored after.",
        "Last, type first second, cursor at the end.",
        "Ctrl-W removes the word second.",
        "Before, Ctrl-Y erases everything; after, second returns.",
        "Input cleared. That's the whole demo.",
    ],
    "before": [
        "Default settings, unchanged build. The input is empty.",
        "Type alpha beta, cursor at the end.",
        "Ctrl-Y deletes everything left of the cursor.",
        "Clear the input and type the Ctrl-U sentinel.",
        "Ctrl-U removes the text.",
        "Ctrl-Y should bring it back. It doesn't.",
        "Clear, type the Ctrl-K sentinel, then press Home.",
        "Ctrl-K removes the text.",
        "Ctrl-Y again: nothing comes back.",
        "Clear, then type first second.",
        "Ctrl-W removes the word second.",
        "Ctrl-Y erases first too; second never returns.",
        "Input cleared. End of the demo.",
    ],
    "after": [
        "Option A build. The input is empty.",
        "Type alpha beta, cursor at the end.",
        "Ctrl-Y leaves alpha beta alone.",
        "Clear the input and type the Ctrl-U sentinel.",
        "Ctrl-U removes the text.",
        "Ctrl-Y brings the sentinel back.",
        "Clear, type the Ctrl-K sentinel, then press Home.",
        "Ctrl-K removes the text.",
        "Ctrl-Y restores it again.",
        "Clear, then type first second.",
        "Ctrl-W removes the word second.",
        "Ctrl-Y puts second back after first.",
        "Input cleared. End of the demo.",
    ],
}


def fmt(t):
    m, s = divmod(t, 60)
    return f"{int(m):02d}:{s:06.3f}"


def table(rows):
    out = ["| start - end | caption on screen | line to say aloud | words | seconds | wpm |",
           "| --- | --- | --- | --- | --- | --- |"]
    for (s, e, cap), line in rows:
        words = len(line.split())
        secs = e - s
        wpm = words / secs * 60
        assert wpm <= MAX_WPM, (line, wpm)
        out.append(f"| {fmt(s)} - {fmt(e)} | {cap} | {line} | {words} | {secs:.2f} | {wpm:.0f} |")
    return "\n".join(out)


def narration():
    comb = [(c["overlap"][0], c["overlap"][1],
             f"Left: {c['left_text']}<br>Right: {c['right_text']}") for c in TL["combined"]]
    per = {s: [(c["start"], c["end"], c["text"]) for c in TL["cues"][s]] for s in ("before", "after")}
    delay = TL["after_pane_delay_s"]
    combined_s = float(probe(EV / "before-after-captioned.mp4")["format"]["duration"])
    peak = max(len(line.split()) / (e - s) * 60
               for rows, key in ((comb, "combined"), (per["before"], "before"), (per["after"], "after"))
               for (s, e, _), line in zip(rows, LINES[key]))
    doc = f"""# Narration script (text only, no voice track)

Timed lines a presenter can read aloud over the silent captioned videos. No audio was recorded
or added to any video. Times come from `m3-captions/timeline.json`, which is derived from the
recorded `events-video.tsv` of each run. Each line fits its interval at a natural pace of about
150 words per minute or slower (fastest row: {peak:.0f} wpm).

## `before-after-captioned.mp4` (side by side, {combined_s:.3f} s)

Left pane is `01-before.mp4`, right pane is `02-after.mp4` delayed by {delay:.3f} s (its first
frame is held) so matching steps line up. One row per caption pair: both panes show caption n
together, and the row covers the time when both are on screen.

{table(zip(comb, LINES['combined']))}

## `01-before-captioned.mp4` (captions from `before.srt`)

{table(zip(per['before'], LINES['before']))}

## `02-after-captioned.mp4` (captions from `after.srt`)

{table(zip(per['after'], LINES['after']))}
"""
    (EV / "NARRATION.md").write_text(doc)


def probe(path):
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries",
                          "format=duration,size:stream=index,codec_type,codec_name,pix_fmt,width,"
                          "height,r_frame_rate,nb_frames", "-of", "json", str(path)],
                         check=True, capture_output=True, text=True).stdout
    return json.loads(out)


def media_check():
    rows = ["| file | bytes | streams | audio streams | codec | pix_fmt | size | fps | frames | duration s | sha256 (first 16) |",
            "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"]
    ok = True
    for p in sorted(EV.rglob("*.mp4")):
        info = probe(p)
        streams = info["streams"]
        video = [s for s in streams if s["codec_type"] == "video"]
        audio = [s for s in streams if s["codec_type"] == "audio"]
        size = p.stat().st_size
        ok &= size < MAX_BYTES and not audio and len(streams) == 1
        v = video[0]
        sha = hashlib.sha256(p.read_bytes()).hexdigest()[:16]
        rows.append(f"| `{p.relative_to(EV)}` | {size:,} | {len(streams)} | {len(audio)} | "
                    f"{v['codec_name']} | {v['pix_fmt']} | {v['width']}x{v['height']} | "
                    f"{v['r_frame_rate']} | {v.get('nb_frames', '?')} | "
                    f"{float(info['format']['duration']):.3f} | {sha} |")
    (OUT / "media-check.md").write_text(
        "# MP4 population check\n\nGenerated by `make_narration.py` with ffprobe over every `*.mp4` "
        "under `evidence/`. Limit: strictly under 25,000,000 bytes, exactly one stream, no audio.\n\n"
        + "\n".join(rows) + f"\n\nResult: {'PASS' if ok else 'FAIL'}\n")
    print("\n".join(rows))
    assert ok


if __name__ == "__main__":
    narration()
    media_check()
