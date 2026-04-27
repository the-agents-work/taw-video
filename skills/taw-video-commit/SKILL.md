---
name: taw-video-commit
description: >
  taw-video's unified commit skill: stages files, scans for secrets/render-artefact
  leaks, generates a conventional commit message by READING the actual diff (not
  guessing), then commits. Two modes: CONTEXT mode (called by /taw-video orchestrator —
  uses .taw-video/checkpoint.json branch info) and SMART mode (ad-hoc — infers
  type+scope+subject from diff content). Identical contract to taw-kit's taw-commit
  but pointed at .taw-video/ state. User never types git commands. Always prefixes
  output with "taw:" so you know which tool did it.
argument-hint: "[type] [scope] [subject]  (or leave empty — taw-commit auto-generates from diff)"
allowed-tools: Read, Bash, Edit, Grep
---

# taw-commit — Conventional Commits, taw-video-Branded

Every commit in a taw-video project goes through THIS skill. Strict format + secret/asset scrub + diff-aware subject generation.

## Commit format (strict)

```
<type>(<scope>): <subject>

<optional body: 1-3 bullets of what changed and why>

<optional trailer: Refs: <feature-id> | Remix-of: <source>>
```

- **type** — `feat | fix | chore | refactor | style | docs | test | perf | build | ci | revert`
- **scope** — kebab-case: `video | scene | voice | captions | render | bgm | preset | deps | env`
- **subject** — imperative, lowercase, ≤ 72 chars, no trailing period, describes WHY not WHAT

### Examples

```
feat(scene): add hook scene with kinetic typography for AI tutorial

- src/scenes/scene-2-hook.tsx: KineticQuote with diacritic-safe stagger
- design.json palette tightened (3 colors)
```

```
fix(captions): force Be Vietnam Pro to prevent missing diacritic glyphs
```

```
chore(deps): bump remotion 4.0.40 → 4.0.62 with zero codemod
```

```
feat(video): remix faceless-channel template with new AI-tools topic

Remix-of: ../my-prev-video
```

## Mode detection

```bash
if [ -f .taw-video/checkpoint.json ] && jq -e '.last_branch' .taw-video/checkpoint.json >/dev/null 2>&1; then
  MODE="context"
else
  MODE="smart"
fi
```

### CONTEXT mode (called by /taw-video orchestrator)

Read `.taw-video/checkpoint.json`:
```json
{ "last_branch": "create", "format": "tutorial-explainer", "scope_hint": "scene" }
```

Use `last_branch` + branch's documented scope hint. CREATE → `scene` or `video`. EDIT → match the edit target (`scene`/`voice`/`captions`/`bgm`). RENDER → `render`. REMIX → `video`.

### SMART mode (ad-hoc)

Detect existing commit style:
```bash
git log -20 --pretty=format:'%s'
```

| Pattern | Style |
|---|---|
| `feat(scope): ...` | Conventional Commits (full) |
| `feat: ...` | Conventional (no scope) |
| `Add X`, `Fix Y` | Imperative title-case |
| chaos | Default to Conventional |

## Workflow

### Step 1 — Derive scope (SMART mode)

Largest diff dir → scope:
- `src/scenes/**` → `scene`
- `src/motion-presets-vi/**` → `preset`
- `src/tts/**` → `voice`
- `public/captions*` or `*.vtt` → `captions`
- `remotion.config.*`, `tsconfig.*`, `tailwind.config.*` → `build`
- `package.json` (deps changed) → `deps`
- `.taw-video/**` → IGNORE (gitignored anyway)
- Multiple unrelated → omit scope

### Step 2 — Pre-commit sanity (MANDATORY)

```bash
git add -A
git diff --cached --name-only > /tmp/taw-video-staged.txt
```

**Auto-unstage local-state and render-artefact paths** (NEVER meant for git):

```bash
for pat in '.claude/' '.claudebk/' '.taw-video/' '.taw/' '.DS_Store' 'Thumbs.db' '*.log' '*.tsbuildinfo' 'node_modules/' '.next/' 'dist/' 'build/' 'out/' '\.mp4$' '\.mov$' '\.webm$' '\.gif$' '\.mkv$' '\.wav$' '\.mp3$' '\.m4a$' '\.aac$' '\.flac$' '\.remotion/' 'public/audio-cache/' 'public/video-cache/' 'media/videos/'; do
  files=$(git diff --cached --name-only | command grep -E "${pat}" || true)
  if [ -n "$files" ]; then
    git reset HEAD -- $files >/dev/null 2>&1
    echo "taw: ↩ unstaged $pat (local-state or render artefact, never commit)"
  fi
done
```

Render artefacts (MP4/MOV/WAV/MP3) MUST stay out of git. They're heavy, regenerable, and bloat repo size catastrophically.

