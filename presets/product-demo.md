# Preset: product-demo

Show product features + benefits + CTA (30–60s). Benefits-first, second-person, urgent CTA at end.

## Pre-filled defaults

```yaml
format: product-demo
duration_sec: 45
aspect_primary: 16:9    # web embed friendly
aspect_secondary: 1:1   # IG feed
fps: 30

voice:
  provider: fpt-ai
  voice_id: leminh       # nam Bắc, confident
  speed: 0.5             # slightly faster for energy

palette:
  bg: "#ffffff"          # light bg for cleaner product feel
  fg: "#0f172a"
  primary: "#3b82f6"     # blue trust
  secondary: "#10b981"   # green CTA

typography:
  display: "Be Vietnam Pro"
  display_weight: 800
  body: "Inter"
  body_weight: 500

motion_style: playful    # bouncy, friendly

scene_structure:
  - { type: TitleCard, duration: 3 }           # logo + tagline
  - { type: HeadlineCallout, duration: 4 }     # the problem
  - { type: KineticQuote, duration: 5 }        # "introducing X"
  - { type: IconGrid, duration: 10 }           # 3-4 features
  - { type: ComparisonSplit, duration: 8 }     # without vs with product
  - { type: DataBar, duration: 8 }             # benefit numbers (saved $X, time, etc)
  - { type: EndCard, duration: 7 }             # CTA + offer (limited-time)

bgm:
  mood: corporate-uplifting
  volume: 0.4
  duck_under_voice: true

captions:
  burn_in: true
  style: clean
  # Product demos benefit from on-screen feature names — Add as scene props, not captions
```

## CTA discipline

End card MUST contain:
- Clear action verb ("Đăng ký dùng thử", "Mua ngay", "Tải về")
- URL / handle (visual + spoken)
- Time-bound offer (if any) — "Giảm 30% hết tháng này"

## When to use

- SaaS product launches
- E-commerce product features
- App store screenshots-style demos
- Internal product team announcements

## When NOT to use

- Brand awareness (no specific product) → use `kinetic-typography` or `faceless-channel`
- Educational about product category → use `tutorial-explainer`
- News about product launch → use `news-recap`
