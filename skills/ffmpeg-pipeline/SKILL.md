---
name: ffmpeg-pipeline
description: >
  ffmpeg recipes for common taw-video tasks: mux video+voice+captions, side-chain
  duck BGM under voice, scale to multiple aspect ratios, encode H.264/H.265/VP9,
  GIF export, frame extraction for review, audio-level normalization (EBU R128).
  Used by renderer agent + render branch. NOT a wrapper — emits actual ffmpeg
  commands so users learn standard tooling.
  Trigger phrases (EN + VN): "ffmpeg", "mux audio", "ghep am thanh", "convert video",
  "compress mp4", "extract frame", "duck audio", "side chain", "gif export".
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

## Recipe 1 — Mux video + voice (silent video has no audio track)

```bash
ffmpeg -i out/<slug>-<aspect>.mp4 \
       -i public/voice.mp3 \
       -c:v copy -c:a aac -b:a 192k \
       -map 0:v -map 1:a \
       -shortest \
       out/<slug>-<aspect>-voiced.mp4
```

`-shortest` ensures output ends when shortest stream ends (handles voice slightly shorter/longer than visual).

## Recipe 2 — Mux video + voice + BGM with side-chain duck

BGM should DIP when voice plays (~6dB drop), restore when voice stops. Standard "ducking":

```bash
ffmpeg -i out/<slug>-<aspect>.mp4 \
       -i public/voice.mp3 \
       -i public/bgm.mp3 \
       -filter_complex "[1:a]volume=1.0[voice]; \
                        [2:a]volume=0.4[bgm]; \
                        [bgm][voice]sidechaincompress=threshold=0.05:ratio=8:attack=20:release=300[bgm_ducked]; \
                        [voice][bgm_ducked]amix=inputs=2:duration=longest[mixed]" \
       -map 0:v -map "[mixed]" \
       -c:v copy -c:a aac -b:a 192k \
       out/<slug>-<aspect>-final.mp4
```

Tune: `threshold` lower = more aggressive duck. `ratio` higher = stronger duck. Above values are good defaults for talking-head pace.

## Recipe 3 — Burn captions (delegated to captions-vi-burn skill, see there)

```bash
ffmpeg -i out/<slug>.mp4 \
  -vf "subtitles=public/voice.vtt:force_style='FontName=Be Vietnam Pro,FontSize=28'" \
  -c:a copy \
  out/<slug>-subbed.mp4
```

## Recipe 4 — Scale to alternate aspect

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

## Recipe 5 — Compress for upload

| Target | Recipe |
|---|---|
| YouTube 1080p | `-c:v libx264 -crf 18 -preset slow -b:v 8M -maxrate 12M -bufsize 16M -c:a aac -b:a 192k` |
| YouTube 4K | `-c:v libx265 -crf 22 -preset medium -tag:v hvc1 -c:a aac -b:a 256k` |
| TikTok 9:16 | `-c:v libx264 -crf 23 -preset medium -b:v 6M -c:a aac -b:a 128k` |
| Web preview | `-c:v libx264 -crf 28 -preset fast -b:v 2M -c:a aac -b:a 96k` |
| GIF | see Recipe 8 |

Full example (TikTok):

```bash
ffmpeg -i out/<slug>-9x16-final.mp4 \
       -c:v libx264 -crf 23 -preset medium -b:v 6M \
       -c:a aac -b:a 128k \
       -movflags +faststart \
       out/<slug>-9x16-tiktok.mp4
```

`-movflags +faststart` moves moov atom to start → enables progressive playback in browsers.

## Recipe 6 — Audio-level normalization (EBU R128)

Different TTS providers output at different loudness. Normalize to broadcast standard:

```bash
ffmpeg -i public/voice.mp3 \
       -filter:a loudnorm=I=-16:TP=-1.5:LRA=11 \
       public/voice-normalized.mp3
```

Two-pass (better but slower) — use for final export, not iteration.

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

## Recipe 8 — Export GIF

```bash
# Two-pass GIF (palette-aware, smaller + better quality)
ffmpeg -i out/<slug>.mp4 \
  -vf "fps=15,scale=720:-1:flags=lanczos,palettegen=stats_mode=diff" \
  -y .taw-video/palette.png

ffmpeg -i out/<slug>.mp4 -i .taw-video/palette.png \
  -filter_complex "fps=15,scale=720:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5" \
  out/<slug>.gif
```

Result: ~30% smaller than single-pass, no banding.

## Recipe 9 — Probe video stats (for reviewer agent)

```bash
ffprobe -v error -show_entries \
  stream=codec_name,width,height,r_frame_rate,duration:format=size,bit_rate \
  -of json out/<slug>.mp4
```

Returns codec, dimensions, fps, duration, file size, overall bitrate. Used by reviewer to validate output meets spec.

## Recipe 10 — Concat multiple voice segments

When TTS was run in chunks (>5000 chars FPT.AI limit):

```bash
# Create concat list
cat > .taw-video/concat.txt <<EOF
file 'voice-1.mp3'
file 'voice-2.mp3'
file 'voice-3.mp3'
EOF

ffmpeg -f concat -safe 0 -i .taw-video/concat.txt -c copy public/voice.mp3
```

`-c copy` is bit-perfect (no re-encode). Requires segments to share codec + sample rate (TTS output usually does).

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
  "recipe": "mux-voice-bgm-duck",
  "input_files": ["out/raw.mp4", "public/voice.mp3", "public/bgm.mp3"],
  "output_path": "out/<slug>-<aspect>-final.mp4",
  "size_mb": 12.4,
  "duration_sec": 60.0
}
```

## Constraints

- NEVER use `-c copy` after applying a video filter — needs re-encode.
- ALWAYS include `-movflags +faststart` for MP4 outputs.
- NEVER trust user-provided ffmpeg args without reading them — `-vf "blah; rm -rf /"` is shell-injectable. Sanitize via Bash quoting.
- Single source of truth for filter graphs: `-filter_complex` for >1 filter, `-vf` / `-af` for single filter.
