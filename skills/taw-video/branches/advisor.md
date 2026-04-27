# branch: ADVISOR

Routed here when user wants opinion / review / feedback on an existing video. **READ-ONLY** — never modify code or render artefacts. Output: written report.

**Prereq:** router classified `tier1 = ADVISOR`. Project should have a finished render at `out/<slug>.mp4` OR at least a storyboard at `.taw-video/storyboard.md`.

## Step 1 — Determine review scope

Parse user prose:

| Scope | Signals | Inputs to load |
|---|---|---|
| `scene-text` | "text có ổn không", "câu này hay không", "review chữ" | `.taw-video/scene-text.json` |
| `storyboard` | "review storyboard", "cấu trúc video", "scene flow" | `.taw-video/storyboard.md` + `.taw-video/design.json` |
| `visual-quality` | "video có đẹp không", "có giống AI slop không", "thiết kế ổn chưa" | source code in `src/scenes/` + 4 random frame screenshots |
| `diacritics` | "dấu tiếng việt", "chữ có bị lỗi không" | render + sample frames where text is large |
| `seo-thumb` | "thumbnail", "tiêu đề video", "SEO YT/TikTok" | metadata in `.taw-video/intent.json` |
| `full` | "review video", "danh gia video", or unspecified | all of the above |

Default to `full` if unclear.

## Step 2 — Run scope-specific checks

### 2a. `scene-text`
- Hook in first scene clear (≤6 words, grabs attention)?
- Phrasing concise (≤10 words per kinetic frame, ≤15 per data-bar label)?
- VN tone consistent (no Bắc/Nam mix unless intent)?
- CTA at end (or intentional cliffhanger)?
- No filler words / repeated phrases.

### 2b. `storyboard`
- Scene count appropriate (4–7 typical for short-form)?
- Energy curve has rise + peak + resolution (not flat)?
- Transitions varied (not all `fade`)?
- Each scene 2–12s; outside this range, pacing problem.
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

### 2d. `diacritics`
- Extract 3 frames where VN text with dấu (ầ, ô, ữ, ặ) is prominent.
- Check no `□` or `?` chars (font missing diacritics).
- If issue, suggest font fallback chain: Be Vietnam Pro → Inter → Noto Sans Vietnamese.

### 2e. `seo-thumb`
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

## Điểm cần cải thiện
- **<scope>**: <vấn đề cụ thể>. Đề xuất: <action>.

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

## Step 5 — Commit (doc only)

ADVISOR is read-only. The review file IS committed (it's a doc), but no source/render changes. Use:

```
docs(video): add quality review for <slug>
```

## Constraints

- ADVISOR NEVER modifies code or renders. If user asks "fix it", route them to EDIT branch.
- Don't render during review (time gate).
- Frames extracted for visual review go to `.taw-video/review/` (gitignored).
- Be specific in feedback — "tăng contrast giữa scene 2 và 3" beats "cải thiện thiết kế".
