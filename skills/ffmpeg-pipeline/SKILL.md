---
name: ffmpeg-pipeline
description: >
  ffmpeg recipes for common taw-video tasks: scale to multiple aspect ratios,
  encode H.264/H.265/VP9, compress for upload (YT/TikTok/web/4K), GIF export,
  frame extraction for review. Used by renderer agent + render branch. NOT a
  wrapper — emits actual ffmpeg commands so users learn standard tooling.
  Note: taw-video v0.1.1 produces silent video; voice mux is OUT OF SCOPE
  (user mixes audio externally in their editor).
  Trigger phrases (EN + VN): "ffmpeg", "convert video", "compress mp4",
  "extract frame", "gif export", "scale video", "render h265", "encode 4k".
allowed-tools: Read, Bash
---

# ffmpeg-pipeline

Recipe book + thin orchestration helpers. Each function = 1 ffmpeg command, well-tested for taw-video output conventions.

## Recipe 0 — Verify ffmpeg is full-build

Before any encode:

```bash
ffmpeg -encoders 2>&1 | command grep -E "libx264|libx265|libvpx-vp9" | head -3
```

Should show all three. If `libx264` missing → user has minimal build → escalate "ffmpeg encoder missing" error template.

## Recipe 1 — Compress for upload

| Target | Recipe |
|---|---|
| YouTube 1080p | `-c:v libx264 -crf 18 -preset slow -b:v 8M -maxrate 12M -bufsize 16M` |
| YouTube 4K | `-c:v libx265 -crf 22 -preset medium -tag:v hvc1` |
| TikTok 9:16 | `-c:v libx264 -crf 23 -preset medium -b:v 6M` |
| Web preview | `-c:v libx264 -crf 28 -preset fast -b:v 2M` |
| GIF | see Recipe 6 |

Full example (TikTok):

```bash
ffmpeg -i out/<slug>-9x16.mp4 \
       -c:v libx264 -crf 23 -preset medium -b:v 6M \
       -movflags +faststart \
       out/<slug>-9x16-tiktok.mp4
```

`-movflags +faststart` moves moov atom to start → enables progressive playback in browsers.

If the input has BGM (Remotion bundled it via `<Audio>`), keep it: add `-c:a aac -b:a 128k` (or `-c:a copy` if already AAC).

## Recipe 2 — Scale to alternate aspect (last resort — prefer Remotion re-render)

