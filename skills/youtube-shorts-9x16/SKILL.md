---
name: youtube-shorts-9x16
description: >
  Layout + safe-area enforcement + thumbnail generation for YouTube Shorts.
  Ensures critical content stays inside the YT Shorts UI safe area (top: title
  overlay, bottom: comment/like UI, right: button stack). Generates a 9:16
  thumbnail still from the first 5 seconds. Output spec matches YT's 2026
  recommendations (1080x1920 @ 30/60fps, H.264, AAC, ≤60s for Shorts gating).
  Trigger phrases (EN + VN): "youtube shorts", "shorts", "9:16 youtube",
  "xuat shorts", "ra youtube shorts".
allowed-tools: Read, Write, Bash
---

# youtube-shorts-9x16 — STUB

v0.1 frontmatter stub.

## Intended behaviour

1. Validate render is 9:16 1080×1920.
2. Validate duration ≤ 60s (Shorts gating).
3. Apply safe-area mask: top 220px + bottom 280px + right 100px reserved for YT UI.
4. Verify text/CTAs in scene presets respect these margins (read each scene's `marginV`/`marginH`).
5. Generate thumbnail from frame at 2.5s mark (good "hook frame" default).
6. Output upload metadata (title <100 chars, hashtags suggestion, music attribution if BGM is from licensed source).

## v0.1 behaviour

Renderer agent applies safe-area when format=faceless-channel or aspect=9:16. No automated upload.
