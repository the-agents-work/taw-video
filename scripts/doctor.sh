#!/usr/bin/env bash
# tawvideo doctor — environment health check.
# Runs checks specific to taw-video (Remotion + ffmpeg + TTS readiness).
# Exits with count of failures.

set -u

TAW_VIDEO_ROOT="${TAW_VIDEO_ROOT:-$HOME/.taw-video}"
[ -f "$TAW_VIDEO_ROOT/scripts/doctor.sh" ] || TAW_VIDEO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/log.sh
. "$TAW_VIDEO_ROOT/scripts/lib/log.sh"

fails=0
warns=0

_pass()      { ok "$1";      }
_fail()      { err "$1";     fails=$((fails+1)); }
_warn_only() { warn "$1";    warns=$((warns+1)); }

# 1. Claude Code installed
if command -v claude >/dev/null 2>&1; then
  ver="$(claude --version 2>/dev/null | head -1 || echo 'unknown')"
  _pass "Claude Code: $ver"
else
  _fail "Claude Code not installed. Install: https://docs.claude.com/claude-code"
fi

# 2. git
if command -v git >/dev/null 2>&1; then
  gv="$(git --version | awk '{print $3}')"
  _pass "git: $gv"
else
  _fail "git not installed"
fi

# 3. node ≥ 20 (Remotion needs this)
if command -v node >/dev/null 2>&1; then
  nv="$(node --version 2>/dev/null | sed 's/v//')"
  major="${nv%%.*}"
  if [ "${major:-0}" -ge 20 ] 2>/dev/null; then
    _pass "Node.js: v$nv (Remotion needs ≥20)"
  else
    _fail "Node.js too old (v$nv). Remotion needs v20+. https://nodejs.org"
  fi
else
  _fail "Node.js not installed. Install: https://nodejs.org"
fi

# 4. ffmpeg (CRITICAL — taw-video can't render without)
if command -v ffmpeg >/dev/null 2>&1; then
  fv="$(ffmpeg -version 2>&1 | head -1 | awk '{print $3}')"
  _pass "ffmpeg: $fv"
  # Check for libx264 encoder (most common requirement)
  if ffmpeg -encoders 2>/dev/null | grep -q libx264; then
    _pass "  ffmpeg has libx264 encoder (H.264)"
  else
    _fail "  ffmpeg missing libx264 (minimal build). Reinstall full: brew reinstall ffmpeg"
  fi
else
  _fail "ffmpeg not installed. CRITICAL — taw-video can't render without it."
  info "  macOS:  brew install ffmpeg"
  info "  Linux:  sudo apt install ffmpeg"
fi

# 5. ffprobe (comes with ffmpeg, but verify)
if command -v ffprobe >/dev/null 2>&1; then
  _pass "ffprobe installed (video metadata reading)"
else
  _fail "ffprobe not installed. Reinstall ffmpeg full build."
fi

# 6. ~/.claude/ writable
if [ -w "$HOME/.claude" ]; then
  _pass "~/.claude/ writable"
else
  _fail "~/.claude/ not writable. Run: chmod -R u+w ~/.claude"
fi

# 7. Core skill installed
if [ -f "$HOME/.claude/skills/taw-video/SKILL.md" ]; then
  _pass "/taw-video skill installed"
else
  _fail "/taw-video skill not installed. Run: tawvideo install"
fi

# 8. Hooks executable
if [ -x "$HOME/.claude/hooks/taw-video-permission-classifier.sh" ]; then
  _pass "taw-video hooks are executable"
else
  _fail "hooks not executable. Run: chmod +x ~/.claude/hooks/taw-video-*.sh"
fi

# 9. Be Vietnam Pro font (CRITICAL for VN sub burn-in)
if command -v fc-list >/dev/null 2>&1; then
  if fc-list | grep -qi "be vietnam pro"; then
    _pass "Be Vietnam Pro font installed (VN diacritic burn-in safe)"
  elif fc-list | grep -qi "noto sans" || fc-list | grep -qi "inter"; then
    _warn_only "Be Vietnam Pro not installed; Inter/Noto fallback OK but Be Vietnam Pro renders VN dấu best"
    info "  install: brew install --cask font-be-vietnam-pro"
  else
    _fail "No VN-capable font found. Install: brew install --cask font-be-vietnam-pro"
  fi
else
  _warn_only "fc-list not available — can't verify font install (macOS without XQuartz)"
fi

# 10. TTS API key (at least one)
has_tts=0
[ -n "${FPT_API_KEY:-}" ]      && _pass "FPT_API_KEY set (recommended for VN voice)" && has_tts=1
[ -n "${ELEVENLABS_API_KEY:-}" ] && _pass "ELEVENLABS_API_KEY set" && has_tts=1
[ -n "${OPENAI_API_KEY:-}" ]   && _pass "OPENAI_API_KEY set" && has_tts=1
if [ "$has_tts" -eq 0 ]; then
  _warn_only "No TTS API key in env. Set at least one to use voice features:"
  info "  export FPT_API_KEY=...     # FPT.AI (best VN voice, free tier)"
  info "  export OPENAI_API_KEY=...  # OpenAI tts-1 (cheapest)"
  info "  export ELEVENLABS_API_KEY=... # ElevenLabs (best emotion control)"
fi

# 11. Anthropic auth (Claude Code login)
if command -v claude >/dev/null 2>&1 && claude auth status >/dev/null 2>&1; then
  _pass "Claude Code authenticated"
elif [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  _pass "ANTHROPIC_API_KEY set"
else
  _warn_only "No Claude auth detected. Run: claude login"
fi

# 12. Disk space (renders eat disk)
if command -v df >/dev/null 2>&1; then
  free_gb="$(df -k . 2>/dev/null | tail -1 | awk '{printf "%.1f", $4/1024/1024}')"
  if [ -n "$free_gb" ]; then
    if awk "BEGIN {exit !($free_gb >= 5)}" 2>/dev/null; then
      _pass "Disk free: ${free_gb}GB (renders need ~2GB headroom)"
    else
      _warn_only "Disk free: ${free_gb}GB — render artefacts may fill quickly"
    fi
  fi
fi

# 13. Locale UTF-8
if locale 2>/dev/null | grep -q 'UTF-8'; then
  _pass "locale: UTF-8"
else
  _fail "locale not UTF-8. Add to ~/.zshrc: export LANG=en_US.UTF-8"
fi

# 14. taw-kit detection (informational only — not required)
if [ -f "$HOME/.claude/skills/taw/SKILL.md" ]; then
  _pass "taw-kit also installed (web/app kit) — coexists fine with taw-video"
fi

echo
if [ "$fails" -eq 0 ]; then
  ok "tawvideo doctor: all checks passed ($warns non-critical warnings)"
  exit 0
else
  err "tawvideo doctor: $fails failure(s), $warns warning(s)"
  exit "$fails"
fi
