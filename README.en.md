# taw-video

> Claude Code kit for non-coders — generate motion-graphic video with one command: `/taw-video <idea>`.

**Site:** [theagents.work](https://www.theagents.work/)
**Sibling repo:** [taw-kit](https://github.com/the-agents-work/taw-kit) — kit for web/app

> Vietnamese: [README.md](./README.md)

```
/taw-video make me a 60s tutorial about using ChatGPT for office workers
  → 3–5 clarifying questions (voice, palette, BGM, aspect ratio)
  → render storyboard with ~5 scenes, you approve
  → Claude codes Remotion scenes + TTS + burn-in subs
  → returns MP4 (1080p or 9:16 for TikTok/Shorts)
```

**Single command: `/taw-video`.** Free-form prose in EN or VN — create / edit / render / remix — the router picks the right branch.

```
/taw-video make 30s kinetic typography intro       → create
/taw-video shorten scene 3 by 1 second              → edit
/taw-video render 9:16 for TikTok                   → re-render
/taw-video remix last week's news template          → remix
```

> Demo: 60-second motion-graphic from idea to MP4 in ~1 hour. All animation written by Claude in React (Remotion) — no After Effects needed.

---

## How is this different from taw-kit?

| | **taw-kit** | **taw-video** |
|---|---|---|
| Output | Website / app | Video MP4 / MOV / GIF |
| Stack | Next.js + Supabase + Polar | **Remotion** (React → video) + ffmpeg + TTS |
| Deploy | Vercel / Docker / VPS | Render local or Remotion Lambda |
| Best for | Landing page, shop, CRM, blog | Tutorial, faceless channel, news recap, product demo, kinetic typography |

Two repos are independent — install whichever you need. A few meta-skills (taw-commit, vietnamese-copy, error-to-vi, terse-internal) are copied to keep both repos self-contained.

---

## What you get

- **~25 skills, 5 agents, 3 hooks** in `~/.claude/`
- **One command `/taw-video`** — 2-tier router: CREATE / EDIT / RENDER / REMIX
- **Default stack:** Remotion 4 (React) + Tailwind for scene styling + ffmpeg for mux/compress + pluggable TTS (ElevenLabs / FPT.AI / OpenAI)
- **Stack adaptation** — detects existing Motion Canvas / Manim / pure SVG and adapts instead of overwriting
- **Vietnamese voice** — `voice-tts-vi` defaults to FPT.AI (most natural VN tones); also supports ElevenLabs + OpenAI
- **Vietnamese subtitle burn-in** — handles VN diacritics correctly (common ffmpeg gotcha when fonts aren't full-Unicode)
- **5 presets**: tutorial-explainer, faceless-channel, news-recap, product-demo, kinetic-typography
- **Multi-aspect rendering** — one source → 9:16 + 1:1 + 16:9 in one build
- **Commercial license** — make and sell as many videos as you want

---

## Install

```bash
git clone https://github.com/the-agents-work/taw-video.git ~/.taw-video
bash ~/.taw-video/scripts/install.sh
```

Requirements: Node.js ≥ 20, ffmpeg, Claude Code, a Claude Pro/Max plan.

## First run

```bash
mkdir my-first-video && cd my-first-video
claude
```

In Claude Code:

```
/taw-video make a 60s tutorial about ChatGPT for office workers
```

The kit will ask 3–5 clarifying questions, render a storyboard, wait for approval, then run the agent chain (`script-writer` → `storyboard-planner` → `scene-coder` → `motion-tuner` → `renderer` → `reviewer`) and return an MP4 ready to upload.

---

## Agents

| Agent | Job |
|---|---|
| `script-writer` | Idea → narration script in chosen tone (informational / hype / chill / news) |
| `storyboard-planner` | Script → 4–8 scenes with timing, beats, transitions |
| `scene-coder` | Writes Remotion JSX/TSX per scene — animation, easing, layout |
| `motion-tuner` | Tightens easing curves, syncs animation with voice |
| `renderer` | Runs `npx remotion render`, muxes audio + subs via ffmpeg, compresses |
| `reviewer` | Visual quality + audio sync + subtitle correctness check |

## Key skills

| Skill | Purpose |
|---|---|
| `remotion-setup` | Bootstrap Remotion 4 project (tsconfig, compositions, root) |
| `motion-presets-vi` | Kinetic typography library that handles VN diacritics |
| `voice-tts-vi` | TTS provider abstraction (ElevenLabs / FPT.AI / OpenAI) |
| `captions-vi-burn` | Subtitle burn-in with full-Unicode fonts (no missing diacritics) |
| `ffmpeg-pipeline` | Mux video + audio + sub, scale, encode H.264/H.265 |
| `scene-presets` | Reusable scenes: title-card, lower-third, kinetic-quote, data-bar, comparison-split, end-card |

---

## License

Source-available — see [LICENSE](./LICENSE) and [THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md). Remotion has its own license (free for individuals and companies under $10M ARR).

## Support

namkent1612000@gmail.com or [theagents.work](https://www.theagents.work/).
