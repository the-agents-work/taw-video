# Third-Party Notices

`taw-video` bundles or interacts with several third-party tools. Each retains its own license. None of the licenses below grant you any right to redistribute `taw-video` itself.

## Bundled Anthropic skills (Apache 2.0)

The following skills are vendored from Anthropic's open skill collection (https://github.com/anthropics/skills) under Apache License 2.0. Modifications, if any, are noted in the skill's `SKILL.md` header.

- `skills/frontend-design/` — visual aesthetic guardrails (anti-AI-slop) — used by `storyboard-planner` agent for picking palette + typography for each video.
- `skills/sequential-thinking/` — multi-step reasoning helper — used by planner/orchestrator.

Apache 2.0 license text: https://www.apache.org/licenses/LICENSE-2.0

## External tools called at runtime (NOT bundled)

`taw-video` shells out to or imports these tools when generating videos. You are responsible for installing each separately and complying with its license.

| Tool | License | Used for |
|---|---|---|
| [Remotion](https://www.remotion.dev/) | Remotion Individual License (free for individuals + companies < $10M ARR; paid otherwise) | Primary video framework — React → MP4 |
| [ffmpeg](https://ffmpeg.org/) | LGPL / GPL (build-dependent) | Compress, format convert, GIF export |
| [Manim Community](https://www.manim.community/) | MIT | Optional fallback for math/data-viz scenes |
| Node.js | MIT | Runtime |
| TypeScript / React | MIT | Scene component language |
| Tailwind CSS | MIT | Scene styling |

## Voice-over (out of scope for taw-video)

taw-video v0.1.1 produces **silent video**. Voice is added by the user in their video editor of choice — taw-video does not bundle, call, or recommend any specific TTS provider. If you want voice:

- **Built-in editor TTS**: CapCut, iMovie, Premiere all have TTS features
- **Standalone TTS**: ElevenLabs, FPT.AI, OpenAI, Google Cloud TTS — pick what you like
- **Real voice**: record yourself, that's still the best option for personal brand

Whatever provider you use, taw-video is not affiliated with any of them.

## Music / asset providers (optional)

`bgm-picker` skill defaults to royalty-free libraries (YouTube Audio Library, Pixabay Music, Free Music Archive). If you license tracks from a paid provider (Epidemic Sound, Artlist, Musicbed), `taw-video` only stores the file path — licensing remains your responsibility.

`asset-generator` skill (image gen for backgrounds, illustrations) is provider-agnostic and reads API keys from `.env.local`. Default provider preferences listed in the skill's SKILL.md. You provide your own keys.

## Trademark notice

"Remotion", "ffmpeg", "Manim", and other names are trademarks of their respective owners. Use here is descriptive only — taw-video is not affiliated with or endorsed by any of these projects.
