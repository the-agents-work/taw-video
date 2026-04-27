# Preset: news-recap

Quick news/event motion graphic (30–60s). Neutral or urgent mood, headlines + data callouts, silent — user adds neutral news voice externally.

## Pre-filled defaults

```yaml
format: news-recap
duration_sec: 45
aspect_primary: 16:9
aspect_secondary: 9:16
fps: 30

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

on_screen_text_density: medium  # ~50 words; headlines + dates + key stats

scene_structure:
  - { type: TitleCard, duration: 3 }           # "TIN MỚI / BREAKING"
  - { type: HeadlineCallout, duration: 4 }     # main headline
  - { type: LowerThird, duration: 6 }          # source + date metadata
  - { type: KineticQuote, duration: 8 }        # key fact
  - { type: DataBar, duration: 10 }            # numbers (when relevant)
  - { type: ComparisonSplit, duration: 10 }    # before/after, then/now
  - { type: EndCard, duration: 4 }             # source attribution

bgm:
  mood: cinematic-tension
  optional: true
```

## Style notes

- **Always cite sources** in lower-third or end-card. "Theo VnExpress, 26/04/2026" — establishes credibility.
- **Numbers spelled clearly** in on-screen labels — viewer reads silently.
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
