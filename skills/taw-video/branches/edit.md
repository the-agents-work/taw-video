# branch: EDIT

Routed here when user wants to modify scenes, script, voice, or assets of an existing video project. Lighter flow than CREATE — no agent chain, scoped change, re-render only what's affected.

**Prereq:** router classified `tier1 = EDIT`. There MUST be an existing project state (`.taw-video/intent.json` + `src/scenes/` files). If not, escalate: "Em không thấy video nào trong folder này — anh muốn `/taw-video tạo mới` không?"

## Step 1 — Identify the edit target

Parse user prose to determine WHAT to change. Try keyword match:

| Target | Signals | What to load |
|---|---|---|
| `scene` (specific scene) | "cảnh 2", "scene 3", "phần intro", "phần outro", "đoạn cuối" | Read `src/scenes/scene-<n>.tsx` |
| `script` | "lời thoại", "script", "narration", "voice over text" | Read `.taw-video/script.txt` |
| `voice` | "giọng", "voice", "đổi giọng", "TTS", "thay người đọc" | Read voice config from `.taw-video/intent.json` |
| `bgm` | "nhạc nền", "BGM", "background music", "đổi nhạc" | Read music config |
| `captions` | "sub", "phụ đề", "captions", "subtitle" | Read `.taw-video/captions.vtt` |
| `palette` | "màu", "color", "palette", "đổi màu chủ đạo" | Read `.taw-video/design.json` |
| `font` | "font", "typography", "đổi chữ" | Read `.taw-video/design.json` |
| `pacing` | "nhanh hơn", "chậm hơn", "rút ngắn", "kéo dài", "shorten", "extend" | Read scene durations |
| `aspect` | (route to RENDER instead) | Re-classify as RENDER |

If user prose mentions multiple targets ("đổi giọng và nhạc nền") → handle as multi-target: do each in sequence.

If unclear, ask ONE clarifying question with the menu above.

## Step 2 — Apply the change

Each target has a specific recipe. Pick the matching block.

### 2a. `scene` change

1. Read current scene file.
2. Parse user's specific ask ("ngắn lại 1 giây", "đổi text 'X' thành 'Y'", "thêm icon chỉ xuống").
3. Edit the scene file (Edit tool, never Write — preserve structure).
4. If duration changed, update parent `src/Root.tsx` composition `durationInFrames`.
5. Re-run `npx remotion preview` (background, 5s timeout) to verify it compiles. If TS error: `error-to-vi` skill translates, escalate.

### 2b. `script` change

1. Edit `.taw-video/script.txt`.
2. Confirm with user: "Em sẽ regenerate giọng đọc — phí TTS ~$X. Tiếp tục? (y/n)" — this is a CONFIRM ONCE because TTS costs money.
3. On `y`, invoke `voice-tts-vi` skill to regen `public/voice.mp3`.
4. Regen captions VTT via `captions-vi-burn` skill.
5. If pacing changes, prompt user: "Voice mới dài hơn ~Xs, em có nên kéo dài cảnh tương ứng không?"

### 2c. `voice` change

1. Show available voices (call `voice-tts-vi` with `--list` arg or read its catalog).
2. Wait for pick.
3. Update `.taw-video/intent.json` voice config.
4. Same as 2b from step 2.

### 2d. `bgm` change

1. If user named a track ("Lofi Type Beat 02") → search local `assets/bgm/` first. If not found, suggest royalty-free sources (`bgm-picker` skill).
2. Update `src/Root.tsx` audio import.
3. Re-mix via `ffmpeg-pipeline` (sidechain duck against voice).

### 2e. `captions` change (style not text)

1. Edit caption styles in `.taw-video/captions-style.json` (font size, color, position, stroke).
2. Regen VTT or burn-in via `captions-vi-burn`.

### 2f. `palette` / `font` change

1. Edit `.taw-video/design.json`.
2. Scenes pull from this — no per-scene edit needed (assuming scene-coder used the design tokens correctly).
3. Re-run `npx remotion preview` to verify.

### 2g. `pacing` change

1. For "shorten Xs" / "extend Xs": adjust the named scene's `durationInFrames` in scene component. 1s = 30 frames at default fps=30.
2. Update parent composition `durationInFrames` (sum of children + transitions).
3. If voice exists and pacing forces voice trim/extend: warn user, suggest re-TTS.

## Step 3 — Re-render (scoped)

After edits, ask: "Render lại luôn không? (y / sau)"

- `y` → invoke `renderer` agent on the changed composition only. Output to `out/<slug>-<aspect>-v<n>.mp4` (incremented version, don't overwrite).
- `sau` → save state, exit. User can run `/taw-video render` later.

## Step 4 — Commit

Invoke `taw-commit` with appropriate type:
- Scene/script change → `feat(video): <summary>`
- Voice/BGM swap → `chore(video): <summary>`
- Style tweak (palette/font) → `style(video): <summary>`
- Pacing fix → `fix(video): <summary>`

## Step 5 — Done

Emit summary:

```
✓ Đã sửa: <target>
  out/<slug>-<aspect>-v<n>.mp4 (Xs, YMB)

Bước tiếp:
  /taw-video edit <khác>     (sửa thêm)
  /taw-video render 9:16     (xuất tỉ lệ khác)
```

## Constraints

- Edit branch NEVER spawns full agent chain (no planner/researcher).
- Edit branch CAN spawn `scene-coder` for non-trivial scene changes (>10 lines diff).
- Edit branch ALWAYS preserves original render until new one succeeds.
- TTS regen requires user confirmation (cost gate).
