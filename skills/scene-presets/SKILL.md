---
name: scene-presets
description: >
  Library of reusable Remotion scene components for taw-video — shadcn/ui equivalent
  for video. Each preset is a typed React component you drop into a Remotion
  composition. Covers: title-card, lower-third, kinetic-quote, data-bar,
  comparison-split, icon-grid, end-card, transition-wipe, headline-callout.
  Each scene is responsive across 16:9 / 9:16 / 1:1 via the `aspect` prop.
  Used by scene-coder agent.
  Trigger phrases (EN + VN): "scene preset", "title card", "lower third",
  "data bar", "end card", "thiet ke canh", "tao canh san", "scene library".
allowed-tools: Read, Write, Edit
---

# scene-presets

Drop-in scene components. Same idea as shadcn/ui: not a runtime library, a code-gen library — `scene-coder` copies the component file into the user's project, then customizes content (text, colors, data) for their video.

## Scene catalogue

Each preset is one file at `src/scenes/presets/<name>.tsx`. Common props:

```tsx
type CommonProps = {
  aspect: '16:9' | '9:16' | '1:1';
  durationInFrames: number;
  // scene-specific props vary
};
```

### 1. `<TitleCard>`

Big logo + title text. Slides in from left, settles, fades out.

```tsx
<TitleCard
  aspect="16:9"
  durationInFrames={90}      // 3s @ 30fps
  title="Học AI 60 giây"
  subtitle="Tập 1: ChatGPT cho người mới"
  logoSrc={staticFile('logo.png')}
  palette={{ bg: '#0f172a', accent: '#fbbf24' }}
/>
```

Usage: video opening (always first scene).

### 2. `<LowerThird>`

Name + role banner that slides in from bottom-left, stays for ~3s, slides out.

```tsx
<LowerThird
  aspect="16:9"
  durationInFrames={90}
  name="Nguyễn Văn A"
  role="Giảng viên Coding"
  position="bottom-left"
/>
```

Usage: introducing a person/source.

### 3. `<KineticQuote>`

Large pull-quote with WordStagger animation (from `motion-presets-vi`). Optional attribution.

```tsx
<KineticQuote
  aspect="9:16"
  durationInFrames={150}
  text="Đừng học để nhớ — học để làm."
  attribution="— Naval Ravikant"
  fontSize={96}
/>
```

Usage: hook scene, transition between sections.

### 4. `<DataBar>`

Animated horizontal/vertical bars with labels. Bars grow from 0 to value over `growDurationFrames`.

```tsx
<DataBar
  aspect="16:9"
  durationInFrames={360}
  title="Số người dùng AI ở VN"
  bars={[
    { label: '2023', value: 12, suffix: 'M' },
    { label: '2024', value: 28, suffix: 'M' },
    { label: '2025', value: 47, suffix: 'M' },
  ]}
  growDurationFrames={60}
/>
```

Usage: data viz, comparisons.

### 5. `<ComparisonSplit>`

Split-screen with 2 panels showing X vs Y. Panels slide in from opposite sides.

```tsx
<ComparisonSplit
  aspect="16:9"
  durationInFrames={300}
  left={{ title: 'Cách cũ', body: 'Mất 2 tuần học đủ syntax', emoji: '😩' }}
  right={{ title: 'Cách mới', body: 'Hỏi AI 5 phút biết ngay', emoji: '⚡' }}
/>
```

Usage: before/after, problem/solution.

### 6. `<IconGrid>`

3×3 or 2×2 grid of icons + labels appearing with stagger.

```tsx
<IconGrid
  aspect="1:1"
  durationInFrames={240}
  items={[
    { icon: '🚀', label: 'Tốc độ' },
    { icon: '🎯', label: 'Chính xác' },
    { icon: '💸', label: 'Tiết kiệm' },
  ]}
  layout="2x2"
/>
```

Usage: feature lists, principle summaries.

### 7. `<EndCard>`

Outro: subscribe button + CTA + logo. Animated logo + pulsing CTA.