Most cases: re-render via Remotion is better (uses scene's responsive layout). But if you must crop existing render:

```bash
# 16:9 master → 9:16 crop (keep center)
ffmpeg -i out/<slug>-16x9.mp4 \
       -vf "crop=ih*9/16:ih,scale=1080:1920" \
       -c:a copy \
       out/<slug>-9x16-cropped.mp4

# 16:9 master → 9:16 with blurred letterbox (TikTok safe)
ffmpeg -i out/<slug>-16x9.mp4 \
       -vf "split[a][b]; \
            [a]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=20[bg]; \
            [b]scale=1080:-1[fg]; \
            [bg][fg]overlay=0:(H-h)/2" \
       -c:a copy \
       out/<slug>-9x16-blur.mp4
```

Recommend re-render for primary deliverable; crop only for quick alt drops.

## Recipe 3 — Re-encode codec only (keep duration + audio + dimensions)

```bash
# H.264 → H.265 (smaller file)
ffmpeg -i out/<slug>.mp4 -c:v libx265 -crf 24 -preset medium -tag:v hvc1 -c:a copy out/<slug>-h265.mp4

# H.264 → VP9/WebM (open-source path)
ffmpeg -i out/<slug>.mp4 -c:v libvpx-vp9 -crf 31 -b:v 0 -c:a libopus out/<slug>.webm
```

## Recipe 4 — Scale to specific resolution

```bash
# 1080p → 720p (keep aspect)
ffmpeg -i out/<slug>.mp4 -vf "scale=-2:720" -c:a copy out/<slug>-720p.mp4

# 1080p → 4K (upscale — quality cap = source)
ffmpeg -i out/<slug>.mp4 -vf "scale=-2:2160:flags=lanczos" -c:v libx265 -crf 22 -c:a copy out/<slug>-4k.mp4
```

## Recipe 5 — Concat multiple renders

```bash
# Create concat list
cat > .taw-video/concat.txt <<EOF
file 'out/intro.mp4'
file 'out/main.mp4'
file 'out/outro.mp4'
EOF

ffmpeg -f concat -safe 0 -i .taw-video/concat.txt -c copy out/full.mp4
```

`-c copy` is bit-perfect (no re-encode). Requires segments to share codec + dimensions + framerate (taw-video output usually does).

## Recipe 6 — Export GIF (two-pass, palette-aware)

```bash
ffmpeg -i out/<slug>.mp4 \
  -vf "fps=15,scale=720:-1:flags=lanczos,palettegen=stats_mode=diff" \
  -y .taw-video/palette.png

ffmpeg -i out/<slug>.mp4 -i .taw-video/palette.png \
  -filter_complex "fps=15,scale=720:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5" \
  out/<slug>.gif
```

Result: ~30% smaller than single-pass, no banding.

## Recipe 7 — Extract frames for review

```bash
# Frame at 5 seconds
ffmpeg -ss 5 -i out/<slug>.mp4 -vframes 1 .taw-video/review/frame-5s.jpg

# 4 evenly-spaced frames
duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 out/<slug>.mp4)
for pct in 25 50 75 90; do
  t=$(awk -v d="$duration" -v p="$pct" 'BEGIN{printf "%.2f", d*p/100}')
  ffmpeg -ss "$t" -i out/<slug>.mp4 -vframes 1 ".taw-video/review/frame-${pct}pct.jpg"
done
```

## Recipe 8 — Probe video stats (for video-reviewer agent)

```bash
ffprobe -v error -show_entries \
  stream=codec_name,width,height,r_frame_rate,duration:format=size,bit_rate \
  -of json out/<slug>.mp4
```

Returns codec, dimensions, fps, duration, file size, overall bitrate. Used by video-reviewer to validate output meets spec.

## Recipe 9 — Add chapter markers (YT)

```bash
# Edit metadata file at .taw-video/chapters.txt:
;FFMETADATA1
[CHAPTER]
TIMEBASE=1/1000
START=0
END=15000
title=Intro

[CHAPTER]
TIMEBASE=1/1000
START=15000
END=45000
title=Main content

ffmpeg -i out/<slug>.mp4 -i .taw-video/chapters.txt -map_metadata 1 -c copy out/<slug>-chaptered.mp4
```

## Performance notes

- `-preset` controls encode speed vs file size tradeoff:
  - `ultrafast` / `superfast` / `veryfast`: dev iteration only — file 2× larger
  - `medium`: balanced (default)
  - `slow` / `veryslow`: final master — ~30% smaller file, 3–5× longer encode
- `-crf`: 18 (visually lossless) … 23 (default) … 28 (acceptable) … 32 (low quality)
- Use `-threads 0` (default) — ffmpeg auto-picks core count.
- `-movflags +faststart` adds ~0.5s but is REQUIRED for web playback. Always include for MP4 outputs.

## Skill output

```json
{
  "status": "ok",
  "recipe": "compress-tiktok-9x16",
  "input_files": ["out/<slug>-9x16.mp4"],
  "output_path": "out/<slug>-9x16-tiktok.mp4",
  "size_mb": 6.2,
  "duration_sec": 60.0
}
```

## Constraints

- NEVER use `-c copy` after applying a video filter — needs re-encode.
- ALWAYS include `-movflags +faststart` for MP4 outputs.
- NEVER trust user-provided ffmpeg args without reading them — `-vf "blah; rm -rf /"` is shell-injectable. Sanitize via Bash quoting.
- Single source of truth for filter graphs: `-filter_complex` for >1 filter, `-vf` / `-af` for single filter.
- Voice mux / side-chain duck recipes are OUT OF SCOPE in v0.1.1 — taw-video produces silent video; user adds voice externally.
