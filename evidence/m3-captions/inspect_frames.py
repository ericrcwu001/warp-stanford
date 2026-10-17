#!/usr/bin/env python3
"""Extracts in-cue frames from the captioned clips and the side-by-side, and builds crop sheets
(caption area plus input line) for visual inspection. Full mid-cue frames are kept as PNGs."""
import json
import pathlib
import subprocess
import tempfile

EV = pathlib.Path(__file__).resolve().parent.parent
OUT = EV / "m3-captions"
INSP = OUT / "inspection"
TL = json.loads((OUT / "timeline.json").read_text())
EDGE = 0.04
CLIPS = {
    "before": (EV / "01-before-captioned.mp4", [0]),
    "after": (EV / "02-after-captioned.mp4", [0]),
    "combined": (EV / "before-after-captioned.mp4", [0, 1600]),
}


def sh(*cmd):
    subprocess.run([str(c) for c in cmd], check=True)


def frame(video, t, dest):
    sh("ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-y", "-ss", f"{t:.3f}",
       "-i", video, "-frames:v", 1, dest)


def strip(src, xs, label, dest, tmp):
    parts = []
    for i, x in enumerate(xs):
        cap = tmp / f"cap{i}.png"
        inp = tmp / f"inp{i}.png"
        sh("convert", src, "-crop", f"1440x170+{x + 160}+420", "+repage", "-resize", "60%", cap)
        sh("convert", src, "-crop", f"700x50+{x + 160}+940", "+repage", inp)
        pane = tmp / f"pane{i}.png"
        sh("convert", cap, inp, "-background", "black", "-gravity", "west", "-append", pane)
        parts.append(pane)
    body = tmp / "body.png"
    sh("convert", *parts, "-background", "gray30", "-splice", "6x0", "+append", body)
    sh("convert", body, "-background", "white", "-fill", "black", "-font", "DejaVu-Sans",
       "-pointsize", 16, "label:" + label, "+swap", "-gravity", "west", "-append", dest)


def main():
    records = []
    with tempfile.TemporaryDirectory() as td:
        tmp = pathlib.Path(td)
        for clip, (video, xs) in CLIPS.items():
            (INSP / clip).mkdir(parents=True, exist_ok=True)
            if clip == "combined":
                windows = [(c["n"], c["name"], *c["overlap"], f"L: {c['left_text']} | R: {c['right_text']}")
                           for c in TL["combined"]]
            else:
                windows = [(c["n"], c["name"], c["start"], c["end"], c["text"])
                           for c in TL["cues"][clip]]
            for pos in ("start", "mid", "end"):
                strips = []
                for n, name, s, e, text in windows:
                    t = {"start": s + EDGE, "mid": (s + e) / 2, "end": e - EDGE}[pos]
                    full = (INSP / clip / f"{n:02d}-{name}-mid.png") if pos == "mid" else tmp / "f.png"
                    frame(video, t, full)
                    st = tmp / f"strip{n:02d}.png"
                    strip(full, xs, f"{clip} cue {n} {pos} t={t:.3f}s  [{s:.3f}-{e:.3f}]  {name}", st, tmp)
                    strips.append(st)
                    records.append({"clip": clip, "cue": n, "name": name, "position": pos,
                                    "t_s": round(t, 3), "cue_start": s, "cue_end": e, "caption": text})
                for half, chunk in (("a", strips[:7]), ("b", strips[7:])):
                    sh("convert", *chunk, "-background", "gray60", "-splice", "0x4", "-append",
                       INSP / f"sheet-{clip}-{pos}-{half}.png")
    (INSP / "frames.json").write_text(json.dumps(records, indent=1) + "\n")


if __name__ == "__main__":
    main()