If 0 staged files left → abort: "taw: nothing to commit (only render artefacts changed). Skipping." Exit 0.

**Filename blockers** — same as taw-kit list, plus video-specific:

| Pattern | What it is |
|---|---|
| `.env`, `.env.local`, `.env.*.local` | Secrets (asset-gen API keys, Remotion Lambda creds) |
| `*.key`, `*.pem`, `*.p12`, `*.pfx` | Private keys |
| `node_modules/**`, `dist/**`, `out/**`, `build/**` | Build artefacts |
| `.taw-video/**` | taw-video local state |
| `public/voice*.mp3`, `public/voice*.wav` | User voice files (heavy, user-supplied) |
| `public/audio-cache/**`, `public/video-cache/**` | Caches |
| `media/videos/**` | Manim render output |
| `.remotion/**` | Remotion build cache |

**Content blockers** — scan staged diff for secret patterns:

```bash
git diff --cached | command grep -InE "$CONTENT_PATTERN"
```

Common patterns (asset-gen + cloud-render keys):

| Source | Pattern |
|---|---|
| OpenAI / Anthropic | `sk-[A-Za-z0-9]{20,}` |
| AWS access key | `AKIA[0-9A-Z]{16}` |
| GitHub PAT | `(ghp\|gho\|ghu\|ghs\|ghr)_[A-Za-z0-9]{20,}` |
| Google API key | `AIza[0-9A-Za-z\-_]{35}` |
| Replicate token (asset-gen) | `r8_[A-Za-z0-9]{36}` |
| Together AI (asset-gen) | `(?i)together[_-]?api[_-]?key` |
| PEM private key | `-----BEGIN (RSA\|EC\|OPENSSH\|PGP\|DSA)? ?PRIVATE KEY-----` |

On hit:
1. Print file + line (NOT the value): `taw: 🚨 secret pattern matched in <file>:<line>`
2. Unstage: `git reset HEAD <file>`
3. VN msg: "File `<path>` lộ secret ở dòng <n>. Đã unstage. Chuyển giá trị vào `.env.local` rồi commit lại."

### Step 3 — `.gitignore` maintenance (append-only)

Check `.gitignore`. If missing, create with the taw-video baseline (covers `node_modules/`, `out/`, `*.mp4`, `*.wav`, `.taw-video/`, etc — see repo root `.gitignore`).

If exists, do NOT overwrite. Read, identify missing patterns, append with `# Added by taw-commit (taw-video)` separator.

### Step 4 — Generate subject (SMART mode or when hint missing)

Read `git diff --cached` fully. Classify:

| Type | Triggers (in taw-video context) |
|---|---|
| `feat` | New scene component, new motion preset, new format support |
| `fix` | Diacritic glyph fix, sync drift fix, codec compat fix, font fallback fix |
| `refactor` | Scene extraction, preset rename, motion-tuner restructure |
| `perf` | Render time reduction, bundle smaller, scene memoization |
| `test` | Scene visual regression test, audio sync test |
| `docs` | README, SKILL.md, doc updates |
| `style` | Tailwind tweak, palette adjust without behaviour change |
| `build` | `package.json`, `remotion.config.*`, `tsconfig.*` |
| `chore` | Housekeeping, deps bump |

**Subject rules** — same as taw-kit. Imperative, ≤72 chars, no period, lowercase first letter, describe WHY.

| Bad | Good |
|---|---|
| `feat(scene): updated scene 3` | `feat(scene): add data-bar with animated growth easing` |
| `fix: stuff` | `fix(captions): force Be Vietnam Pro for diacritic coverage` |
| `chore: bump deps` | `chore(deps): bump remotion 4.0.40 → 4.0.62 (zero codemod)` |

### Step 5 — Commit

```bash
git commit -m "$(cat <<'EOF'
feat(scene): add hook scene with kinetic typography for AI tutorial

- src/scenes/scene-2-hook.tsx: KineticQuote with diacritic-safe stagger
- design.json palette tightened to 3 colors
EOF
)"
```

### Step 6 — First-time setup

```bash
git rev-parse --git-dir >/dev/null 2>&1 || (git init && git branch -M main)
```

### Step 7 — Output

```
taw: committed feat(scene): add hook with kinetic typography — abc1234
```

## Safety rules

- NEVER `--no-verify` unless user asks.
- NEVER `--amend` on a pushed commit.
- NEVER force-push.
- Scrub render artefacts BEFORE commit. They have no business in git, period.
- Subject ALWAYS English (GitHub tooling expects it). Body CAN be VN if project history uses VN.
- Output prefix "taw:" — branding discipline.

## Constraints

- Read diff FULLY before subject — no guessing from filenames
- Render artefacts auto-unstaged with no exception
- Max 72 chars subject hard limit
