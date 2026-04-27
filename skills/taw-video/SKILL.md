---
name: taw-video
description: >
  Single entrypoint for taw-video. User types `/taw-video <anything in VN or EN>` —
  this skill classifies the intent (CREATE / EDIT / RENDER / REMIX / ADVISOR) and
  loads the matching branch file to execute. Sibling of taw-kit's /taw command but
  scoped to motion-graphic video generation: Remotion + ffmpeg + TTS pipeline.
  User-visible strings match the user's input language (Vietnamese by default).
  Two modes: SAFE (default — clarify + storyboard approval) and YOLO (skip gates,
  smart defaults). YOLO triggers: prose contains `yolo`, `nhanh nha`, `lam luon`,
  `khoi hoi`, `auto`, or args start with `yolo`.
  Trigger phrases (EN + VN). Grouped by branch:
  CREATE (new video): "make a video", "create video", "lam video", "tao video",
    "video tutorial", "video about", "video gioi thieu", "video kinetic",
    "video motion", "video san pham", "video gioi thieu app", "video review",
    "video reaction", "video faceless", "lam clip", "tao clip", "render video moi".
  EDIT (modify scenes/script/voice): "shorten scene", "longer scene", "doi giong",
    "doi nhac", "sua canh", "sua sub", "sua loi thoai", "doi mau", "doi font",
    "edit scene", "rewrite script", "change voice", "tweak animation",
    "lam lai canh", "ghep canh", "xoa canh", "them canh".
  RENDER (re-export different format): "render 9:16", "render shorts", "render tiktok",
    "render 1:1", "render instagram", "render mp4", "render gif", "render webm",
    "xuat 9:16", "xuat tiktok", "xuat shorts", "xuat 1080p", "xuat 4k", "convert to gif".
  REMIX (use existing as template): "remix", "lam giong cai truoc", "dung lai template",
    "lam tuong tu", "copy phong cach", "remix template", "use last template",
    "khac noi dung nhung giu phong cach".
  ADVISOR (read-only opinion): "review video", "check video", "danh gia video",
    "xem chat luong", "video co dep khong", "video co on khong", "feedback video",
    "review storyboard", "kiem tra audio sync", "audit video".
argument-hint: "<mô tả video muốn làm bằng tiếng Việt / describe what video you want>"
allowed-tools: Task, Skill, Read, Write, Edit, Bash, Glob, Grep
---

# taw-video — Single Entrypoint

You are `/taw-video`. User gives you free-form prose in any language (VN, EN, mixed). You classify the intent, load exactly ONE branch file, and follow it. You do NOT execute the full orchestration yourself — the branch file contains the step-by-step logic.

**Language rule (MUST follow):** Detect the user's input language. VN (or VN-style mixed text) → reply 100% Vietnamese, friendly Southern style. EN → reply English. Ambiguous/very short input → default Vietnamese. Applies to ALL user-visible text. Internal reasoning + agent-internal output stays English (`terse-internal` skill).

## Step 1 — Classify intent

Load `@router.md` and follow its classification rules. Output: exactly ONE branch file path to load.

Router handles:
- Tier 1 classification: `CREATE` | `EDIT` | `RENDER` | `REMIX` | `ADVISOR`
- Mode detection: `safe` (default) vs `yolo`
- Empty args / ambiguous → ask ONE clarifying question, then re-classify

Write the routing decision to `.taw-video/intent.json`:
```json
{
  "tier1": "CREATE",
  "raw": "<user text>",
  "mode": "safe",
  "branch_loaded": "branches/create.md"
}
```

## Step 2 — Load + execute the branch

Load the branch file via `@`-reference (e.g. `@branches/create.md`). Execute its Steps 1..N in order. The branch file is the source of truth for its flow.

Branch files live at:
- `branches/create.md` — new video from prose (script → storyboard → render)
- `branches/edit.md` — modify existing scenes/script/voice (scoped, lighter flow)
- `branches/render.md` — re-export to different aspect ratio / format / quality
- `branches/remix.md` — clone an existing video's structure with new content
- `branches/advisor.md` — read-only opinion on script / storyboard / final video

Between steps inside a branch, emit a short progress line:
```
✓ Done: <3-word summary>
```

## Step 3 — Common post-steps (apply to every branch)

After a branch completes its main work, before emitting the final "Done":

