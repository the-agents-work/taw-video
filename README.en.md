# taw-video

> Claude Code kit for non-coders — generate **silent** motion-graphic videos with one command: `/taw-video <idea>`. Add voice in your editor (CapCut / Premiere / DaVinci) if you want narration.

**Site:** [theagents.work](https://www.theagents.work/)
**Sibling repo:** [taw-kit](https://github.com/the-agents-work/taw-kit) — kit for web/app

> Vietnamese: [README.md](./README.md)

```
/taw-video make me a 60s tutorial about using ChatGPT for office workers
  → 3–4 clarifying questions (palette, BGM, aspect ratio)
  → render storyboard with ~5 scenes, you approve
  → Claude codes Remotion scenes
  → returns silent MP4 (1080p or 9:16 for TikTok/Shorts)
```

**Single command: `/taw-video`.** Free-form prose in EN or VN — create / edit / render / remix — the router picks the right branch.

```
/taw-video make 30s kinetic typography intro       → create
/taw-video shorten scene 3 by 1 second              → edit
/taw-video render 9:16 for TikTok                   → re-render
/taw-video remix last week's news template          → remix
```

> Demo: 60-second motion-graphic from idea to MP4 in ~30 minutes. All animation written by Claude in React (Remotion) — no After Effects needed.

---

## Why silent (no TTS)?

Voice is personal. Everyone wants a different voice (gender, accent, energy) and TTS providers change quality + price constantly. Instead of locking the kit to one provider, **taw-video produces silent video** — you open your editor, record yourself or use whatever TTS you prefer, drop it onto the MP4.

Benefits:
- **Faster**: no API key signup, no credit limits
- **Flexible**: use your real voice, or any TTS (ElevenLabs / FPT.AI / OpenAI / built-in CapCut TTS)
- **Cheaper**: zero TTS cost at gen time
- **Right call for motion graphic**: kinetic typography + on-screen text + visuals carry the message. Voice is "extra," not required.

---

## How is this different from taw-kit?

| | **taw-kit** | **taw-video** |
|---|---|---|
| Output | Website / app | Video MP4 / MOV / GIF (silent) |
| Stack | Next.js + Supabase + Polar | **Remotion** (React → video) + ffmpeg |
| Deploy | Vercel / Docker / VPS | Render local or Remotion Lambda |
| Best for | Landing page, shop, CRM, blog | Tutorial, faceless channel, news recap, product demo, kinetic typography |

---

## What you get

- **~17 skills, 6 agents, 3 hooks** in `~/.claude/`
- **One command `/taw-video`** — 2-tier router: CREATE / EDIT / RENDER / REMIX / ADVISOR
- **Default stack:** Remotion 4 (React) + Tailwind for scene styling + ffmpeg for compress/convert
- **Stack adaptation** — detects existing Motion Canvas / Manim and adapts instead of overwriting
- **Vietnamese diacritic-safe** — `motion-presets-vi` handles VN diacritics (đ, ầ, ố, ữ, ặ) so kinetic text doesn't shred marks during animation
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

If you already have taw-kit installed, taw-video coexists — no overwrites.

## First run

```bash
mkdir my-first-video && cd my-first-video
claude
```

In Claude Code:

```
/taw-video make a 60s tutorial about ChatGPT for office workers
```

The kit will ask 3–4 clarifying questions, render a storyboard, wait for approval, then run the agent chain (`script-writer` → `storyboard-planner` → `scene-coder` → `motion-tuner` → `renderer` → `video-reviewer`) and return a silent MP4 ready to upload (or open in your editor to add voice).

---

## Add voice afterwards (workflow tips)

After taw-video produces the silent MP4:

**Option 1 — CapCut (free, has TTS built-in)**:
1. Open CapCut Desktop, import the MP4
2. `Text → Text-to-speech` → pick a voice, paste your script
3. Drag voice clip onto timeline, sync with scenes
4. Export

**Option 2 — DaVinci Resolve (free, more pro)**:
1. Import MP4 to timeline
2. Record mic separately or import a TTS WAV (FPT.AI / ElevenLabs export to WAV)
3. Sync, normalize, mix with BGM if any
4. Export

**Option 3 — Record your own voice**:
1. Audacity / Voice Memos record reading the on-screen text shown in video
2. Import into CapCut/iMovie/Premiere, drop on timeline
3. Export

Tip: trim on-screen text shorter if your spoken pace lags the animation.

---

## Agents

| Agent | Job |
|---|---|
| `script-writer` | Idea → JSON payload of per-scene on-screen text (NOT a TTS narration script) |
| `storyboard-planner` | Text payload → 4–7 scenes with timing, beats, transitions |
| `scene-coder` | Writes Remotion JSX/TSX per scene — animation, easing, layout |
| `motion-tuner` | Tightens easing curves + beat curve matching |
| `renderer` | Runs `npx remotion render` → MP4 (BGM bundled via `<Audio>` if user added) |
| `video-reviewer` | Visual quality + VN diacritic correctness + platform safe-area check |

## Key skills

| Skill | Purpose |
|---|---|
| `remotion-setup` | Bootstrap Remotion 4 project (tsconfig, compositions, root) |
| `motion-presets-vi` | Kinetic typography library that handles VN diacritics |
| `ffmpeg-pipeline` | Compress / convert format / GIF export / frame extract recipes |
| `scene-presets` | Reusable scenes: title-card, lower-third, kinetic-quote, data-bar, comparison-split, end-card |

---

## License

Source-available — see [LICENSE](./LICENSE) and [THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md). Remotion has its own license (free for individuals and companies under $10M ARR).

## Support

namkent1612000@gmail.com or [theagents.work](https://www.theagents.work/).
