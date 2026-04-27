---
name: remotion-setup
description: >
  Bootstrap a Remotion 4 project for taw-video. Creates package.json, remotion.config.ts,
  src/Root.tsx with multi-aspect compositions (16:9 + 9:16 + 1:1 ready), tsconfig, and
  a starter scene component. Detects existing setup and adapts instead of overwriting.
  Used by scene-coder agent at the start of a CREATE flow when no Remotion is present.
  Trigger phrases (EN + VN): "remotion setup", "init remotion", "scaffold remotion",
  "khoi tao remotion", "tao du an video", "setup video project".
allowed-tools: Read, Write, Edit, Bash, Glob
---

# remotion-setup

Initialize a working Remotion 4 project with taw-video conventions baked in: multi-aspect compositions, scene-presets-friendly Root, Tailwind-ready, ffmpeg-aware.

## Step 0 — Detection (MANDATORY first)

Before writing anything:

```bash
# Inside Claude Code, use `command grep` not bare grep for boolean checks
ls package.json 2>/dev/null && command grep -q '"remotion"' package.json && echo "remotion-installed"
ls remotion.config.ts 2>/dev/null && echo "config-exists"
ls src/Root.tsx 2>/dev/null && echo "root-exists"
```

| Detected state | Action |
|---|---|
| Empty folder, no package.json | Full scaffold (Steps 1–6) |
| package.json exists, no `remotion` dep | Add Remotion to existing project (Steps 2–6, skip 1) |
| Remotion already installed but no Root.tsx | Steps 4–6 only |
| Full Remotion project exists | Skip — return `"already-installed"` to caller |
| Motion Canvas detected (`@motion-canvas/core` in deps) | STOP — emit "Project uses Motion Canvas, not Remotion. Switch needs explicit user confirmation." |

## Step 1 — npm init

```bash
npm init -y
```

Edit `package.json` to add:

```json
{
  "scripts": {
    "dev": "remotion studio",
    "build": "remotion bundle",
    "render": "remotion render",
    "render:9x16": "remotion render src/index.ts main-9x16 out/video-9x16.mp4 --codec=h264",
    "render:16x9": "remotion render src/index.ts main-16x9 out/video-16x9.mp4 --codec=h264",
    "render:1x1":  "remotion render src/index.ts main-1x1  out/video-1x1.mp4  --codec=h264"
  }
}
```

## Step 2 — Install dependencies

```bash
npm install \
  remotion@4 \
  @remotion/cli@4 \
  @remotion/bundler@4 \
  @remotion/renderer@4 \
  @remotion/google-fonts@4 \
  react@18 react-dom@18 \
  --save

npm install -D \
  typescript@5 \
  @types/react@18 \
  @types/react-dom@18 \
  @types/node@20 \
  tailwindcss@3 \
  postcss autoprefixer
```

If user wants Manim fallback, additionally install via `manim-fallback` skill — separate flow.

## Step 3 — Create remotion.config.ts

```ts
import { Config } from '@remotion/cli/config';

Config.setVideoImageFormat('jpeg');
Config.setOverwriteOutput(true);
Config.setPixelFormat('yuv420p');
Config.setCodec('h264');
Config.setCrf(23);
Config.setConcurrency(4);

// Tailwind CSS support
Config.overrideWebpackConfig((cfg) => ({
  ...cfg,
  module: {
    ...cfg.module,
    rules: [
      ...(cfg.module?.rules ?? []),
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader', 'postcss-loader'],
      },
    ],
  },
}));
```

## Step 4 — Create src/Root.tsx (multi-aspect)

This is the canonical taw-video Root. Same scene component, three aspect-aware compositions:

```tsx
import { Composition } from 'remotion';
import { MainScene } from './scenes/MainScene';
import './tailwind.css';

const FPS = 30;

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="main-16x9"
        component={MainScene}
        durationInFrames={FPS * 60}
        fps={FPS}
        width={1920}
        height={1080}
        defaultProps={{ aspect: '16:9' as const }}
      />
      <Composition
        id="main-9x16"
        component={MainScene}
        durationInFrames={FPS * 60}
        fps={FPS}
        width={1080}
        height={1920}
        defaultProps={{ aspect: '9:16' as const }}
      />
      <Composition
        id="main-1x1"
        component={MainScene}
        durationInFrames={FPS * 60}
        fps={FPS}
        width={1080}
        height={1080}
        defaultProps={{ aspect: '1:1' as const }}
      />
    </>
  );
};
```

## Step 5 — Create src/index.ts entry

```ts
import { registerRoot } from 'remotion';
import { RemotionRoot } from './Root';

registerRoot(RemotionRoot);
```

## Step 6 — Starter MainScene (placeholder)

`src/scenes/MainScene.tsx`:

```tsx
import { AbsoluteFill, Sequence } from 'remotion';

type Props = { aspect: '16:9' | '9:16' | '1:1' };

export const MainScene: React.FC<Props> = ({ aspect }) => {
  return (
    <AbsoluteFill className="bg-slate-950 items-center justify-center">
      <div className="text-white text-6xl font-bold">
        taw-video — {aspect}
      </div>
    </AbsoluteFill>
  );
};
```

This is intentionally minimal. The `scene-coder` agent will replace `MainScene` with composed Sequence chains using `scene-presets`.

## Step 7 — tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "jsx": "react-jsx",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "isolatedModules": true,
    "lib": ["DOM", "ES2022"]
  },
  "include": ["src"]
}
```

## Step 8 — Tailwind config

`tailwind.config.ts`:

```ts
export default {
  content: ['./src/**/*.{ts,tsx}'],
  theme: { extend: {} },
  plugins: [],
};
```

`src/tailwind.css`:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## Step 9 — Verify

```bash
npm run build   # bundles silently — fast smoke test
```

If exit 0 → return `"setup-ok"` to caller. If non-zero → translate ffmpeg/Remotion error via `error-to-vi` skill, escalate.

## Step 10 — Output

Return JSON to caller:

```json
{
  "status": "setup-ok",
  "deps_installed": 12,
  "compositions": ["main-16x9", "main-9x16", "main-1x1"],
  "scene_files": ["src/scenes/MainScene.tsx"],
  "fps": 30,
  "default_duration_sec": 60
}
```

## Constraints

- ALWAYS use Remotion 4 (latest as of 2026). Don't pin to v3 unless user explicitly asks.
- Multi-aspect compositions baked in from start — saves work in RENDER branch later.
- FPS default 30 (web standard). 60fps only for kinetic typography or anyone explicitly asks.
- Audio + captions added later by `voice-tts-vi` and `captions-vi-burn` — not part of setup.
