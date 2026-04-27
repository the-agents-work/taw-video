/**
 * KineticQuote — reusable kinetic-quote layout for Scenes 2, 3, 4
 * tag → headline (word stagger) → punchline (scale + color highlight) → footnote (fade)
 * Wipe transition handled at MainScene level via Sequence clipping.
 */
import React from 'react';
import { AbsoluteFill, useCurrentFrame, useVideoConfig, spring, interpolate, Easing } from 'remotion';
import { loadFont } from '@remotion/google-fonts/BeVietnamPro';
import { palette } from '../theme';
import { WordStagger } from '../motion-presets-vi/WordStagger';
import { toWordTokens } from '../motion-presets-vi/normalize';

const { fontFamily } = loadFont();

interface KineticQuoteProps {
  tag: string;         // e.g. "Lý do #1"
  headline: string;    // e.g. "Tóm tắt tài liệu 100 trang"
  punchline: string;   // e.g. "trong 5 giây"
  footnote: string;
  highlightColor: string;
}

export const KineticQuote: React.FC<KineticQuoteProps> = ({
  tag,
  headline,
  punchline,
  footnote,
  highlightColor,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // --- timing plan (210 frames / 7s) ---
  // f0-12:   tag pops in (snappier, front-loaded)
  // f12-50:  headline word stagger (4f per word, faster reveal)
  // f55-78:  punchline scales + highlight marker grows
  // f85-110: footnote fades in
  // f150-210: hold

  // Tag pop-in — tighter damping for crisp pill entrance, no float
  const tagProgress = spring({
    frame,
    fps,
    // playful: fast snap with minimal overshoot on pill
    config: { damping: 14, stiffness: 320, mass: 0.5 },
    durationInFrames: 14,
  });

  // Punchline scale — aggressive spring for energetic "aha" moment
  const punchlineProgress = spring({
    frame: frame - 55,
    fps,
    // playful: more bounce/overshoot than tag, energy rise mid-video
    config: { damping: 10, stiffness: 280, mass: 0.65 },
    durationInFrames: 20,
  });

  // Highlight bar width — eased out for satisfying sweep
  const highlightWidth = interpolate(
    frame,
    [62, 88],
    [0, 100],
    {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
      easing: Easing.out(Easing.quad),
    }
  );

  // Footnote fade — ease-out so it settles softly
  const footnoteOpacity = interpolate(
    frame,
    [85, 110],
    [0, 1],
    {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
      easing: Easing.out(Easing.cubic),
    }
  );

  // Punchline scale: spring overshoots naturally above 1.0 for playful feel
  const punchlineScale = interpolate(punchlineProgress, [0, 1], [0.6, 1]);

  // Word count of headline for stagger timing
  const headlineWords = toWordTokens(headline);
  const headlineDuration = 12 + headlineWords.length * 4;

  return (
    <AbsoluteFill
      style={{
        backgroundColor: palette.bg,
        fontFamily,
        padding: '0 108px',
        justifyContent: 'center',
        alignItems: 'flex-start',
        flexDirection: 'column',
      }}
    >
      {/* Tag pill */}
      <div
        style={{
          display: 'inline-block',
          backgroundColor: highlightColor,
          color: palette.bg,
          fontWeight: 800,
          fontSize: 44,
          padding: '10px 32px',
          borderRadius: 48,
          marginBottom: 48,
          opacity: tagProgress,
          // enter from below (positive Y = starts lower, springs up)
          transform: `scale(${0.6 + tagProgress * 0.4}) translateY(${(1 - tagProgress) * 30}px)`,
          letterSpacing: '0.02em',
        }}
      >
        {tag}
      </div>

      {/* Headline — word stagger */}
      <div
        style={{
          fontSize: 88,
          fontWeight: 800,
          color: palette.text,
          lineHeight: 1.25,
          marginBottom: 40,
          width: '100%',
        }}
      >
        <WordStagger
          text={headline}
          startFrame={12}
          staggerFrames={4}
          fontSize={88}
          color={palette.text}
          fontFamily={fontFamily}
          fontWeight={800}
          textAlign="left"
          lineHeight={1.25}
        />
      </div>

      {/* Punchline with highlight underline */}
      <div
        style={{
          marginBottom: 48,
          position: 'relative',
        }}
      >
        <div
          style={{
            fontSize: 108,
            fontWeight: 800,
            color: highlightColor,
            lineHeight: 1.2,
            opacity: punchlineProgress,
            transform: `scale(${punchlineScale})`,
            transformOrigin: 'left center',
            letterSpacing: '-0.01em',
          }}
        >
          {punchline}
        </div>
        {/* Highlight underline bar */}
        <div
          style={{
            position: 'absolute',
            bottom: -8,
            left: 0,
            height: 8,
            borderRadius: 4,
            backgroundColor: highlightColor,
            width: `${highlightWidth}%`,
            opacity: 0.5,
          }}
        />
      </div>

      {/* Footnote */}
      <p
        style={{
          fontSize: 44,
          fontWeight: 500,
          color: palette.text,
          opacity: footnoteOpacity * 0.7,
          margin: 0,
          lineHeight: 1.4,
          borderLeft: `4px solid ${highlightColor}`,
          paddingLeft: 24,
        }}
      >
        {footnote}
      </p>
    </AbsoluteFill>
  );
};
