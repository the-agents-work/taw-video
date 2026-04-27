---
name: manim-fallback
description: >
  Use Manim Community for math/data-viz scenes that Remotion struggles with:
  3D plots, equation typesetting, graph theory animations, calculus visualizations.
  Renders a Manim scene to PNG sequence or MP4, then imports into Remotion via
  <OffthreadVideo>. Adds 2-3 minute extra render time but unlocks scenes that
  would take a day to hand-code in CSS/SVG.
  Trigger phrases (EN + VN): "manim", "math animation", "3blue1brown", "data viz",
  "do thi toan hoc", "phuong trinh", "tinh toan dong", "graph animation".
allowed-tools: Read, Write, Bash
---

# manim-fallback — STUB

v0.1 frontmatter stub.

## When to use

- Math equations (LaTeX rendering): Manim has native LaTeX
- 3D plots
- Graph/network visualisations with smooth layout transitions
- Calculus/physics simulations

## When NOT to use

- Anything Remotion can do (Manim has 5–10× higher render overhead)
- Tight VN-text animations (Manim's text is OK but Remotion + motion-presets-vi is better)
- Real-time preview (Manim has no studio preview)

## Pipeline

1. Write Python scene file at `manim/scenes/<name>.py`.
2. Run `manim -qm manim/scenes/<name>.py SceneName` → outputs MP4 to `media/videos/<name>/720p30/`.
3. Copy/symlink output to `public/manim/<name>.mp4`.
4. Use Remotion `<OffthreadVideo src={staticFile('manim/<name>.mp4')}>` inside a Sequence.
5. Sync timing: read Manim output duration, set `<Sequence durationInFrames={...}>` accordingly.

## v0.1 behaviour

Skill is stub. If user explicitly requests math viz, agent recommends "install Manim manually via `pip install manim` then save scene file at manim/scenes/" and falls back to a placeholder gradient.
