---
name: asset-generator
description: >
  Generate video assets via image AI (Replicate / Together AI / OpenAI / Recraft):
  scene backgrounds, logos, character illustrations, B-roll stills, thumbnails.
  Caches results to public/assets-cache/ keyed by prompt hash so repeat scenes
  don't re-pay. Default model: SDXL Lightning for speed, Flux for quality.
  Trigger phrases (EN + VN): "gen image", "tao anh", "background video",
  "tao logo", "gen thumbnail", "anh minh hoa", "asset gen".
allowed-tools: Read, Write, Bash, WebFetch
---

# asset-generator — STUB

v0.1 frontmatter stub. Full impl in v0.2.

## Intended behaviour

1. Read asset request: prompt + size + style (illustration / photoreal / vector).
2. Check `public/assets-cache/<hash>.png` — if exists, reuse.
3. Else call configured provider (Replicate default), download, cache.
4. Return path to caller.

## Provider preference

1. Replicate (most flexible, paid)
2. Together AI (cheap)
3. OpenAI gpt-image-1 (consistent style)
4. Local diffusers (advanced, free, GPU required)

## v0.1 behaviour

scene-coder uses placeholder gradient backgrounds + emoji icons. User adds real assets manually to `public/`.
