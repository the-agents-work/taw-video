#!/usr/bin/env bash
# Copy taw-video skills, agents, and hooks into ~/.claude/ without clobbering
# the user's own (non-taw-prefixed) content OR taw-kit's installed skills.
#
# Strategy:
#   - skills/taw-video*/                      → always overwrite (ours, prefixed name)
#   - skills/taw-video-{commit,trace}/        → always overwrite (renamed adapted skills)
#   - skills/<shared meta>/                   → install ONLY if dir does NOT exist
#                                               (preserves taw-kit's version since they
#                                                are interchangeable for both kits)
#   - agents/{script-writer,storyboard-planner,scene-coder,motion-tuner,renderer,video-reviewer}.md
#                                             → overwrite (ours, distinct names)
#   - hooks/taw-video-*.sh                    → overwrite (ours, prefixed)
#
# Marker: every dir/file we install gets a ".taw-video-owned" marker so
# uninstall + prune can find them.
#
# Prune: skills with .taw-video-owned that no longer exist in repo source
# are removed. User-authored skills (no marker) are never touched.
# taw-kit-owned skills are also never touched — different kit, different scope.
#
# Usage: bash scripts/lib/copy-skills.sh <TAW_VIDEO_ROOT>

set -eu

TAW_VIDEO_ROOT="${1:-$PWD}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
MARKER=".taw-video-owned"
TAW_KIT_MARKER=".taw-kit-owned"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=log.sh
. "$SCRIPT_DIR/log.sh"

mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/hooks"

# Skills that BOTH taw-kit and taw-video ship — defer to existing if present
# (the content is identical or close enough that either kit's copy works for
# both projects)
SHARED_META_SKILLS=(
  "vietnamese-copy"
  "error-to-vi"
  "terse-internal"
  "approval-plan"
  "sequential-thinking"
  "docs-seeker"
  "frontend-design"
)

is_shared_meta() {
  local name="$1"
  for s in "${SHARED_META_SKILLS[@]}"; do
    [ "$name" = "$s" ] && return 0
  done
  return 1
}

# Copy a skill dir, writing the marker
_copy_skill() {
  local src="$1" name; name="$(basename "$src")"
  local dst="$CLAUDE_DIR/skills/$name"

  # Shared meta-skills: install only if no version exists. If taw-kit's already
  # there (or user's own), do nothing — both kits use the same underlying skill.
  if is_shared_meta "$name"; then
    if [ -d "$dst" ]; then
      info "  meta-skill $name already installed (kept) — both kits use it"
      return 0
    fi
    mkdir -p "$dst"
    cp -R "$src"/. "$dst"/
    touch "$dst/$MARKER"
    info "  installed shared meta-skill $name (no prior install)"
    return 0
  fi

  # Non-shared skills: only refuse if user-owned (no marker) AND not taw-video-prefixed
  if [ -d "$dst" ] && [ ! -f "$dst/$MARKER" ] && [[ "$name" != taw-video* ]]; then
    warn "  skipping $name (exists and is not owned by taw-video)"
    return 0
  fi
  mkdir -p "$dst"
  # shellcheck disable=SC2086
  cp -R "$src"/. "$dst"/
  touch "$dst/$MARKER"
}

# --- Copy skills from repo into live install ---
for d in "$TAW_VIDEO_ROOT"/skills/*/; do
  [ -d "$d" ] || continue
  _copy_skill "${d%/}"
done

# --- Prune: taw-video-owned skills that disappeared from repo source ---
pruned=0
for d in "$CLAUDE_DIR"/skills/*/; do
  [ -d "$d" ] || continue
  name="$(basename "${d%/}")"
  [ -f "$d/$MARKER" ] || continue                       # not ours, skip
  [ -d "$TAW_VIDEO_ROOT/skills/$name" ] && continue     # still in repo, keep
  rm -rf "$d"
  pruned=$((pruned+1))
done
[ "$pruned" -gt 0 ] && ok "pruned $pruned skill(s) no longer in taw-video"

# --- Agents — always overwrite (we own these distinct names) ---
TAW_VIDEO_AGENTS=(
  "script-writer.md"
  "storyboard-planner.md"
  "scene-coder.md"
  "motion-tuner.md"
  "renderer.md"
  "video-reviewer.md"
)
for a in "${TAW_VIDEO_AGENTS[@]}"; do
  src="$TAW_VIDEO_ROOT/agents/$a"
  [ -f "$src" ] || continue
  cp "$src" "$CLAUDE_DIR/agents/$a"
done

# --- Hooks — always overwrite (we own taw-video-* prefixed names) ---
for h in "$TAW_VIDEO_ROOT"/hooks/taw-video-*.sh; do
  [ -f "$h" ] || continue
  cp "$h" "$CLAUDE_DIR/hooks/$(basename "$h")"
  chmod +x "$CLAUDE_DIR/hooks/$(basename "$h")"
done

ok "installed taw-video skills, agents, and hooks into $CLAUDE_DIR"
