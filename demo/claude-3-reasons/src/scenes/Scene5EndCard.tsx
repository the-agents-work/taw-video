/**
 * Scene 5 — End Card (5s / 150 frames)
 * "Claude.ai" logotype scale-up + glow, "Thử ngay — miễn phí" + url
 * CTA pulses continuously
 */
import React from 'react';
import { AbsoluteFill, useCurrentFrame, useVideoConfig, spring, interpolate, Easing } from 'remotion';
import { loadFont } from '@remotion/google-fonts/BeVietnamPro';
import { palette } from '../theme';

const { fontFamily } = loadFont();

export const Scene5EndCard: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Logo scale-up spring — back-out: overshoots ~8-10% then settles
  const logoProgress = spring({
    frame,
    fps,
    // playful end-card: low damping lets scale punch past 1.0 then snap back
    config: { damping: 8, stiffness: 200, mass: 0.85 },
    durationInFrames: 30,
  });

  // Glow intensity pulsing after initial entrance
  const glowPulse = frame > 20
    ? 0.5 + Math.sin((frame - 20) * 0.12) * 0.5
    : logoProgress;

  // CTA slide-up — snappy with a tiny bounce to match playful tone
  const ctaProgress = spring({
    frame: frame - 22,
    fps,
    config: { damping: 11, stiffness: 240, mass: 0.65 },
    durationInFrames: 20,
  });

  // URL fade in — ease-out so badge softly appears after CTA settles
  const urlOpacity = interpolate(frame, [50, 72], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.out(Easing.cubic),
  });

  // CTA pulse (starts after entrance)
  const ctaPulse = frame > 50
    ? 1 + Math.sin((frame - 50) * 0.18) * 0.04
    : 1;

  // Map spring output [0, 1+overshoot] linearly — overshoot above 1.0 gives natural back-out
  const logoScale = interpolate(logoProgress, [0, 1], [0.2, 1]);
  const glowBlur = interpolate(glowPulse, [0, 1], [0, 48]);
  const glowOpacity = interpolate(glowPulse, [0, 1], [0, 0.7]);

  return (
    <AbsoluteFill
      style={{
        backgroundColor: palette.bg,
        fontFamily,
        alignItems: 'center',
        justifyContent: 'center',
        flexDirection: 'column',
        padding: '0 108px',
      }}
    >
      {/* Glow layer behind logo */}
      <div
        style={{
          position: 'absolute',
          width: 480,
          height: 240,
          borderRadius: '50%',
          backgroundColor: palette.primary,
          filter: `blur(${glowBlur}px)`,
          opacity: glowOpacity,
          transform: `scale(${logoScale})`,
        }}
      />

      {/* Logo text */}
      <div
        style={{
          fontSize: 128,
          fontWeight: 800,
          color: palette.text,
          letterSpacing: '-0.02em',
          lineHeight: 1,
          opacity: logoProgress,
          transform: `scale(${logoScale})`,
          marginBottom: 16,
          position: 'relative',
          zIndex: 1,
          textAlign: 'center',
        }}
      >
        Claude
        <span style={{ color: palette.primary }}>.ai</span>
      </div>

      {/* Divider */}
      <div
        style={{
          width: interpolate(logoProgress, [0, 1], [0, 280]),
          height: 4,
          borderRadius: 2,
          backgroundColor: palette.highlight,
          marginBottom: 48,
          opacity: logoProgress,
        }}
      />

      {/* CTA */}
      <div
        style={{
          fontSize: 80,
          fontWeight: 800,
          color: palette.accent,
          lineHeight: 1.2,
          textAlign: 'center',
          opacity: ctaProgress,
          transform: `translateY(${(1 - ctaProgress) * 40}px) scale(${ctaPulse})`,
          marginBottom: 40,
        }}
      >
        Thử ngay — miễn phí
      </div>

      {/* URL badge */}
      <div
        style={{
          fontSize: 52,
          fontWeight: 500,
          color: palette.text,
          opacity: urlOpacity * 0.85,
          backgroundColor: `${palette.primary}33`,
          border: `2px solid ${palette.primary}66`,
          borderRadius: 48,
          padding: '12px 48px',
          letterSpacing: '0.02em',
        }}
      >
        claude.ai
      </div>
    </AbsoluteFill>
  );
};
