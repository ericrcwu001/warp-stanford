#!/usr/bin/env python3
"""Builds before.srt/after.srt, captioned clips and the side-by-side comparison for #11743.

Cues come only from the recorded video-clock event logs of the two unchanged demo.sh runs.
Run from anywhere: python3 evidence/m3-captions/make_captions.py
"""
import json
import pathlib
import subprocess

EV = pathlib.Path(__file__).resolve().parent.parent
OUT = EV / "m3-captions"
RUNS = {
    "before": EV / "m1-native/default-before/events-video.tsv",
    "after": EV / "m3-native/default-after/events-video.tsv",
}
RAW = {"before": EV / "01-before.mp4", "after": EV / "02-after.mp4"}
CAPTIONED = {"before": EV / "01-before-captioned.mp4", "after": EV / "02-after-captioned.mp4"}
COMBINED = EV / "before-after-captioned.mp4"
LABELS = {
    "before": "BEFORE  -  unchanged build (base f411fbc20), default Linux settings",
    "after": "AFTER  -  Option A build (56f3560e9), default Linux settings",
}
FPS = 30
# Input line (where typed text appears) on the 1600x1000 capture.
INPUT_CROP = (160, 948, 1000, 36)
# A caret blink changes only a few pixel columns; a text edit changes many.
MIN_CHANGED_COLUMNS = 12

# hold name -> (before caption, after caption). Text describes only what the input shows.
CAPTIONS = {
    "empty-prompt": ("Empty input at the prompt", "Empty input at the prompt"),
    "typed-alpha-beta": ("Type 'alpha beta' (cursor at end)", "Type 'alpha beta' (cursor at end)"),
    "after-direct-ctrl-y": (
        "Ctrl-Y: all text left of the cursor is deleted",
        "Ctrl-Y: 'alpha beta' is unchanged",
    ),
    "typed-kill-u": (
        "Clear input, type 'kill-u-sentinel' (cursor at end)",
        "Clear input, type 'kill-u-sentinel' (cursor at end)",
    ),
    "after-ctrl-u": ("Ctrl-U: the text is removed", "Ctrl-U: the text is removed"),
    "after-ctrl-u-ctrl-y": (
        "Ctrl-Y: input stays empty, 'kill-u-sentinel' is not restored",
        "Ctrl-Y: 'kill-u-sentinel' is restored",
    ),
    "typed-kill-k-cursor-start": (
        "Clear input, type 'kill-k-sentinel', Home moves the cursor to the start",
        "Clear input, type 'kill-k-sentinel', Home moves the cursor to the start",
    ),
    "after-ctrl-k": ("Ctrl-K: the text is removed", "Ctrl-K: the text is removed"),
    "after-ctrl-k-ctrl-y": (
        "Ctrl-Y: input stays empty, 'kill-k-sentinel' is not restored",
        "Ctrl-Y: 'kill-k-sentinel' is restored",
    ),
    "typed-first-second": (
        "Clear input, type 'first second' (cursor at end)",
        "Clear input, type 'first second' (cursor at end)",
    ),
    "after-ctrl-w": ("Ctrl-W: the word 'second' is removed", "Ctrl-W: the word 'second' is removed"),
    "after-ctrl-w-ctrl-y": (
        "Ctrl-Y: 'first ' is deleted too, 'second' is not restored",
        "Ctrl-Y: 'second' is restored, giving 'first second'",
    ),
    "final-reset": ("Clear input: end of the demo", "Clear input: end of the demo"),
}
SUB_STYLE = (
    "FontName=DejaVu Sans,FontSize=15,PrimaryColour=&H00FFFFFF,OutlineColour=&H30303030,"
    "BorderStyle=3,Outline=5,Shadow=0,Alignment=8,MarginV=55,MarginL=60,MarginR=8"
)
FONT_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
X264 = ["-an", "-c:v", "libx264", "-preset", "medium", "-crf", "20", "-pix_fmt", "yuv420p",
        "-r", "30", "-movflags", "+faststart"]


def run(cmd):
    print("+", " ".join(str(c) for c in cmd), flush=True)
    subprocess.run(cmd, check=True)


def probe_duration(path):
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of",
                          "csv=p=0", str(path)], check=True, capture_output=True, text=True)
    return float(out.stdout.strip())


def input_line_frames(video):
    x, y, w, h = INPUT_CROP
    raw = subprocess.run(["ffmpeg", "-nostdin", "-v", "error", "-i", str(video), "-vf",
                          f"crop={w}:{h}:{x}:{y},format=gray", "-f", "rawvideo", "-"],
                         check=True, capture_output=True).stdout
    size = w * h
    return [raw[i:i + size] for i in range(0, len(raw), size)], w


def changed_columns(a, b, width):
    cols = set()
    for i in range(len(a)):
        if abs(a[i] - b[i]) > 40:
            cols.add(i % width)
    return len(cols)


def detect_change(frames, width, key_t):
    """Time of the first frame after key_t whose input line differs from the pre-key frame by
    more than a caret blink, or None when the key leaves the input visibly unchanged."""
    ref = frames[max(0, int(key_t * FPS) - 1)]
    for i in range(int(key_t * FPS), min(len(frames), int((key_t + 0.6) * FPS))):
        n = changed_columns(ref, frames[i], width)
        if n >= MIN_CHANGED_COLUMNS:
            return round(i / FPS, 3), n
    return None, 0


