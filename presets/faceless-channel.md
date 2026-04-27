# Preset: faceless-channel

YouTube/TikTok faceless content as motion graphic. Hype/curious tone, hooks every 10–15s, silent video — user voice-overs externally.

## Pre-filled defaults

```yaml
format: faceless-channel
duration_sec: 60
aspect_primary: 9:16     # default to vertical for short-form
aspect_secondary: 16:9
fps: 30

palette:
  bg: "#1a1a2e"           # near-black with blue tint
  fg: "#ffffff"
  primary: "#fbbf24"      # gold-yellow attention grabber
  secondary: "#ef4444"    # red urgency

typography:
  display: "Be Vietnam Pro"
  display_weight: 900     # heaviest weight, maximum punch
  body: "Inter"
  body_weight: 600

motion_style: aggressive  # snappy, attention-grabbing

on_screen_text_density: medium  # ~70 words; punchy phrases per beat

scene_structure:
  - { type: HeadlineCallout, duration: 3 }     # 3-second hook is mandatory
  - { type: KineticQuote, duration: 7 }        # statement / claim
  - { type: ComparisonSplit, duration: 10 }    # cách 1 vs cách 2 vs cách 3
  - { type: DataBar, duration: 10 }            # numbers / proof
  - { type: IconGrid, duration: 12 }           # 3-4 takeaway points
  - { type: KineticQuote, duration: 8 }        # punchline
  - { type: EndCard, duration: 5 }             # follow CTA

bgm:
  mood: hype-trap
  optional: false         # faceless without BGM = empty; recommend BGM
```

## Hook engineering reminder

Hook = first 3 seconds. Faceless audiences swipe in 2s if no grab. ALWAYS:
- Surprising stat ("97% người dùng AI sai cách")
- Direct question ("Bạn dùng ChatGPT đúng chưa?")
- Counter-intuitive claim ("Quên mọi thứ bạn biết về...")

For silent faceless, the hook line is the LARGEST text on screen — fills 60%+ of frame.

## When to use

- Niche-specific channels (AI tools, productivity, finance, lifestyle, history)
- Short-form attention economy content
- Aggregator content (top 5, did you know, etc.)
- Affiliate / monetized faceless ops

## When NOT to use

- Personal brand → user is the face, doesn't fit
- Tutorial step-by-step → tone too hype, info gets lost
