#!/usr/bin/env bash
# taw-video install — idempotent local setup
# Copies skills/agents/hooks → ~/.claude/, merges settings, optionally
# symlinks `tawvideo` CLI into /usr/local/bin.
#
# Designed to coexist with taw-kit on the same machine:
#   - Shared meta-skills (vietnamese-copy, error-to-vi, etc.) defer to whichever
#     kit installed them first.
#   - Renamed-on-purpose collisions (taw-commit → taw-video-commit, hooks
#     prefixed taw-video-) ensure no overwrites of taw-kit files.
#
# Usage:
#   bash ~/.taw-video/scripts/install.sh
#   # or, if cloned elsewhere, run from the repo root:
#   bash scripts/install.sh

set -eu

TAW_VIDEO_ROOT="${TAW_VIDEO_ROOT:-$HOME/.taw-video}"
[ -f "$TAW_VIDEO_ROOT/scripts/install.sh" ] || TAW_VIDEO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/log.sh
. "$TAW_VIDEO_ROOT/scripts/lib/log.sh"

OS="$(bash "$TAW_VIDEO_ROOT/scripts/lib/detect-os.sh")"
case "$OS" in
  macos|linux|wsl) info "OS detected: $OS" ;;
  *) err "unsupported OS: $OS. Requires macOS, Linux, or WSL2."; exit 2 ;;
esac

# --- 0. Quick prereq check (warnings only — install proceeds) ---
warn_missing() {
  if ! command -v "$1" >/dev/null 2>&1; then
    warn "$1 not installed — taw-video needs it to render. ($2)"
    return 1
  fi
  return 0
}
warn_missing "node"   "Node.js ≥ 20 — Remotion runtime"
warn_missing "ffmpeg" "ffmpeg full build — video mux/compress"
warn_missing "git"    "git — version control + auto-commit hook"
warn_missing "claude" "Claude Code CLI — required to use taw-video skills"

# --- 1. Copy skills, agents, hooks ---
info "copying skills/agents/hooks → ~/.claude/"
bash "$TAW_VIDEO_ROOT/scripts/lib/copy-skills.sh" "$TAW_VIDEO_ROOT"

# --- 2. Merge settings.json.tmpl into ~/.claude/settings.json ---
SETTINGS="$HOME/.claude/settings.json"
TMPL="$TAW_VIDEO_ROOT/templates/settings.json.tmpl"
VERSION="$(cat "$TAW_VIDEO_ROOT/VERSION" 2>/dev/null || echo '0.1.0')"

# Render template (substitute {{TAW_VIDEO_VERSION}})
rendered="$(sed "s/{{TAW_VIDEO_VERSION}}/$VERSION/g" "$TMPL")"