def read_events(path):
    rows = []
    for line in path.read_text().splitlines()[1:]:
        t, kind, detail, *rest = line.split("\t")
        rows.append({"t": float(t), "kind": kind, "detail": detail,
                     "hold": float(rest[0]) if rest and rest[0] else None})
    return rows


def build_cues(events, duration, side, frames, width):
    """One cue per hold. A typed state starts at the reset (or type) event that leads into it,
    a key result starts at the first frame showing the key's effect (or at the key event when
    nothing visibly changes), and each cue ends where the next one starts."""
    idx = 0 if side == "before" else 1
    starts = []
    detections = []
    for i, ev in enumerate(events):
        if ev["kind"] != "hold":
            continue
        name = ev["detail"]
        if name == "empty-prompt":
            start = 0.0
        elif name.startswith("typed-") or name == "final-reset":
            lead = [e for e in events[:i] if e["kind"] in ("reset", "type")]
            prior_hold_t = max(e["t"] for e in events[:i] if e["kind"] == "hold")
            lead = [e for e in lead if e["t"] > prior_hold_t]
            start = lead[0]["t"]
        else:
            key_ev = [e for e in events[:i] if e["kind"] == "key"][-1]
            change_t, cols = detect_change(frames, width, key_ev["t"])
            start = change_t if change_t is not None else key_ev["t"]
            detections.append({"cue": name, "key": key_ev["detail"], "key_t": key_ev["t"],
                               "change_t": change_t, "changed_columns": cols})
        starts.append((name, start, ev["t"], ev["hold"]))
    cues = []
    for n, (name, start, hold_t, hold_s) in enumerate(starts):
        end = starts[n + 1][1] if n + 1 < len(starts) else duration
        cues.append({"n": n + 1, "name": name, "start": round(start, 3), "end": round(end, 3),
                     "hold_start": hold_t, "hold_s": hold_s, "text": CAPTIONS[name][idx]})
    return cues, detections


def ts(sec):
    ms = int(round(sec * 1000))
    h, ms = divmod(ms, 3600000)
    m, ms = divmod(ms, 60000)
    s, ms = divmod(ms, 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def write_srt(path, cues):
    path.write_text("".join(f"{c['n']}\n{ts(c['start'])} --> {ts(c['end'])}\n{c['text']}\n\n"
                            for c in cues))


def pane_filter(side):
    label = OUT / f"label-{side}.txt"
    label.write_text(LABELS[side])
    return (f"subtitles={side}.srt:force_style='{SUB_STYLE}',"
            f"drawtext=fontfile={FONT_BOLD}:textfile={label}:fontsize=30:fontcolor=white:"
            f"box=1:boxcolor=0x1c3d6e@0.95:boxborderw=12:x=250+(1350-text_w)/2:y=62")


def main():
    events = {s: read_events(p) for s, p in RUNS.items()}
    kinds = {s: [(e["kind"], e["detail"]) for e in ev] for s, ev in events.items()}
    assert kinds["before"] == kinds["after"], "before/after scripts differ"
    durations = {s: probe_duration(RAW[s]) for s in RAW}
    cues, detections = {}, {}
    for s in RUNS:
        frames, width = input_line_frames(RAW[s])
        cues[s], detections[s] = build_cues(events[s], durations[s], s, frames, width)
    for s in RUNS:
        write_srt(EV / f"{s}.srt", cues[s])

    # A single constant delay on the after pane (frozen first frame) minimises the largest
    # event mismatch without changing the speed or order of either recording.
    diffs = [b["t"] - a["t"] for b, a in zip(events["before"], events["after"])]
    delay = round((max(diffs) + min(diffs)) / 2, 3)
    residual = round(max(abs(d - delay) for d in diffs), 3)
    total = max(durations["before"], durations["after"] + delay)

    for s in RUNS:
        run(["ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-y", "-i", RAW[s],
             "-vf", pane_filter(s), *X264, CAPTIONED[s]])

    graph = (
        f"[0:v]{pane_filter('before')},tpad=stop_mode=clone:stop_duration={total:.3f}[b];"
        f"[1:v]{pane_filter('after')},tpad=start_mode=clone:start_duration={delay:.3f}:"
        f"stop_mode=clone:stop_duration={total:.3f}[a];"
        "[b][a]hstack=inputs=2[v]"
    )
    run(["ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-y", "-i", RAW["before"],
         "-i", RAW["after"], "-filter_complex", graph, "-map", "[v]", "-t", f"{total:.3f}",
         *X264, COMBINED])

    combined_cues = []
    for b, a in zip(cues["before"], cues["after"]):
        a_start, a_end = a["start"] + delay, a["end"] + delay
        combined_cues.append({
            "n": b["n"], "name": b["name"],
            "left": [b["start"], b["end"]], "right": [round(a_start, 3), round(a_end, 3)],
            "overlap": [round(max(b["start"], a_start), 3), round(min(b["end"], a_end), 3)],
            "left_text": b["text"], "right_text": a["text"],
        })
    (OUT / "timeline.json").write_text(json.dumps({
        "durations_s": durations, "after_pane_delay_s": delay,
        "max_residual_event_offset_s": residual, "combined_duration_s": round(total, 3),
        "input_crop_xywh": INPUT_CROP, "key_change_detection": detections,
        "cues": cues, "combined": combined_cues,
    }, indent=2) + "\n")
    print(f"delay={delay} residual={residual} total={total:.3f}")


if __name__ == "__main__":
    main()