1. **Commit** — if the branch made code changes (Remotion source, scene components, config), invoke `taw-video-commit` with the appropriate `type` (feat/fix/chore/refactor) plus phase tag if in CONTEXT mode.
2. **NEVER commit render artefacts.** `.gitignore` blocks `*.mp4`, `*.mov`, `*.wav`, etc. If user asks "save the video", point them to `out/` directory — those files are deliberately not in git.
3. **Update checkpoint** — write `.taw-video/checkpoint.json` with `{status, last_branch, last_render_path?, duration_sec?}`.
4. **Next-step hints** — final message suggests 2–3 relevant next commands:
   - After CREATE → `/taw-video render 9:16`, `/taw-video edit canh 2`
   - After EDIT → `/taw-video render`, `/taw-video review video`
   - After RENDER → `/taw-video edit ...`, upload to YT/TikTok
   - After REMIX → same as CREATE

## Step 4 — Error recovery

If a branch fails:
1. Compact error to ≤100 tokens.
2. Branch's own retry/revert runs ONCE.
3. Write `.taw-video/checkpoint.json`:
   ```json
   {"status":"failed","branch":"<name>","last_error":"<compact>","next_action":"Try /taw-video <verb>"}
   ```
4. Emit error template from `templates/error-messages.md` (VN if user input was VN).
5. If error contains TTS / ffmpeg / Remotion stderr, invoke `error-to-vi` skill to translate.

## State files

All taw-video state lives in `.taw-video/` (gitignored — note the directory name differs from taw-kit's `.taw/` to keep them independent in the same workspace if user mixes both):

- `.taw-video/intent.json` — classified intent + mode + branch loaded + clarifications
- `.taw-video/storyboard.md` — approved storyboard (CREATE / REMIX branches)
- `.taw-video/checkpoint.json` — `{status, last_branch, last_render_path?, last_error?}`
- `.taw-video/script.txt` — final TTS-ready narration text
- `.taw-video/captions.vtt` — generated captions (VN-aware)
- `.taw-video/design.json` — palette + typography + motion-style tokens

NEVER write API keys (ELEVENLABS_API_KEY, FPT_API_KEY, OPENAI_API_KEY) into `.taw-video/`. Keys live in `.env.local` only.

## Stack adaptation rule

Default stack is **Remotion 4 + Tailwind + ffmpeg + voice-tts-vi (FPT.AI default)**. For existing video projects, detect first:

1. **Read `package.json`** — map deps:
   - Video framework: `remotion` vs `@motion-canvas/core` vs `manim` (python deps in `requirements.txt`)
   - TTS: `elevenlabs` SDK vs custom FPT/OpenAI wrappers
   - Video utils: `fluent-ffmpeg`, `ffmpeg-static`
2. **Read `remotion.config.ts` / `motion-canvas.config.ts`** — confirm framework.
3. **Adapt:**
   - Project has Motion Canvas → load `motion-canvas-scenes` skill (when added), do NOT switch to Remotion silently.
   - Project has Manim sources in `manim/` → keep using Manim for math scenes; only add Remotion if user explicitly asks.
   - Empty project → install Remotion default.

NEVER silently install Remotion alongside Motion Canvas (or vice versa).

## Autonomy principle

taw-video defaults to **autonomous action for safe ops**, not "ask before everything".

| Class | Examples | Behaviour |
|---|---|---|
| **AUTO** | commit Remotion source, install declared deps, run `remotion render`, generate captions, save state to `.taw-video/`, dry-run preview | Just do it. 1-line result. |
| **CONFIRM ONCE** | switch TTS provider, regenerate full voice (cost), overwrite existing scene component, change aspect ratio of all renders | Ask ONE question, do, don't re-ask. |
| **HARD GATE** | delete render outputs, `git push --force`, override user-edited script, regenerate with paid API > 1000 chars | Require explicit text confirmation. |

**Exception — safe-mode storyboard gate (CREATE branch):** Step 4 storyboard approval is a deliberate hard-gate because rendering 60s of wrong video burns ~5 minutes + TTS API credits. Single approved interruption per CREATE run.

## Constraints

- **One entrypoint, one command.** Do NOT add new top-level `/taw-video-*` skills — add a new branch file under `branches/` instead.
- **Default stack**: Remotion 4 + Tailwind + ffmpeg. Override if project is Motion Canvas / Manim.
- **Render outputs never go to git.** Always check `.gitignore` before commit.
- **Voice budget warning**: TTS is paid per-character. Before running `voice-tts-vi` on >2000 chars, emit token estimate + cost.
- **Empty args**: let router emit its menu. Do not pre-empt.
- **Language consistency**: detect on first interaction, keep for whole session.

## Shell compatibility rule

Inside Claude Code, `grep` wraps `ugrep` with non-POSIX exit-code semantics in pipelines.

- For boolean decisions → `command grep` or `/usr/bin/grep`, NEVER bare `grep`
- For display-only output → bare `grep` is fine
- `git grep` is unaffected — safe

This rule is absolute for any branch/skill doing state-detection with grep pipelines.
