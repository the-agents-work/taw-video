# branch: EDIT

Routed here when user wants to modify scenes, on-screen text, or assets of an existing motion-graphic project. Lighter flow than CREATE — no full agent chain, scoped change, re-render only what's affected.

**Prereq:** router classified `tier1 = EDIT`. There MUST be an existing project state (`.taw-video/intent.json` + `src/scenes/` files). If not, escalate: "Em không thấy video nào trong folder này — anh muốn `/taw-video tạo mới` không?"

## Step 1 — Identify the edit target

Parse user prose to determine WHAT to change. Try keyword match:

| Target | Signals | What to load |
|---|---|---|
| `scene` (specific scene) | "cảnh 2", "scene 3", "phần intro", "phần outro", "đoạn cuối" | Read `src/scenes/scene-<n>.tsx` |
| `text` | "text", "chữ", "câu này sai", "đổi text" | Read `.taw-video/scene-text.json` |
| `bgm` | "nhạc nền", "BGM", "background music", "đổi nhạc" | Read music config |
| `palette` | "màu", "color", "palette", "đổi màu chủ đạo" | Read `.taw-video/design.json` |
| `font` | "font", "typography", "đổi chữ" | Read `.taw-video/design.json` |
| `pacing` | "nhanh hơn", "chậm hơn", "rút ngắn", "kéo dài", "shorten", "extend" | Read scene durations |
| `aspect` | (route to RENDER instead) | Re-classify as RENDER |

If user prose mentions multiple targets ("đổi màu và rút ngắn cảnh 2") → handle as multi-target: do each in sequence.

If unclear, ask ONE clarifying question with the menu above.

## Step 2 — Apply the change

### 2a. `scene` change

1. Read current scene file.
2. Parse user's specific ask ("ngắn lại 1 giây", "đổi text 'X' thành 'Y'", "thêm icon chỉ xuống").
3. Edit the scene file (Edit tool, never Write — preserve structure).
4. If duration changed, update parent `src/Root.tsx` composition `durationInFrames`.
5. Smoke-build: `npx remotion bundle src/index.ts /tmp/remotion-bundle 2>&1 | tail -5`. If TS error: `error-to-vi` translates, escalate.

### 2b. `text` change

1. Edit `.taw-video/scene-text.json` (the on-screen text payload).
2. Scenes pull from this — find affected scene component(s) and update prop refs.
3. Smoke-build to verify.

### 2c. `bgm` change

1. If user named a track ("Lofi Type Beat 02") → search local `assets/bgm/` first. If not found, suggest royalty-free sources via `bgm-picker` skill.
2. Update `src/Root.tsx` audio import.
3. Re-render needed (no separate mux step — Remotion bundles audio in).

### 2d. `palette` / `font` change

1. Edit `.taw-video/design.json`.
2. Scenes pull from this — no per-scene edit needed (assuming scene-coder used the design tokens correctly).
3. Smoke-build to verify.

### 2e. `pacing` change

1. For "shorten Xs" / "extend Xs": adjust the named scene's `durationInFrames` in scene component. 1s = 30 frames at default fps=30.
2. Update parent composition `durationInFrames` (sum of children + transitions).

## Step 3 — Re-render (scoped)

After edits, ask: "Render lại luôn không? (y / sau)"

- `y` → invoke `renderer` agent on the changed composition only. Output to `out/<slug>-<aspect>-v<n>.mp4` (incremented version, don't overwrite).
- `sau` → save state, exit. User can run `/taw-video render` later.

## Step 4 — Commit

Invoke `taw-video-commit` with appropriate type:
- Scene/text change → `feat(video): <summary>` or `fix(video): <summary>`
- BGM swap → `chore(video): <summary>`
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
