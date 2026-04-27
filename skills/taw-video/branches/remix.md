# branch: REMIX

Routed here when user wants to reuse an existing video's structure (scenes, motion style, palette, BGM) but with new content. Lighter than CREATE (skips storyboard from scratch); heavier than EDIT (regenerates scene text + re-renders).

**Prereq:** router classified `tier1 = REMIX`. There must be a "source video" to remix:
- Current folder is itself a taw-video project → use it as source
- User points to another folder: `/taw-video remix from ../my-old-video`
- User says "tuần trước" / "last week's" → look in `~/.taw-video-history/` (if local cache exists) or ask path

## Step 1 — Locate source

Try in order:
1. Current folder has `.taw-video/storyboard.md` → use it.
2. User prose contains a path → resolve it.
3. Otherwise ask: "Anh muốn remix từ folder nào? (paste path hoặc tên dự án trong ~/Documents/GitHub/)"

Read source's:
- `.taw-video/storyboard.md` — scene structure, beats, transitions
- `.taw-video/design.json` — palette + typography + motion style
- `.taw-video/scene-text.json` — on-screen text payload (we'll replace content)
- `.taw-video/intent.json` — original format + clarifications
- `src/scenes/*.tsx` — actual scene components

## Step 2 — Capture style fingerprint

Generate `.taw-video/style-fingerprint.json` from source:

```json
{
  "scene_structure": ["title-card", "kinetic-quote", "data-bar", "comparison-split", "end-card"],
  "scene_durations_sec": [3, 8, 12, 10, 5],
  "palette": {"primary": "#1a1a2e", "accent": "#fbbf24", "text": "#e5e7eb"},
  "typography": {"display": "Be Vietnam Pro Bold", "body": "Inter"},
  "motion_style": "playful",
  "transitions": ["fade", "swipe-left", "scale-pop", "fade"],
  "bgm_mood": "chill-electronic",
  "aspect_primary": "9:16"
}
```

This is the "look" we keep.

## Step 3 — Capture new content

Parse user prose for the NEW topic.

If user provided full topic → Step 4. Else ask: "Anh remix với chủ đề mới nào? (1 câu mô tả nội dung)"

Write to `.taw-video/intent.json` as `{format: <from source>, raw: <new topic>, source: "remix-of:<source-path>"}`.

## Step 4 — Generate new scene text (matches structure)

Spawn `script-writer` agent with extra constraint:

```
Generate new scene text that:
- Matches the scene structure from style-fingerprint.json (5 scenes: title-card / kinetic-quote / data-bar / comparison-split / end-card)
- Matches the per-scene visual density from style-fingerprint.json (so animation timing still fits)
- Topic: <user new topic>
```

Output: `.taw-video/scene-text.json` (new content).

## Step 5 — Storyboard auto-fill

Use source's storyboard as template. Replace scene CONTENT (text, data points, images referenced) with new ones. KEEP: scene types, durations, transitions, palette, typography, motion-style.

Write `.taw-video/storyboard.md` (remixed). Save updated `.taw-video/design.json` (copy from source unless user asked to change palette/font).

## Step 6 — Approval gate (lighter than CREATE)

**If `mode == "yolo"`:** skip.

**If `mode == "safe"`:** echo storyboard delta (only changed content rows) + emit:

```
Remix với cấu trúc cũ + nội dung mới — ok chưa anh? (yes / sửa / huỷ)
```

WAIT.

## Step 7 — Run pipeline (subset of CREATE)

Same as CREATE Step 5, but:
- SKIP `scene-coder` initial scaffold IF scenes already exist in current folder (we're remixing in-place).
- IF remixing from external source folder, COPY `src/scenes/*.tsx` from source first, then `scene-coder` adapts CONTENT (text strings, data values) — not structure.
- SPAWN `motion-tuner` if any scene's text length differs ≥30% from source (animation timing needs re-fit).
- SPAWN `renderer` + `video-reviewer` as usual.

## Step 8 — Output

Same as CREATE Step 7 but mention remix lineage:

```
✓ Remix xong: out/<new-slug>-<aspect>.mp4
  Lấy phong cách từ: <source-path>
  Nội dung mới: <new topic>

Bước tiếp:
  /taw-video render <khác tỉ lệ>
  /taw-video edit canh <n>
```

## Step 9 — Commit

```
feat(video): remix <source-name> with new content about <topic>

- scene-text.json regenerated
- scene structure preserved from source
- palette/font/motion-style kept

Refs: remix-of:<source-path>
```

## Constraints

- REMIX never changes scene STRUCTURE — only content. If user wants different structure, they should run CREATE.
- BGM may need swap if mood mismatch with new tone — check via `bgm-picker` skill.
