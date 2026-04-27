# branch: CREATE

Routed here when user wants to make a new motion-graphic video from prose. Output is a **silent video** — text + visuals + optional BGM. User adds voice-over externally (CapCut, Premiere, DaVinci) if they want narration.

**Prereq:** router has classified `tier1 = CREATE` and written `.taw-video/intent.json`.

## Step 0 — Sub-classify the CREATE ask

| Case | Signals | Next step |
|---|---|---|
| `new-from-prose` | No `.taw-video/intent.json` clarifications yet AND user described topic+style | Step 1 — classify format, then full flow |
| `new-from-preset` | User typed `preset:<name>` OR mentioned preset name (tutorial, faceless, news, product, kinetic) | Step 1p — load preset, skip format classify |

If unsure, ask: "Anh muốn làm video kiểu gì? (tutorial, faceless channel, news recap, product demo, hoặc kinetic typography)"

---

## Step 1 — Classify format

Parse user prose. Assign exactly ONE:

- `tutorial-explainer` — how-to, step-by-step, motion graphic with on-screen text (45–120s)
- `faceless-channel` — kinetic text + b-roll style, hooks every 10–15s (45–120s)
- `news-recap` — quick news summary, kinetic headlines + data callouts (30–60s)
- `product-demo` — features → benefits → CTA, on-screen feature labels (20–45s)
- `kinetic-typography` — pure motion text, BGM-driven (15–30s)
- `other` — fallback; ask more clarify Qs

Write to `.taw-video/intent.json` under `format`.

## Step 1p — (Preset variant) Load preset

Valid presets: `tutorial-explainer`, `faceless-channel`, `news-recap`, `product-demo`, `kinetic-typography`.

If arg empty, show 5-item list and wait. If name doesn't match, find closest (edit distance ≤2) and ask "Did you mean X?".

Read `presets/<name>.md`. Extract `Pre-filled defaults`. Write into `.taw-video/intent.json` as `{format, raw, defaults, source: "preset"}`. Skip Step 2 → go to Step 3.

## Step 2 — Clarify (≤4 questions)

**If `mode == "yolo"`:** skip. Emit `⚡ YOLO mode — dùng smart defaults.` Generate sensible defaults (BGM = chill royalty-free OR none, palette per format default, 16:9 unless format is faceless/kinetic → 9:16). Go to Step 3.

**If `mode == "safe"`:** load `templates/clarify-questions.md`. Pick 3–4 Qs matching format. Ask in ONE message, numbered. WAIT for reply.

Append answers to `.taw-video/intent.json` under `clarifications`.

## Step 3 — Generate scene-text + storyboard

This step has TWO sub-outputs:

### 3a. Scene text (on-screen copy)

Spawn `script-writer` agent. Input: `.taw-video/intent.json` + format-specific prompt template. Output: `.taw-video/scene-text.json` — per-scene on-screen text (titles, headlines, callouts, bullets, CTAs).

NOT a narration script. Each scene gets a structured text payload that scene-coder will render visually.

### 3b. Storyboard

Spawn `storyboard-planner` agent. Input: `.taw-video/scene-text.json` + `.taw-video/intent.json`. Output: `.taw-video/storyboard.md` — 4–7 scenes with: scene id, duration, scene type (title-card / kinetic-quote / data-bar / etc.), motion description, transition, beat (energy 1–5).

Storyboard MUST include design tokens: palette (3–5 colors), typography (display + body fonts), motion-style (subtle / playful / aggressive / cinematic). Save to `.taw-video/design.json`.

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

**HARD RULE:** Even with rich context, safe mode MUST emit prompt and wait. User trades 1 message for the right to course-correct before 2–4 minutes of rendering.

## Step 5 — Spawn agent chain

Use Task tool. Order is FIXED.

1. **`scene-coder`** — input: `.taw-video/storyboard.md` + `.taw-video/scene-text.json` + `.taw-video/design.json`. Output: Remotion compositions in `src/scenes/`, root composition in `src/Root.tsx`, deps installed.

2. **`motion-tuner`** — input: scenes from step 1. Output: tuned easing + timing in scene files (no voice sync — pure aesthetic polish).

3. **`renderer`** — input: scenes (tuned). Steps:
   - Run `npx remotion render` to MP4 at primary aspect ratio.
   - If BGM file present at `public/bgm.mp3`, Remotion bundles it via `<Audio>` component (no separate mux step).
   - Save to `out/<slug>-<aspect>.mp4`.

4. **`video-reviewer`** — visual quality + platform safe-area + diacritic burn check. Reports pass/fail.

Between steps emit `✓ Done: <3-word summary>` (e.g. `✓ Done: scenes coded`).

## Step 6 — Error recovery

On agent failure:
1. Compact error to ≤100 tokens.
2. Retry SAME agent ONCE with error as extra input.
3. If retry fails: write `.taw-video/checkpoint.json` `{last_step, last_error, next_action: "/taw-video <suggested fix>"}`, emit error template (translated via `error-to-vi`), stop.

Common video-specific error patterns to reference:
- `ffmpeg: Unknown encoder 'libx264'` → user needs full ffmpeg → `brew reinstall ffmpeg`
- `Remotion: Composition not found` → scene-coder didn't register composition → re-spawn scene-coder
- `Font not found: Be Vietnam Pro` → install font or change to fallback

Never retry > 1. Never silently skip.

## Step 7 — Output handoff

On Step 5 success, emit final message (VN default):

```
✓ Video xong rồi anh: out/<slug>-<aspect>.mp4 (<duration>s, <size>MB)

Đây là video silent (không có voice). Nếu anh muốn thêm giọng đọc:
  → Mở CapCut / Premiere / DaVinci, import file MP4, thu/ghép voice là xong.

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

Invoke `taw-video-commit` skill with `type=feat` `scope=video`:

```
feat(video): scaffold tutorial about <topic> (<duration>s, <aspect>)

- src/Root.tsx + src/scenes/* (5 scenes)
- design.json: <palette name> + <font name>
- silent render — voice can be added externally
```

Render artefacts (`out/*.mp4`) are gitignored — they don't enter the commit. Source code only.

## Constraints

- 4–7 scenes max for v0.1.
- 1 primary aspect ratio per CREATE run — additional ratios via separate `/taw-video render <ratio>` calls.
- Silent video by default. BGM optional (file at `public/bgm.mp3`). Voice is OUT OF SCOPE — user adds externally.
- Never auto-upload to YT/TikTok — user uploads manually.
