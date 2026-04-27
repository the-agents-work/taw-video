# Third-Party Notices

`taw-video` bundles or interacts with several third-party tools. Each retains its own license. None of the licenses below grant you any right to redistribute `taw-video` itself.

## Bundled Anthropic skills (Apache 2.0)

The following skills are vendored from Anthropic's open skill collection (https://github.com/anthropics/skills) under Apache License 2.0. Modifications, if any, are noted in the skill's `SKILL.md` header.

- `skills/frontend-design/` — visual aesthetic guardrails (anti-AI-slop) — used by `video-planner` agent for picking palette + typography for each video.
- `skills/sequential-thinking/` — multi-step reasoning helper — used by planner/orchestrator.

Apache 2.0 license text: https://www.apache.org/licenses/LICENSE-2.0

## External tools called at runtime (NOT bundled)

`taw-video` shells out to or imports these tools when generating videos. You are responsible for installing each separately and complying with its license.

| Tool | License | Used for |
|---|---|---|
| [Remotion](https://www.remotion.dev/) | Remotion Individual License (free for individuals + companies < $10M ARR; paid otherwise) | Primary video framework — React → MP4 |
| [ffmpeg](https://ffmpeg.org/) | LGPL / GPL (build-dependent) | Final mux, compress, format convert |
| [Manim Community](https://www.manim.community/) | MIT | Optional fallback for math/data-viz scenes |
| Node.js | MIT | Runtime |
| TypeScript / React | MIT | Scene component language |
| Tailwind CSS | MIT | Scene styling |

## Voice / TTS providers (optional, API key required)

`voice-tts-vi` skill can call any of these; you choose at config time:

- ElevenLabs — proprietary, paid (free tier exists)
- FPT.AI Text-to-Speech — proprietary, free + paid tiers (best Vietnamese tones)
- OpenAI TTS — proprietary, paid
- Google Cloud Text-to-Speech — proprietary, free + paid tiers

`taw-video` never embeds API keys. You provide them via `.env.local`.

## Music / asset providers (optional)

`bgm-picker` defaults to royalty-free libraries (YouTube Audio Library, Pixabay Music, Free Music Archive). If you license tracks from a paid provider (Epidemic Sound, Artlist, Musicbed), `taw-video` only stores the file path — licensing remains your responsibility.

## Trademark notice

"Remotion", "ffmpeg", "Manim", "ElevenLabs", "FPT.AI" and other names are trademarks of their respective owners. Use here is descriptive only — taw-video is not affiliated with or endorsed by any of these projects.
