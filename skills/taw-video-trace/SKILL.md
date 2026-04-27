---
name: taw-video-trace
description: >
  Look up taw-video git history without needing to know git. Find which commit
  added a scene, changed a voice provider, or fixed a caption diacritic bug.
  Reads the strict format written by `taw-commit` (type(scope): subject).
  Every output prefixed "taw:" for branding.
  Trigger phrases (VN + EN): "xem lich su", "ai sua cai nay", "khi nao them canh",
  "commit nao lam hong sub", "tra lai version cu", "show git history", "blame",
  "video tuần trước".
argument-hint: "<scope | file | feature>   vd: scene | captions | src/scenes/scene-2-hook.tsx | hero-typography"
allowed-tools: Read, Bash, Grep
---

# taw-trace — Commit History Lookup (taw-video-Branded)

## Purpose

Non-dev users should be able to ask "khi nào thêm cảnh hook?" or "commit nào làm hỏng sub tiếng Việt?" and get a straight answer. Wraps `git log` / `git blame` behind a single interface.

## Input modes

| Input shape | Example | Query |
|---|---|---|
| Scope name | `scene`, `voice`, `captions`, `render` | `git log --grep="($scope)"` |
| File path | `src/scenes/scene-2-hook.tsx` | `git log --follow -- <file>` |
| Feature slug | `kinetic-typography`, `tiktok-export` | `git log --grep="$slug" --all-match` |
| SHA | `abc1234` | `git show --stat <sha>` |
| `who` + file | `who src/scenes/MainScene.tsx` | `git blame -L 1,40 <file>` |

If ambiguous, ask once in VN: "taw: tìm theo **scope** (vd: scene), **file** (src/...), hay **feature** (kinetic-typography)?"

## Workflow

### 1. By scope — "mọi commit về scene"

```bash
git log --grep="(scene)" --pretty=format:"%h  %ad  %s" --date=short -20
```

Output (VN, max 10 dòng):
```
taw: lịch sử thay đổi scene —
  abc1234  2026-04-26  feat(scene): add hook with kinetic typography
  def5678  2026-04-27  fix(scene): tighten data-bar growth easing
  9a0b1c2  2026-04-28  refactor(scene): extract MainScene composition
```

### 2. By file — "ai sửa scene-2-hook.tsx"

```bash
git log --follow --pretty=format:"%h  %an  %ad  %s" --date=short -- "$file"
```

Per-line:
```bash
git blame -L <start>,<end> -- "$file"
```

### 3. By feature slug — "khi nào thêm hỗ trợ TikTok"

```bash
git log --grep="tiktok" -i --pretty=format:"%h  %ad  %s" --date=short
```

### 4. By voice provider switch — "khi nào đổi sang FPT"

```bash
git log -G "fpt-ai|FPT_API_KEY" --pretty=format:"%h  %ad  %s" --date=short
```

### 5. Reverse lookup — "commit nào làm hỏng sub"

Ask last-known-good vs broken SHA/date, then:
```bash
git log --oneline <good>..<broken> -- src/scenes/ public/captions*
```

Offer `git bisect` only if >10 commits in range.

## Safety / UX rules

- **Max 20 commits** per output unless user asks "tất cả"
- Always truncate SHAs to 7 chars
- **Read-only** — NEVER run `git reset`, `git checkout <sha>`, `git revert`. If user asks rollback → suggest `/taw-video edit ...` to redo properly, OR `git revert <sha>` (let user run)
- If `.git/` missing: "taw: project chưa có git. Chạy `git init` hoặc `/taw-video` để khởi tạo."

## Output convention

```
$ git log --grep="(captions)" -10

taw: 3 commit liên quan captions —
  abc1234  2026-04-26  fix(captions): force Be Vietnam Pro for diacritics
  def5678  2026-04-27  feat(captions): add tiktok safe-area style preset
  9a0b1c2  2026-04-28  chore(captions): bump whisper to medium model
```

## When to invoke

- User asks "khi nào", "ai sửa", "commit nào", "lịch sử", "thay đổi gì"
- Before `/taw-video edit`: surface last 5 commits touching the area being edited
- Before `/taw-video render`: show commits since last successful render (if marker exists)
