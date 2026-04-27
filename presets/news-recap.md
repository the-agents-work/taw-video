# Preset: news-recap

Quick news/event summary (45–90s). Neutral or urgent mood, third-person, dates+numbers explicit.

## Pre-filled defaults

```yaml
format: news-recap
duration_sec: 60
aspect_primary: 16:9
aspect_secondary: 9:16
fps: 30

voice:
  provider: fpt-ai
  voice_id: banmai        # nữ Bắc, news authoritative
  speed: 0

palette:
  bg: "#000000"
  fg: "#ffffff"
  primary: "#dc2626"      # news-red urgency
  secondary: "#fbbf24"    # accent for highlights

typography:
  display: "Be Vietnam Pro"
  display_weight: 700
  body: "Inter"
  body_weight: 400        # body lighter for "newsroom" feel

motion_style: cinematic   # smooth, not flashy

scene_structure:
  - { type: TitleCard, duration: 3 }           # "TIN MỚI / BREAKING"
  - { type: HeadlineCallout, duration: 4 }     # main headline
  - { type: LowerThird, duration: 8 }          # source + date metadata
  - { type: KineticQuote, duration: 10 }       # key fact / quote
  - { type: DataBar, duration: 12 }            # numbers (when relevant)
  - { type: ComparisonSplit, duration: 10 }    # before/after, then/now
  - { type: EndCard, duration: 5 }             # source attribution

bgm:
  mood: cinematic-tension
  volume: 0.3             # lower for news authority
  duck_under_voice: true

captions:
  burn_in: true
  style: clean
  # In news, captions repeat the voice almost verbatim — for low-sound viewing
```

## Style notes

- **Always cite sources** in lower-third or end-card. "Theo VnExpress, 26/04/2026" — establishes credibility.
- **Numbers spelled clearly** in script ("12 tỷ" → "mười hai tỷ" if TTS misreads).
- **No editorial framing** unless explicitly satirical preset.
- **Date stamp** in title card so reuploads are clearly historical.

## When to use

- Daily news recap channels
- Industry/niche news (e.g. AI news weekly)
- Event coverage (election, sports event)
- Crisis communications (corporate)

## When NOT to use

- Opinion content → too neutral, sounds robotic for op-ed
- Long-form documentary → 60s too short
- Hype/marketing → tone won't connect with audience
