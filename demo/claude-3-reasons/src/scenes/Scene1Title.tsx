/**
 * Scene 1 — Title Card (4s / 120 frames)
 * "Dân văn phòng ơi!" + "Đã thử Claude.ai chưa?" + ✨ wiggling sparkle
 * Motion: text spring-in from below, emoji wiggle, hard cut out
 */
import React from 'react';
import { AbsoluteFill, useCurrentFrame, useVideoConfig, spring, interpolate } from 'remotion';
import { loadFont } from '@remotion/google-fonts/BeVietnamPro';
import { palette } from '../theme';

const { fontFamily } = loadFont();

export const Scene1Title: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Headline spring-in from below
  const headlineProgress = spring({
    frame,
    fps,
    config: { damping: 12, stiffness: 180, mass: 0.9 },
    durationInFrames: 25,
  });

  // Subhead spring-in, delayed by 12 frames
  const subheadProgress = spring({
    frame: frame - 12,
    fps,
    config: { damping: 14, stiffness: 200, mass: 0.8 },
    durationInFrames: 22,
  });

  // Emoji enters after subhead (frame 22)
  const emojiProgress = spring({
    frame: frame - 22,
    fps,
    config: { damping: 10, stiffness: 300, mass: 0.6 },
    durationInFrames: 18,
  });

  // Emoji wiggle — continuous sine oscillation
  const wiggle = Math.sin((frame - 22) * 0.35) * 12;
  const wiggleScale = 1 + Math.sin((frame - 22) * 0.5) * 0.08;

  return (
    <AbsoluteFill
      style={{
        backgroundColor: palette.bg,
        alignItems: 'center',
        justifyContent: 'center',
        flexDirection: 'column',
        fontFamily,
        padding: '0 108px', // 10% safe area on each side
      }}
    >
      {/* Sparkle top decoration */}
      <div
        style={{
          fontSize: 96,
          opacity: emojiProgress,
          transform: `scale(${emojiProgress * wiggleScale}) rotate(${wiggle}deg)`,
          marginBottom: 32,
          lineHeight: 1,
        }}
      >
        ✨
      </div>

      {/* Main headline */}
      <h1
        style={{
          fontSize: 108,
          fontWeight: 800,
          color: palette.text,
          margin: 0,
          lineHeight: 1.2,
          textAlign: 'center',
          opacity: headlineProgress,
          transform: `translateY(${(1 - headlineProgress) * 80}px)`,
          letterSpacing: '-0.01em',
        }}
      >
        Dân văn phòng ơi!
      </h1>

      {/* Accent underline bar */}
      <div
        style={{
          width: interpolate(headlineProgress, [0, 1], [0, 320]),
          height: 6,
          borderRadius: 3,
          backgroundColor: palette.primary,
          marginTop: 16,
          marginBottom: 40,
        }}
      />

      {/* Subhead */}
      <p
        style={{
          fontSize: 72,
          fontWeight: 500,
          color: palette.accent,
          margin: 0,
          lineHeight: 1.35,
          textAlign: 'center',
          opacity: subheadProgress,
          transform: `translateY(${(1 - subheadProgress) * 60}px)`,
        }}
      >
        Đã thử Claude.ai chưa?
      </p>

      {/* Bottom sparkle */}
      <div
        style={{
          fontSize: 64,
          opacity: emojiProgress * 0.7,
          transform: `scale(${emojiProgress * wiggleScale}) rotate(${-wiggle * 0.8}deg)`,
          marginTop: 48,
          lineHeight: 1,
        }}
      >
        ✨
      </div>
    </AbsoluteFill>
  );
};
