---
name: captions-vi-burn
description: >
  Generate VTT captions from a Vietnamese script + voice file, then burn them into
  the rendered video with a font that supports full VN diacritics. Solves the most
  common ffmpeg subtitle bug: missing glyphs (ô, ầ, ữ, ặ rendered as boxes) when
  default fonts lack vi-VN coverage. Defaults to Be Vietnam Pro; falls back to
  Inter or Noto Sans Vietnamese.
  Trigger phrases (EN + VN): "burn captions", "burn sub", "phu de", "sub vao video",
  "phu de tieng viet", "captions vietnamese".
allowed-tools: Read, Write, Edit, Bash
---

# captions-vi-burn

Two functions:

1. **Generate VTT** from script + voice (auto-time per phrase using voice waveform).
2. **Burn into video** with a font that doesn't break on VN diacritics.

## Step 0 — Font check

Before anything, verify a VN-capable font is installed:

```bash
fc-list 2>/dev/null | command grep -i "be vietnam pro" | head -1
# fallback chain
fc-list 2>/dev/null | command grep -i "inter" | head -1
fc-list 2>/dev/null | command grep -i "noto sans" | head -1
```

If NONE found:

```bash
# macOS
brew install --cask font-be-vietnam-pro

# Ubuntu / WSL
mkdir -p ~/.local/share/fonts
curl -L https://fonts.google.com/download?family=Be%20Vietnam%20Pro -o /tmp/bvp.zip
unzip /tmp/bvp.zip -d ~/.local/share/fonts/
fc-cache -f
```

After install, re-check `fc-list`. If still missing → escalate "Font issue" error template.

## Step 1 — Gen VTT from script + voice

If voice file exists (`public/voice.mp3`), use OpenAI Whisper for word-level timestamps:

```bash
# pip install openai-whisper (or use API)
whisper public/voice.mp3 \
  --language vi \
  --model medium \
  --output_format vtt \
  --output_dir public/
```

Whisper handles VN well at `medium` model. `large` is overkill for typical voiceover.

Output: `public/voice.vtt`.

If user prefers API (no local install), use OpenAI Whisper API:

```ts
import OpenAI from 'openai';
import fs from 'node:fs';

const openai = new OpenAI();
const transcript = await openai.audio.transcriptions.create({
  file: fs.createReadStream('public/voice.mp3'),
  model: 'whisper-1',
  language: 'vi',
  response_format: 'vtt',
});
fs.writeFileSync('public/voice.vtt', transcript);
```

If voice file does NOT exist (kinetic-typography format, no voice), generate VTT from script + manual timing in `.taw-video/storyboard.md` (each phrase has duration).

## Step 2 — Cleanup VTT (VN-specific)

Whisper sometimes outputs decomposed Unicode (base + combining marks). Normalize to NFC:

```ts
import fs from 'node:fs/promises';

const raw = await fs.readFile('public/voice.vtt', 'utf8');
const normalized = raw.normalize('NFC');
await fs.writeFile('public/voice.vtt', normalized);
```

Without this, ffmpeg burn-in shows correct chars but they're 2 codepoints wide → spacing looks weird.

## Step 3 — Style config

Read `.taw-video/captions-style.json` (or use defaults):

```json
{
  "font": "Be Vietnam Pro",
  "fontSize": 28,
  "primaryColor": "&H00FFFFFF",
  "outlineColor": "&H00000000",
  "outline": 2,
  "shadow": 1,
  "alignment": 2,
  "marginV": 60
}
```

ASS color format: `&HBBGGRR` (alpha = 00 means opaque).

## Step 4 — Burn-in via ffmpeg

```bash
ffmpeg -i out/<slug>-<aspect>.mp4 \
  -vf "subtitles=public/voice.vtt:force_style='FontName=Be Vietnam Pro,FontSize=28,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,Outline=2,Shadow=1,Alignment=2,MarginV=60'" \
  -c:a copy \
  out/<slug>-<aspect>-subbed.mp4
```

**Critical detail**: `force_style` overrides VTT's own `<style>` blocks. Without it, ffmpeg falls back to default font (DejaVu / Liberation Sans) which has GAPS in VN coverage.

## Step 5 — Verify burn-in

Sample 3 frames where text is visible:

```bash
ffmpeg -ss 5 -i out/<slug>-<aspect>-subbed.mp4 -vframes 1 .taw-video/review/sub-check-1.jpg
ffmpeg -ss 15 -i out/<slug>-<aspect>-subbed.mp4 -vframes 1 .taw-video/review/sub-check-2.jpg
ffmpeg -ss 25 -i out/<slug>-<aspect>-subbed.mp4 -vframes 1 .taw-video/review/sub-check-3.jpg
```

If reviewer agent reports missing diacritics in any frame → the font font-cache is stale. Run `fc-cache -fv` and re-burn.

## Style preset library

Common style profiles user can pick:

### `clean`
Standard centered white sub with black outline.
```json
{ "fontSize": 28, "primaryColor": "&H00FFFFFF", "outline": 2, "alignment": 2 }
```

### `youtube-shorts`
Bigger, yellow accent, bottom-positioned, drop shadow.
```json
{ "fontSize": 36, "primaryColor": "&H0000FFFF", "outline": 3, "shadow": 2, "alignment": 2, "marginV": 120 }
```

### `tiktok`
Centered upper-third, white-on-black box (BorderStyle=4).
```json
{ "fontSize": 32, "primaryColor": "&H00FFFFFF", "outlineColor": "&H80000000", "borderStyle": 4, "alignment": 8, "marginV": 200 }
```

### `cinematic`
Italic, smaller, bottom edge, low contrast.
```json
{ "fontSize": 22, "fontStyle": "italic", "primaryColor": "&H00CCCCCC", "outline": 0, "alignment": 2, "marginV": 30 }
```

User picks via `/taw-video edit captions style=tiktok`.

## Common errors

### Diacritic shows as box (□)

Cause: font missing. Run `fc-list | command grep -i "be vietnam pro"`. If empty, install (Step 0).

### Diacritic shows as ?

Cause: ffmpeg can't decode the VTT (encoding mismatch). Force UTF-8:

```bash
file public/voice.vtt   # should say "UTF-8 Unicode"
# if not:
iconv -t UTF-8 public/voice.vtt > /tmp/fixed.vtt && mv /tmp/fixed.vtt public/voice.vtt
```

### Subs show but jitter

Whisper word-timestamps occasionally drift. Re-run with `--word_timestamps True` for finer alignment.

### Subs go off screen edge in 9:16

`marginV` too low. Vertical safe-area for 9:16: minimum 120 px from bottom (TikTok UI overlays).

## Skill output

```json
{
  "status": "ok",
  "vtt_path": "public/voice.vtt",
  "burnt_video": "out/<slug>-<aspect>-subbed.mp4",
  "font_used": "Be Vietnam Pro",
  "cue_count": 14,
  "verified_frames": 3
}
```

## Constraints

- ALWAYS NFC-normalize VTT before burn (Step 2).
- ALWAYS use `force_style` to override font (Step 4).
- NEVER burn into the original render — always output `-subbed.mp4` so user has both.
- For platforms that show their OWN captions (TikTok auto-generated), mark sub-track as soft instead of burn:
  ```bash
  ffmpeg -i in.mp4 -i voice.vtt -c copy -c:s mov_text -metadata:s:s:0 language=vie out.mp4
  ```
