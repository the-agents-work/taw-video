---
name: bgm-picker
description: >
  Pick royalty-free background music matching a video's mood and energy curve.
  Sources: YouTube Audio Library, Pixabay Music, Free Music Archive, Mixkit.
  Returns a track URL + license info + suggested volume level. Composes with
  ffmpeg-pipeline's side-chain duck recipe so BGM dips under voice automatically.
  Trigger phrases (EN + VN): "bgm", "background music", "nhac nen", "tim nhac",
  "doi nhac", "soundtrack", "music video".
allowed-tools: Read, Write, WebFetch
---

# bgm-picker — STUB

This is a v0.1 frontmatter stub. Full implementation arrives in v0.2.

## Intended behaviour

1. Read mood requirement from `.taw-video/intent.json` or user prompt.
2. Map mood → catalogue of curated royalty-free tracks (chill / hype / cinematic / corporate / lofi).
3. Suggest 3 tracks with title + URL + license + duration.
4. User picks; skill downloads to `assets/bgm/` and updates `src/Root.tsx` audio import.
5. Output volume default = 0.4 (with side-chain duck to ~0.15 under voice).

## v0.1 behaviour

Until full implementation, agents should:
- Ask user to provide a track path manually.
- Default to silence + voice only if no track provided.
- Use ffmpeg-pipeline's Recipe 2 to mix.
