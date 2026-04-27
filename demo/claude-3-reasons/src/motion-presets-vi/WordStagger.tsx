import React from 'react';
import { useCurrentFrame, useVideoConfig, spring } from 'remotion';
import { toWordTokens } from './normalize';

interface WordStaggerProps {
  text: string;
  startFrame?: number;
  staggerFrames?: number;
  fontSize?: number;
  color?: string;
  fontFamily?: string;
  fontWeight?: number;
  textAlign?: 'left' | 'center' | 'right';
  lineHeight?: number;
  letterSpacing?: string;
}

export const WordStagger: React.FC<WordStaggerProps> = ({
  text,
  startFrame = 0,
  staggerFrames = 5,
  fontSize = 72,
  color = '#FFF8E7',
  fontFamily = 'Be Vietnam Pro',
  fontWeight = 800,
  textAlign = 'center',
  lineHeight = 1.35,
  letterSpacing = '0em',
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const words = toWordTokens(text);

  return (
    <span
      style={{
        display: 'inline',
        fontSize,
        color,
        fontFamily,
        fontWeight,
        lineHeight,
        letterSpacing,
        textAlign,
      }}
    >
      {words.map((word, i) => {
        const wordStart = startFrame + i * staggerFrames;
        const progress = spring({
          frame: frame - wordStart,
          fps,
          // playful: snappier pop-in per word, slight overshoot allowed
          config: { damping: 12, stiffness: 260, mass: 0.55 },
          durationInFrames: 18,
        });
        return (
          <span
            key={i}
            style={{
              display: 'inline-block',
              opacity: progress,
              transform: `translateY(${(1 - progress) * 24}px)`,
              marginRight: '0.25em',
            }}
          >
            {word}
          </span>
        );
      })}
    </span>
  );
};
