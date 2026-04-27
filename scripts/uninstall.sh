#!/usr/bin/env bash
# tawvideo uninstall — remove taw-video files from ~/.claude/ without touching
# the user's own skills OR taw-kit's installed files. Optionally also remove
# the cloned repo at ~/.taw-video/.
#
# Usage:
#   tawvideo uninstall            # remove ~/.claude/ taw-video files, keep ~/.taw-video/
#   tawvideo uninstall --full     # also remove ~/.taw-video/
#   tawvideo uninstall --yes      # skip confirmation prompt

set -eu

TAW_VIDEO_ROOT="${TAW_VIDEO_ROOT:-$HOME/.taw-video}"
[ -f "$TAW_VIDEO_ROOT/scripts/uninstall.sh" ] || TAW_VIDEO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/log.sh
. "$TAW_VIDEO_ROOT/scripts/lib/log.sh"

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
MARKER=".taw-video-owned"
TAW_KIT_MARKER=".taw-kit-owned"

FULL=0
ASSUME_YES=0
for a in "$@"; do
  case "$a" in
    --full) FULL=1 ;;
    --yes|-y) ASSUME_YES=1 ;;
    --help|-h)
      cat <<EOF
tawvideo uninstall — remove taw-video from your machine

Two levels:
  tawvideo uninstall          Remove taw-video skills, agents, and hooks from ~/.claude/
                              Keep ~/.taw-video/ (for quick reinstall later)
  tawvideo uninstall --full   Remove EVERYTHING, including ~/.taw-video/

Options:
  --yes / -y                  Skip confirmation prompt
  --help / -h                 Show this help

What's preserved:
  - taw-kit files (separate kit, separate marker)
  - Your personal skills in ~/.claude/skills/ (no marker = not ours)
  - Shared meta-skills installed by taw-kit (won't double-remove)
EOF
      exit 0 ;;
  esac
done

# --- Confirm ---
if [ "$ASSUME_YES" -eq 0 ]; then
  info "About to remove taw-video from $CLAUDE_DIR"
  [ "$FULL" -eq 1 ] && warn "--full: will also delete $TAW_VIDEO_ROOT"
  printf "Continue? (yes/no): "
  read -r ans
  case "$ans" in
    yes|y|Yes|YES) ;;
    *) info "cancelled"; exit 0 ;;
  esac
fi

removed_count=0

# --- 1. Remove skills with our marker (.taw-video-owned) ---
# Note: shared meta-skills only get our marker if WE installed them first
# (i.e. taw-kit was not already present). We honour that — remove only what we
# installed.
if [ -d "$CLAUDE_DIR/skills" ]; then
  for d in "$CLAUDE_DIR/skills"/*/; do
    [ -d "$d" ] || continue
    if [ -f "$d/$MARKER" ]; then
      rm -rf "$d"
      removed_count=$((removed_count+1))
    fi
  done
  ok "removed $removed_count taw-video skill(s)"
fi

# --- 2. Remove our agents (named distinctly to avoid taw-kit collision) ---
TAW_VIDEO_AGENTS=(script-writer storyboard-planner scene-coder motion-tuner renderer video-reviewer)
agent_count=0
for a in "${TAW_VIDEO_AGENTS[@]}"; do
  f="$CLAUDE_DIR/agents/$a.md"
  if [ -f "$f" ]; then
    rm -f "$f"
    agent_count=$((agent_count+1))
  fi
done
[ "$agent_count" -gt 0 ] && ok "removed $agent_count taw-video agent(s)"

# --- 3. Strip tool-bootstrap block from ~/.claude/CLAUDE.md ---
USER_CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
if [ -f "$USER_CLAUDE_MD" ] && grep -q "taw-video:tool-bootstrap:begin" "$USER_CLAUDE_MD"; then
  awk '
    /<!-- taw-video:tool-bootstrap:begin -->/ { skip=1; next }
    /<!-- taw-video:tool-bootstrap:end -->/   { skip=0; next }
    !skip                                     { print }
  ' "$USER_CLAUDE_MD" > "$USER_CLAUDE_MD.new" && mv "$USER_CLAUDE_MD.new" "$USER_CLAUDE_MD"
  if [ ! -s "$USER_CLAUDE_MD" ] || ! grep -q '[^[:space:]]' "$USER_CLAUDE_MD"; then
    rm -f "$USER_CLAUDE_MD"
    ok "removed empty ~/.claude/CLAUDE.md"
  else
    ok "stripped taw-video tool-bootstrap section from ~/.claude/CLAUDE.md"
  fi
fi

# --- 4. Remove our hooks (prefixed taw-video-) ---
hook_count=0
for h in taw-video-session-start taw-video-auto-commit taw-video-permission-classifier; do
  f="$CLAUDE_DIR/hooks/$h.sh"
  if [ -f "$f" ]; then
    rm -f "$f"
    hook_count=$((hook_count+1))
  fi
done
[ "$hook_count" -gt 0 ] && ok "removed $hook_count hook(s)"

# --- 5. Strip taw-video keys from settings.json ---
SETTINGS="$CLAUDE_DIR/settings.json"
TAW_VIDEO_HOOK_PATTERN='taw-video|/\.claude/hooks/taw-video-'
if [ -f "$SETTINGS" ]; then
  if command -v jq >/dev/null 2>&1; then
    tmp="$(mktemp)"
    jq --arg pat "$TAW_VIDEO_HOOK_PATTERN" '
      (.hooks // empty) |= (
        with_entries(
          .value |= (
            map(.hooks |= (map(select((.command // "") | test($pat) | not))))
            | map(select((.hooks | length) > 0))
          )
        )
        | with_entries(select((.value | length) > 0))
      )
      | if (.hooks // {}) == {} then del(.hooks) else . end
      | del(._taw_video_meta)
    ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
    ok "cleaned settings.json (taw-kit hooks preserved if present)"
  else
    warn "jq not installed — settings.json not auto-cleaned. Edit $SETTINGS manually if needed"
  fi
fi

# --- 6. Remove symlink if exists ---
LINK="/usr/local/bin/tawvideo"
if [ -L "$LINK" ]; then
  if rm -f "$LINK" 2>/dev/null; then
    ok "removed symlink $LINK"
  elif command -v sudo >/dev/null 2>&1 && sudo rm -f "$LINK" 2>/dev/null; then
    ok "removed symlink $LINK"
  else
    warn "could not remove $LINK. Run manually: sudo rm $LINK"
  fi
fi

# --- 7. --full: remove ~/.taw-video/ ---
if [ "$FULL" -eq 1 ] && [ -d "$TAW_VIDEO_ROOT" ]; then
  if [ -d "$TAW_VIDEO_ROOT/.git" ] && [ -f "$TAW_VIDEO_ROOT/VERSION" ]; then
    rm -rf "$TAW_VIDEO_ROOT"
    ok "removed $TAW_VIDEO_ROOT"
  else
    warn "$TAW_VIDEO_ROOT does not look like a taw-video clone — skipping (delete manually if you really want to)"
  fi
fi

ok "uninstall complete. taw-kit (if installed) is untouched. Have a nice day."
