# Preset: kinetic-typography

Pure motion text. NO voice required. 15–30s. Heavy reliance on `motion-presets-vi` for diacritic-correct animation.

## Pre-filled defaults

```yaml
format: kinetic-typography
duration_sec: 20
aspect_primary: 9:16    # vertical for max VN consumption
aspect_secondary: 1:1
fps: 60                 # 60fps for smooth fast motion

voice:
  provider: none         # NO voice — text + music only
  voice_id: null

palette:
  bg: "#000000"
  fg: "#ffffff"
  primary: "#fbbf24"     # accent on key word
  secondary: "#ef4444"   # secondary emphasis

typography:
  display: "Be Vietnam Pro"
  display_weight: 900    # max weight
  body: "Be Vietnam Pro"
  body_weight: 600

motion_style: aggressive # peak-energy, fast cuts

scene_structure:
  # Each "scene" is really a beat. Lots of beats per video, short individually.
  - { type: HeadlineCallout, duration: 2 }    # set up (1 word)
  - { type: KineticQuote, duration: 3 }       # phrase 1
  - { type: HeadlineCallout, duration: 2 }    # punch
  - { type: KineticQuote, duration: 3 }       # phrase 2
  - { type: HeadlineCallout, duration: 2 }    # punch
  - { type: KineticQuote, duration: 3 }       # phrase 3
  - { type: KineticQuote, duration: 4 }       # finale
  - { type: EndCard, duration: 1 }            # logo flash

bgm:
  mood: trap-aggressive   # OR cinematic-orchestral OR lofi-chill
  volume: 0.8             # higher because no voice to compete
  duck_under_voice: false # no voice
  beat_sync: true         # cuts on beat (downstream feature)

captions:
  burn_in: false          # text IS the captions
```

## Diacritic test phrases

When designing text, USE these test phrases to validate motion-presets handle VN correctly:

```
"đường về nhà ngắn lại sau mỗi mùa thu vàng ươm những giấc mộng"
"có những điều ta không bao giờ nói ra vì sợ thay đổi"
"tỉnh dậy đi anh — cuộc đời chỉ mất 80 năm thôi"
```

These cover all 84 VN letters with marks, including the tricky double-mark cases (ầ, ố, ữ, ặ).

## Music selection critical

Without voice, BGM CARRIES the emotion. Pick deliberately:

- **trap-aggressive** — for hype, gen-Z, motivational
- **cinematic-orchestral** — for serious, dramatic, cinematic
- **lofi-chill** — for calm, contemplative, aesthetic
- **electronic-builds** — for crescendo / reveal moments

`bgm-picker` skill matches mood to royalty-free track.

## When to use

- Motivational/quote-style content
- Aesthetic Instagram reels
- Music video accompaniment
- Brand identity reels
- Opening/closing animation for longer video

## When NOT to use

- Anything requiring narration/explanation → use other presets
- Long-form (>30s) → kinetic typography exhausts viewer
- Comparison / data viz → text-only too sparse for those formats