if [ -f "$SETTINGS" ]; then
  if command -v jq >/dev/null 2>&1; then
    tmp_file="$(mktemp)"
    printf '%s' "$rendered" > "$tmp_file"
    # Deep-merge but APPEND hook arrays (don't replace) so taw-kit hooks survive.
    # Strategy: for each hook event we know about, concat arrays then dedupe by .hooks[0].command
    jq -s '
      def merge_hook_event(a; b):
        ((a // []) + (b // []))
        | unique_by(.matcher + "|" + (.hooks[0].command // ""));
      .[0] as $existing | .[1] as $new
      | $existing
      | .hooks = (
          ($existing.hooks // {}) as $eh
          | ($new.hooks // {}) as $nh
          | reduce ($eh + $nh | keys_unsorted | unique)[] as $event
              ({}; .[$event] = merge_hook_event($eh[$event]; $nh[$event]))
        )
      | ._taw_video_meta = $new._taw_video_meta
    ' "$SETTINGS" "$tmp_file" > "$SETTINGS.new" \
      && mv "$SETTINGS.new" "$SETTINGS" \
      && rm -f "$tmp_file"
    ok "merged settings.json (taw-kit hooks preserved if present)"
  else
    warn "jq not installed — skipping auto-merge."
    info "manual: copy hook entries from $TMPL into $SETTINGS"
    info "install jq: brew install jq  (Mac)  or  sudo apt install jq  (Linux)"
  fi
else
  printf '%s\n' "$rendered" > "$SETTINGS"
  ok "created $SETTINGS"
fi

# --- 3. Symlink tawvideo CLI to /usr/local/bin ---
TARGET="/usr/local/bin/tawvideo"
SOURCE="$TAW_VIDEO_ROOT/scripts/tawvideo"

if [ ! -f "$SOURCE" ]; then
  warn "$SOURCE not found — skipping CLI symlink"
elif [ -w "$(dirname "$TARGET")" ] 2>/dev/null; then
  ln -sf "$SOURCE" "$TARGET" && ok "symlinked $TARGET -> $SOURCE"
elif command -v sudo >/dev/null 2>&1; then
  info "sudo required to create symlink at $TARGET"
  if sudo ln -sf "$SOURCE" "$TARGET" 2>/dev/null; then
    ok "symlinked $TARGET -> $SOURCE"
  else
    warn "symlink failed. Add to PATH manually:"
    info "  echo 'export PATH=\"$TAW_VIDEO_ROOT/scripts:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
  fi
else
  warn "cannot create symlink. Add to PATH manually:"
  info "  echo 'export PATH=\"$TAW_VIDEO_ROOT/scripts:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
fi

# --- 4. Ensure hooks are executable ---
chmod +x "$HOME/.claude/hooks/taw-video-"*.sh 2>/dev/null || true

# --- 5. Append tool-bootstrap rule to ~/.claude/CLAUDE.md (idempotent) ---
USER_CLAUDE_MD="$HOME/.claude/CLAUDE.md"
mkdir -p "$HOME/.claude"

if [ -f "$USER_CLAUDE_MD" ] && grep -q "taw-kit:tool-bootstrap:begin\|taw-video:tool-bootstrap:begin" "$USER_CLAUDE_MD"; then
  info "tool-bootstrap section already in ~/.claude/CLAUDE.md (skip — taw-kit or prior taw-video install set it)"
else
  [ -f "$USER_CLAUDE_MD" ] && printf "\n\n" >> "$USER_CLAUDE_MD"
  cat >> "$USER_CLAUDE_MD" <<'TBEOF'
<!-- taw-video:tool-bootstrap:begin -->
## Tool bootstrap protocol (added by taw-video — do not edit between markers)

When you need a CLI tool that is not installed (ffmpeg, jq, fc-cache, whisper, etc.) AND it would materially speed up the current task:

1. Check first: `command -v <tool> >/dev/null 2>&1`
2. If missing, ask the user ONCE in their language:
   > Tool `<tool>` chưa được cài. Nó sẽ giúp <one-line benefit>. Cài không? (y/n)
3. If yes, detect OS via `uname -s` and run the right installer:
   - macOS (Darwin): `brew install <tool>` (or `pip install` for whisper)
   - Linux: try `apt install <tool>`, fallback `cargo install <tool>` or `pacman -S` based on distro
   - WSL: same as Linux
4. If no OR install fails: fall back to slower alternative without comment.

NEVER run `brew install` / `apt install` / `pip install` without explicit user consent in step 2.
NEVER ask twice in the same session for the same tool.
<!-- taw-video:tool-bootstrap:end -->
TBEOF
  ok "appended tool-bootstrap section to ~/.claude/CLAUDE.md"
fi

# --- 6. Run doctor at end ---
if [ -f "$TAW_VIDEO_ROOT/scripts/doctor.sh" ]; then
  info "running install checks..."
  bash "$TAW_VIDEO_ROOT/scripts/doctor.sh" || true
fi

ok "taw-video is ready. Open Claude Code and try: /taw-video <ý tưởng video bạn muốn làm>"
