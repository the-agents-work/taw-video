#!/usr/bin/env bash
# taw-video hook: SessionStart
# Injects current video-project context so Claude starts with awareness.
# Exits 0 always; failures silent (hooks must never break sessions).

set -u

LOG="${HOME}/.taw-video/logs/hooks.log"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

log() { printf '[%s] session-start: %s\n' "$(date -u +%FT%TZ)" "$1" >> "$LOG" 2>/dev/null || true; }

# Only run inside a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  log "not a git repo; skip"
  exit 0
fi

branch="$(git branch --show-current 2>/dev/null || echo 'detached')"
commits="$(git log -3 --oneline 2>/dev/null | head -3)"

# Detect taw-video state
last_render=""
[ -f ".taw-video/checkpoint.json" ] && last_render="$(jq -r '.last_render_path // empty' .taw-video/checkpoint.json 2>/dev/null)"

# List available compositions if Remotion project
compositions=""
if [ -f "src/Root.tsx" ]; then
  compositions="$(command grep -E 'id="(main-[^"]+)"' src/Root.tsx 2>/dev/null | sed -E 's/.*id="([^"]+)".*/    - \1/' | head -5)"
fi

# Count source scenes
scene_count=""
[ -d "src/scenes" ] && scene_count="$(ls -1 src/scenes/scene-*.tsx 2>/dev/null | wc -l | tr -d ' ')"

# Emit a compact context block (≤25 lines cap)
{
  printf '## Project context (taw-video session-start)\n'
  printf '- Branch: %s\n' "$branch"
  if [ -n "$commits" ]; then
    printf '- Recent commits:\n'
    printf '%s\n' "$commits" | sed 's/^/    /'
  fi
  [ -n "$scene_count" ] && [ "$scene_count" != "0" ] && printf '- Scenes: %s\n' "$scene_count"
  if [ -n "$compositions" ]; then
    printf '- Compositions:\n'
    printf '%s\n' "$compositions"
  fi
  [ -n "$last_render" ] && printf '- Last render: %s\n' "$last_render"
} | head -25

log "emitted context (branch=$branch, scenes=$scene_count, render=$last_render)"
exit 0
