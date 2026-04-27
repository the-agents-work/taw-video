// Shared design tokens — sourced from .taw-video/design.json
export const palette = {
  bg: '#1A1A2E',
  primary: '#FF6B35',
  accent: '#F7B538',
  highlight: '#4ECDC4',
  text: '#FFF8E7',
} as const;

export const typography = {
  display: 'Be Vietnam Pro',
  displayWeight: 800,
  body: 'Be Vietnam Pro',
  bodyWeight: 500,
} as const;

export const FPS = 30;
export const WIDTH = 1080;
export const HEIGHT = 1920;

// Per-scene durations in frames
export const SCENE_DURATIONS = {
  s1: 120,  // 4s
  s2: 210,  // 7s
  s3: 210,  // 7s
  s4: 210,  // 7s
  s5: 150,  // 5s
} as const;

export const TOTAL_FRAMES = 900; // 30s
