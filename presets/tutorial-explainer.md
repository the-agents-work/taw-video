# Preset: tutorial-explainer

Educational how-to motion graphic (45–120s). On-screen text drives the message. Silent video — user adds voice externally if desired.

## Pre-filled defaults

```yaml
format: tutorial-explainer
duration_sec: 75
aspect_primary: 16:9
aspect_secondary: 9:16
fps: 30

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

on_screen_text_density: high   # ~120 words across video; viewer reads at own pace

scene_structure:
  - { type: TitleCard, duration: 4 }
  - { type: HeadlineCallout, duration: 5 }     # "Vấn đề" — hook scene
  - { type: ComparisonSplit, duration: 12 }    # cách cũ vs cách mới
  - { type: IconGrid, duration: 18 }           # 3 bước thực hiện (longer — viewer reads each step)
  - { type: DataBar, duration: 15 }            # kết quả / số liệu
  - { type: KineticQuote, duration: 10 }       # takeaway
  - { type: EndCard, duration: 8 }             # CTA + đăng ký channel/follow

bgm:
  mood: chill-electronic
  optional: true          # works without BGM too
```

## Pre-filled clarifications (when YOLO)

```json
{
  "audience": "intermediate",
  "tone": "clear-friendly",
  "deliverable": "MP4 1080p 16:9 + 9:16",
  "include_bgm": true
}
```

## When to use

- "How to X" content
- Software tutorials with step-by-step screens
- Quick explainers (under 2 min)
- Educational YouTube/TikTok motion graphics

## When NOT to use

- Faceless hype channels → use `faceless-channel` preset (tone differs, scene density different)
- News content → use `news-recap` (timing tighter, mood different)
- Pure visual without much text → use `kinetic-typography`
