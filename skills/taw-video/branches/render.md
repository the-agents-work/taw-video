# branch: RENDER

Routed here when user wants to re-export an existing video project to a different aspect ratio, format, quality, or codec. Mechanical, no agent chain, no LLM creativity needed.

**Prereq:** router classified `tier1 = RENDER`. Project must have `src/Root.tsx` (Remotion compositions defined) and `package.json` with `remotion` dep.

## Step 1 — Parse render target

User prose maps to render config. Common patterns:

| User says | Aspect | Resolution | Use case |
|---|---|---|---|
| "9:16", "shorts", "tiktok", "reels" | 9:16 | 1080×1920 | TikTok, YT Shorts, IG Reels |
| "1:1", "instagram feed", "square" | 1:1 | 1080×1080 | IG feed |
| "16:9", "landscape", "youtube" | 16:9 | 1920×1080 | YT, web |
| "4k", "uhd" | (preserve aspect) | 3840×2160 | High-quality master |
| "720p" | (preserve aspect) | 1280×720 | Low-bandwidth |
| "gif" | (preserve aspect) | 720×—  | Twitter, Slack |
| "webm" | (preserve aspect) | 1080×—  | Web, smaller file |

Write parsed config to `.taw-video/render-target.json`:

```json
{
  "aspect": "9:16",
  "resolution": "1080x1920",
  "format": "mp4",
  "codec": "h264",
  "bitrate": "6M"
}
```

If multiple aspects mentioned ("9:16 và 1:1"), set `aspects: ["9:16", "1:1"]` and loop.

## Step 2 — Check for aspect-specific composition

Read `src/Root.tsx`. Remotion projects following taw-video convention have one composition per aspect:

```tsx
<Composition id="main-16x9" width={1920} height={1080} ... />
<Composition id="main-9x16" width={1080} height={1920} ... />
<Composition id="main-1x1"  width={1080} height={1080} ... />
```

- If composition for target aspect EXISTS → skip to Step 3.
- If MISSING → spawn `scene-coder` with input "add 9:16 composition reusing existing scene-* with responsive layout". Each scene component should already accept aspect-aware props if scene-coder followed convention; if not, scene-coder adapts. This sub-step is auto, no user gate.

## Step 3 — Run render

Bash:

```bash
npx remotion render \
  src/index.ts \
  main-9x16 \
  out/<slug>-9x16.mp4 \
  --codec=h264 \
  --crf=23 \
  --pixel-format=yuv420p \
  --concurrency=4
```

Variables:
- `--codec`: `h264` (default), `h265` (smaller, slower), `vp9` (webm)
- `--crf`: 18 (best quality, big file) … 28 (small file, lossy). Default 23.
- `--concurrency`: scale with cores; default 4.

For GIF: use `--codec=gif --quality=80 --gif-loop` instead of MP4 args.

Pipe output to log; on error invoke `error-to-vi` skill to translate stderr.

## Step 4 — Mux audio + captions (if not already in Remotion source)

If voice + captions are NOT in the Remotion `<Audio>` / `<Caption>` composition (i.e. user wants to add them at this stage), invoke `ffmpeg-pipeline` skill:

```bash
ffmpeg -i out/<slug>-<aspect>.mp4 \
       -i public/voice.mp3 \
       -c:v copy -c:a aac \
       -map 0:v -map 1:a \
       out/<slug>-<aspect>-final.mp4
```

For burn-in subs, add `-vf "subtitles=public/captions.vtt:force_style='FontName=Be Vietnam Pro,FontSize=24'"` (handled by `captions-vi-burn` skill which fixes VN diacritic font issues).

## Step 5 — Report

Emit (VN default):

```
✓ Render xong: out/<slug>-9x16.mp4
  Tỉ lệ: 9:16 (1080×1920)
  Thời lượng: <Xs>
  Size: <YMB>
  Codec: H.264

Bước tiếp:
  /taw-video render <khác tỉ lệ>
  Upload TikTok/Shorts: file đã sẵn dưới ./out/
```

Update `.taw-video/checkpoint.json`:

```json
{
  "status": "rendered",
  "last_branch": "render",
  "last_render_path": "out/<slug>-9x16.mp4",
  "all_renders": ["out/<slug>-16x9.mp4", "out/<slug>-9x16.mp4"]
}
```

## Step 6 — No commit

RENDER produces only artefacts (gitignored). NO commit unless `scene-coder` was spawned in Step 2 to add a new composition — in that case, `taw-video-commit` with `type=chore scope=video subject="add <aspect> composition"`.

## Constraints

- NEVER overwrite an existing render. Use versioned filenames if same aspect re-rendered.
- Render is parallel-safe per aspect (different output files), but DO NOT run >2 renders simultaneously on user's machine — Remotion is CPU-heavy.
- For Remotion Lambda (cloud render), check `.env.local` for `REMOTION_AWS_ACCESS_KEY_ID` — if present, offer `--lambda` flag. Otherwise local render only.
- Estimate time before render: typical Remotion render is ~realtime (60s video = 60s render at default settings). 4K + complex scenes can hit 5× realtime. Warn user if estimated > 3 minutes.
