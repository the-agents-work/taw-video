# branch: CREATE

Routed here when user wants to make a new video from prose. This is the "full pipeline" flow.

**Prereq:** router has classified `tier1 = CREATE` and written `.taw-video/intent.json`.

## Step 0 — Sub-classify the CREATE ask

| Case | Signals | Next step |
|---|---|---|
| `new-from-prose` | No `.taw-video/intent.json` clarifications yet AND user described topic+style | Step 1 — classify format, then Steps 2-9 full flow |
| `new-from-preset` | User typed `preset:<name>` OR mentioned preset name (tutorial, faceless, news, product, kinetic) | Step 1p — load preset, skip format classify, jump to Step 2 |

If unsure, ask: "Anh muốn làm video kiểu gì? (tutorial, faceless channel, news recap, product demo, hoặc kinetic typography)"

---

## Step 1 — Classify format

Parse user prose. Assign exactly ONE:

- `tutorial-explainer` — how-to, step-by-step, educational (60–180s)
- `faceless-channel` — voiceover + b-roll style (YouTube/TikTok faceless, 60–180s)
- `news-recap` — quick news summary, kinetic text + headlines (45–90s)
- `product-demo` — show product features, screenshots, benefits (30–60s)
- `kinetic-typography` — pure motion text, no voice required (15–30s)
- `other` — fallback; ask more clarify Qs

Write to `.taw-video/intent.json` under `format`.

## Step 1p — (Preset variant) Load preset

Valid presets: `tutorial-explainer`, `faceless-channel`, `news-recap`, `product-demo`, `kinetic-typography`.

If arg empty, show 5-item list and wait. If name doesn't match, find closest (edit distance ≤2) and ask "Did you mean X?".

Read `presets/<name>.md`. Extract `Pre-filled defaults` (voice, palette, typography, scene count, duration, aspect ratio). Write into `.taw-video/intent.json` as `{format, raw, defaults, source: "preset"}`. Skip Step 2 → go to Step 3.

## Step 2 — Clarify (≤5 questions)

**If `mode == "yolo"`:** skip. Emit `⚡ YOLO mode — dùng smart defaults.` Generate sensible defaults (voice = FPT.AI female Northern, BGM = chill royalty-free, palette per format default, 16:9 landscape unless format is faceless/kinetic → 9:16). Go to Step 3.

**If `mode == "safe"`:** load `templates/clarify-questions.md`. Pick 3–5 Qs matching format. Ask in ONE message, numbered. WAIT for reply.

Append answers to `.taw-video/intent.json` under `clarifications`.

## Step 3 — Generate script + storyboard

This step has TWO sub-outputs:

### 3a. Script (narration text)

Spawn `script-writer` agent. Input: `.taw-video/intent.json` + format-specific prompt template. Output: `.taw-video/script.txt` — TTS-ready narration with `[scene-N]` markers.

For `kinetic-typography` format: skip narration, generate text-only script with timing (each phrase + duration in seconds).

### 3b. Storyboard

Spawn `storyboard-planner` agent. Input: `.taw-video/script.txt` + `.taw-video/intent.json`. Output: `.taw-video/storyboard.md` — 4–8 scenes with: scene id, duration, description, visual elements, transition, beat (energy level 1–5).

Storyboard MUST include design tokens: palette (3 colors), typography (display + body fonts), motion-style (subtle / playful / aggressive). Save to `.taw-video/design.json`.

## Step 4 — Storyboard approval gate (HARD GATE)

**If `mode == "yolo"`:** skip. Emit `⚡ YOLO — auto-approved storyboard, đang code...` Go to Step 5.

**If `mode == "safe"`:** echo storyboard table + design tokens as code block. Then emit EXACTLY:

```
Storyboard này ok chưa anh? (gõ: yes / sửa / huỷ)
```

WAIT. Do NOT spawn scene-coder until reply.

- `yes` / `ok` / `có` / `được` / `ừ` / `chạy đi` / `lam di` → Step 5
- `sửa` / `edit` → ask what to change, regenerate Step 3, re-gate
- `huỷ` / `cancel` → write `{"status":"cancelled"}` to `.taw-video/checkpoint.json`, emit "Đã huỷ. Gõ /taw-video lúc nào sẵn sàng.", exit