```tsx
<EndCard
  aspect="16:9"
  durationInFrames={150}
  ctaText="Theo dõi để xem tập tiếp"
  socialHandles={{ youtube: '@taw-video', tiktok: '@taw.video' }}
  logoSrc={staticFile('logo.png')}
/>
```

Usage: video closer (always last scene).

### 8. `<TransitionWipe>`

3-frame transition between scenes. Color wipe with the palette accent.

```tsx
<TransitionWipe
  aspect="16:9"
  durationInFrames={9}
  direction="left-to-right"
  color="#fbbf24"
/>
```

Usage: between content scenes.

### 9. `<HeadlineCallout>`

Big single-word/phrase that appears + zooms + holds + fades. Like Vox-style emphasis.

```tsx
<HeadlineCallout
  aspect="9:16"
  durationInFrames={90}
  word="QUAN TRỌNG"
  underlineColor="#ef4444"
/>
```

Usage: emphasis, dramatic pause.

## Aspect-aware layout (responsive design baked in)

Every scene preset accepts `aspect` prop. Layout adapts:

```tsx
const config = useMemo(() => {
  switch (aspect) {
    case '16:9': return { fontSize: 96, padding: 64, layout: 'horizontal' };
    case '9:16': return { fontSize: 72, padding: 48, layout: 'vertical' };
    case '1:1':  return { fontSize: 80, padding: 56, layout: 'centered' };
  }
}, [aspect]);
```

Result: same source code → 3 aspect ratios render correctly with no per-aspect duplication.

## Composition convention

`scene-coder` chains presets in `src/scenes/MainScene.tsx`:

```tsx
import { Sequence } from 'remotion';
import { TitleCard } from './presets/TitleCard';
import { KineticQuote } from './presets/KineticQuote';
import { DataBar } from './presets/DataBar';
import { ComparisonSplit } from './presets/ComparisonSplit';
import { EndCard } from './presets/EndCard';

export const MainScene: React.FC<{ aspect: '16:9' | '9:16' | '1:1' }> = ({ aspect }) => {
  const fps = 30;
  return (
    <>
      <Sequence from={0} durationInFrames={fps * 3}>
        <TitleCard aspect={aspect} title="..." durationInFrames={fps * 3} />
      </Sequence>
      <Sequence from={fps * 3} durationInFrames={fps * 5}>
        <KineticQuote aspect={aspect} text="..." durationInFrames={fps * 5} />
      </Sequence>
      <Sequence from={fps * 8} durationInFrames={fps * 12}>
        <DataBar aspect={aspect} bars={[...]} durationInFrames={fps * 12} />
      </Sequence>
      {/* ... */}
    </>
  );
};
```

## Adding a new preset

1. Create `src/scenes/presets/<name>.tsx` with `aspect` prop.
2. Layout config via `useMemo` switch on aspect.
3. Use `interpolate` + `spring` from remotion for animations.
4. Use motion-presets-vi for any text inside (handles diacritics).
5. Pull palette/typography from `.taw-video/design.json` via context or props.
6. Document in this SKILL.md catalogue with example.

## When NOT to use a preset

- One-off creative scene that breaks the system → write inline in `MainScene`, don't pollute presets/.
- Format-specific layouts (e.g. news lower-third with logo+date strip) → consider format-preset library at `src/scenes/format-presets/news/` instead.
- 3D / WebGL effects → out of scope; needs Three.js setup or Manim fallback.

## Skill output

When invoked to scaffold the preset library:

```json
{
  "status": "scaffolded",
  "presets_written": [
    "src/scenes/presets/TitleCard.tsx",
    "src/scenes/presets/LowerThird.tsx",
    "src/scenes/presets/KineticQuote.tsx",
    "src/scenes/presets/DataBar.tsx",
    "src/scenes/presets/ComparisonSplit.tsx",
    "src/scenes/presets/IconGrid.tsx",
    "src/scenes/presets/EndCard.tsx",
    "src/scenes/presets/TransitionWipe.tsx",
    "src/scenes/presets/HeadlineCallout.tsx"
  ]
}
```

(v0.1 stubs out files; full impls land in v0.2.)
