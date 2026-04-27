# branch: ADVISOR

Routed here when user wants opinion / review / feedback on an existing video. **READ-ONLY** — never modify code or render artefacts. Output: written report.

**Prereq:** router classified `tier1 = ADVISOR`. Project should have a finished render at `out/<slug>.mp4` OR at least a storyboard at `.taw-video/storyboard.md`.

## Step 1 — Determine review scope

Parse user prose:

| Scope | Signals | Inputs to load |
|---|---|---|
| `script` | "lời thoại có ổn không", "review script", "voice over text" | `.taw-video/script.txt` |
| `storyboard` | "review storyboard", "cấu trúc video", "scene flow" | `.taw-video/storyboard.md` + `.taw-video/design.json` |
| `visual-quality` | "video có đẹp không", "có giống AI slop không", "thiết kế ổn chưa" | source code in `src/scenes/` + 4 random frame screenshots |
| `audio-sync` | "audio sync", "voice khớp với cảnh không", "timing có khớp không" | render + script + voice file |
| `subtitle` | "sub có đúng không", "phụ đề chuẩn dấu chưa" | captions VTT + render |
| `seo-thumb` | "thumbnail", "tiêu đề video", "SEO YT/TikTok" | metadata in `.taw-video/intent.json` |
| `full` | "review video", "danh gia video", or unspecified | all of the above |

Default to `full` if unclear.

## Step 2 — Run scope-specific checks

### 2a. `script`
- Length appropriate for format (60–180s for tutorial, 15–30s for kinetic, etc).
- VN tone consistent (no mixed Bắc/Nam without intent).
- Hook in first 3 seconds (matters for short-form).
- Call-to-action at end (or intentional cliffhanger).
- No filler words / repeated phrases.

### 2b. `storyboard`
- Scene count matches format norm (4–8 typical).
- Energy curve has rise + peak + resolution (not flat).
- Transitions varied (not all `fade`).
- Each scene ≥3s and ≤15s (otherwise pacing problem).
- Design tokens consistent (no scene defies palette).

### 2c. `visual-quality`
- Sample 4 frames at 25%, 50%, 75%, 90% of duration via ffmpeg:
  ```bash
  ffmpeg -i out/<slug>.mp4 -vf "select='eq(n,30)'" -vframes 1 .taw-video/review/frame-25.jpg
  ```
- For each frame, check (use `frontend-design` skill's anti-AI-slop guidelines):
  - Distinctive design choice OR generic "centered text + gradient" slop?
  - Typography hierarchy clear?
  - Whitespace deliberate?
  - Colour palette consistent across all 4 frames?
- Output: rating 1–5 + 2–3 specific actionable improvements.

### 2d. `audio-sync`
- Run ffmpeg to extract voice peaks:
  ```bash
  ffmpeg -i public/voice.mp3 -filter_complex "ebur128" -f null - 2>&1 | grep "peak"
  ```
- Cross-reference scene cut times in storyboard. Peaks within ±200ms of scene cut = good. Drift > 500ms = report.

### 2e. `subtitle`
- Check VTT file: any `?` or `�` chars where VN diacritics should be → font issue.
- Check burn-in render: extract a frame at 50% and visually inspect (display via image-aware analysis if possible).
- Check WPM (words per minute) — VN avg 130–160 WPM; faster = subs unreadable.

### 2f. `seo-thumb`
- Title length appropriate for platform (TikTok ≤100 chars, YT ≤60 effective).
- Hashtag relevance.
- Thumbnail: if no thumbnail exists, suggest gen one from frame at 5% mark with overlay text.

## Step 3 — Compose report

Output a Markdown report (no code changes). Format:

```markdown
# taw-video review: <slug>

## Tổng quan
<2–3 câu cảm nhận tổng>

## Điểm mạnh
- ...
- ...

## Điểm cần cải thiện
- **<scope>**: <vấn đề cụ thể>. Đề xuất: <action>.
- ...

## Đề xuất 3 bước làm tiếp (theo độ ưu tiên)
1. /taw-video edit canh 3 — <lý do>
2. /taw-video render 4k — <lý do>
3. ...
```

Save to `.taw-video/review-<YYMMDD-HHMM>.md`.

## Step 4 — Print summary to chat

Print top 3 findings (most impactful) + path to full report:

```
✓ Review xong (full report: .taw-video/review-260426-2120.md)

3 điểm chính:
  1. <điểm 1>
  2. <điểm 2>
  3. <điểm 3>

Anh muốn em fix luôn không? (gõ /taw-video edit ...)
```

## Step 5 — No commit

ADVISOR is read-only. The review file IS committed (it's a doc), but no source/render changes. Use:

```
docs(video): add quality review for <slug>
```

## Constraints

- ADVISOR NEVER modifies code or renders. If user asks "fix it", route them to EDIT branch.
- Don't run TTS or render during review (cost / time gate).
- Frames extracted for visual review go to `.taw-video/review/` (gitignored).
- Be specific in feedback — "tăng contrast giữa scene 2 và 3" beats "cải thiện thiết kế".