**HARD RULE:** Even with rich context, safe mode MUST emit prompt and wait. User trades 1 message for the right to course-correct before 3–5 minutes of render + TTS API spend.

## Step 5 — Spawn agent chain

Use Task tool. Order is FIXED. Each step waits for previous EXCEPT 5.2 (parallel TTS + scene coding when format isn't kinetic).

1. **`scene-coder`** — input: `.taw-video/storyboard.md` + `.taw-video/design.json` + research reports (if researcher was spawned). Output: Remotion compositions in `src/scenes/`, root composition in `src/Root.tsx`, deps installed.

2. **PARALLEL** (only when format has voice — skip for kinetic-typography):
   - **`voice-tts-vi`** (skill, not agent) — input: `.taw-video/script.txt` + voice config. Output: `public/voice.mp3` (or `.wav`).
   - **`motion-tuner` agent** — input: scenes from 5.1. Output: tuned easing + timing in scene files.

   **HOW to spawn parallel:** ONE assistant message, TWO Task tool_use blocks back-to-back in same `<function_calls>`. Sequential = ~30s wasted.

3. **`renderer`** — input: scenes (tuned) + voice file + captions. Steps:
   - Run `npx remotion render` to MP4 at primary aspect ratio.
   - Generate captions VTT from script using `captions-vi-burn` skill (handles VN diacritics).
   - Mux video + voice + captions via `ffmpeg-pipeline` skill.
   - Save to `out/<slug>-<aspect>.mp4`.

4. **`video-reviewer`** — runs visual + audio sync checks:
   - Random-frame screenshot 4 frames, eyeball check (does it look like AI slop or distinctive?).
   - Audio sync: pick 3 voice peaks, check scene cut alignment within ±200ms.
   - Subtitle correctness: VTT renders all VN diacritics (no � chars in burn).
   - Reports pass/fail to orchestrator.

Between steps emit `✓ Done: <3-word summary>` (e.g. `✓ Done: scenes coded`).

## Step 6 — Error recovery

On agent failure:
1. Compact error to ≤100 tokens.
2. Retry SAME agent ONCE with error as extra input.
3. If retry fails: write `.taw-video/checkpoint.json` `{last_step, last_error, next_action: "/taw-video <suggested fix>"}`, emit error template (translated via `error-to-vi`), stop.

Common video-specific error patterns the FIX hint should reference:
- `ffmpeg: Unknown encoder 'libx264'` → user needs full ffmpeg, not minimal build → suggest `brew reinstall ffmpeg --with-x264`
- `Remotion: Composition not found` → scene-coder didn't register composition in Root.tsx → re-spawn scene-coder
- `TTS: insufficient credits` → user needs to top up provider or switch provider
- `Font not found: Be Vietnam Pro` → need to install font or change to fallback

Never retry > 1. Never silently skip.

## Step 7 — Output handoff

On Step 5 success, emit final message (VN default):

```
✓ Video xong rồi anh: out/<slug>-<aspect>.mp4 (<duration>s, <size>MB)

Bước tiếp:
  /taw-video render 9:16        (xuất ra TikTok/Shorts)
  /taw-video edit canh <n>      (sửa cảnh cụ thể)
  /taw-video review video       (em góp ý chất lượng)
```

For EN: same structure in English.

Update `.taw-video/checkpoint.json`:
```json
{
  "status": "ready",
  "last_branch": "create",
  "last_render_path": "out/<slug>-16x9.mp4",
  "duration_sec": 60,
  "size_mb": 12.3,
  "format": "tutorial-explainer"
}
```

## Step 8 — Commit (auto)

Invoke `taw-video-commit` skill with `type=feat` `scope=video` and a generated subject like:

```
feat(video): scaffold tutorial about ChatGPT (~60s, 1080p)

- src/Root.tsx + src/scenes/* (5 scenes)
- public/voice.mp3 generated via FPT.AI (female North)
- captions burnt with Be Vietnam Pro font
```

Render artefacts (`out/*.mp4`, `public/voice.mp3`) are gitignored — they don't enter the commit. Source code only.

## Constraints

- 4–8 scenes max for v0.1 — more = video too long for typical short-form.
- 1 voice provider per video — don't mix.
- 1 primary aspect ratio per CREATE run — additional ratios via separate `/taw-video render <ratio>` calls.
- Never auto-upload to YT/TikTok — user uploads manually (intentional, prevents accidental publish).
