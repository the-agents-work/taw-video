---
name: tiktok-export
description: >
  Export spec for TikTok 2026: 1080x1920 9:16, 30fps, H.264 high profile,
  AAC 128kbps, ≤180s (extended), faststart flag, aspect-ratio metadata correct.
  Validates safe area against TikTok's UI overlays (top: username, bottom: caption
  + sound, right: like/comment/share/profile/effect stack).
  Trigger phrases (EN + VN): "tiktok", "ra tiktok", "xuat tiktok", "tiktok format".
allowed-tools: Read, Write, Bash
---

# tiktok-export — STUB

v0.1 frontmatter stub.

## Safe area for TikTok 9:16 (1080x1920)

- Top reserved: ~120px (username + sound info)
- Bottom reserved: ~250px (caption + sound bar)
- Right reserved: ~100px (button stack)
- Left reserved: ~30px (edge breathing)

Critical content (text, CTAs, faces) must fit within central 920×1550 region.

## Intended ffmpeg flags (over default render)

```bash
-c:v libx264 -profile:v high -level 4.1 -pix_fmt yuv420p \
-r 30 -c:a aac -b:a 128k -ar 44100 \
-movflags +faststart \
-metadata:s:v rotate=0
```

## v0.1 behaviour

Renderer outputs MP4 with these flags when user requests `/taw-video render tiktok` or `9:16`. No auto-upload.
