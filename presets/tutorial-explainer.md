# Preset: tutorial-explainer

Educational how-to video (60–180s). Step-by-step, authoritative-friendly tone, second-person address.

## Pre-filled defaults

```yaml
format: tutorial-explainer
duration_sec: 90
aspect_primary: 16:9
aspect_secondary: 9:16
fps: 30

voice:
  provider: fpt-ai
  voice_id: leminh        # nam Bắc, tone tutorial-clear
  speed: 0

palette:
  bg: "#0f172a"           # dark slate
  fg: "#f8fafc"
  primary: "#fbbf24"      # amber accent
  secondary: "#3b82f6"

typography:
  display: "Be Vietnam Pro"
  display_weight: 800
  body: "Inter"
  body_weight: 500

motion_style: subtle      # tutorial = clear, not flashy

scene_structure:
  - { type: TitleCard, duration: 4 }
  - { type: HeadlineCallout, duration: 5 }     # "Vấn đề"
  - { type: ComparisonSplit, duration: 12 }    # cách cũ vs cách mới
  - { type: IconGrid, duration: 15 }           # 3 bước thực hiện
  - { type: DataBar, duration: 12 }            # kết quả / số liệu
  - { type: KineticQuote, duration: 8 }        # takeaway
  - { type: EndCard, duration: 5 }             # CTA

bgm:
  mood: chill-electronic
  volume: 0.4
  duck_under_voice: true

captions:
  burn_in: true
  style: clean
```

## Pre-filled clarifications (when YOLO)

```json
{
  "audience": "intermediate",
  "tone": "clear-friendly",
  "deliverable": "MP4 1080p 16:9 + 9:16"
}
```

## When to use

- "How to X" content
- Software tutorials
- Quick explainers (under 3 min)
- Educational YouTube/TikTok content

## When NOT to use

- Faceless hype channels → use `faceless-channel` preset (tone differs)
- News content → use `news-recap` (timing tighter, mood different)
- Pure visual without narration → use `kinetic-typography`
