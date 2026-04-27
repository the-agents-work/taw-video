/**
 * MainScene — chains all 5 scenes via Sequence
 * Total: 900 frames @ 30fps = 30s
 *
 * Durations:
 *   s1: 120f (4s)  — hard cut out
 *   s2: 210f (7s)  — wipe left→right into s3
 *   s3: 210f (7s)  — wipe left→right into s4
 *   s4: 210f (7s)  — wipe left→right into s5
 *   s5: 150f (5s)  — end
 *
 * Wipe transitions: clip path on incoming scene slides from left over 20 frames
 */
import React from 'react';
import { AbsoluteFill, Sequence, useCurrentFrame, useVideoConfig, interpolate, Easing } from 'remotion';
import '../tailwind.css';
import { Scene1Title } from './Scene1Title';
import { Scene2Reason1 } from './Scene2Reason1';
import { Scene3Reason2 } from './Scene3Reason2';
import { Scene4Reason3 } from './Scene4Reason3';
import { Scene5EndCard } from './Scene5EndCard';
import { SCENE_DURATIONS } from '../theme';

const S1 = SCENE_DURATIONS.s1; // 120
const S2 = SCENE_DURATIONS.s2; // 210
const S3 = SCENE_DURATIONS.s3; // 210
const S4 = SCENE_DURATIONS.s4; // 210
const S5 = SCENE_DURATIONS.s5; // 150

// Start offsets
const OFF1 = 0;
const OFF2 = S1;
const OFF3 = S1 + S2;
const OFF4 = S1 + S2 + S3;
const OFF5 = S1 + S2 + S3 + S4;

const WIPE_DURATION = 20; // frames for wipe transition

/**
 * WipeIn — wraps a scene with a left-to-right clip-path reveal
 */
const WipeIn: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const frame = useCurrentFrame();
  const clipPercent = interpolate(frame, [0, WIPE_DURATION], [0, 100], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  return (
    <AbsoluteFill
      style={{
        clipPath: `inset(0 ${100 - clipPercent}% 0 0)`,
      }}
    >
      {children}
    </AbsoluteFill>
  );
};

export const MainScene: React.FC = () => {
  return (
    <AbsoluteFill>
      {/* Scene 1: hard cut in (no wipe) */}
      <Sequence from={OFF1} durationInFrames={S1}>
        <Scene1Title />
      </Sequence>

      {/* Scene 2: wipe in from left */}
      <Sequence from={OFF2} durationInFrames={S2}>
        <WipeIn>
          <Scene2Reason1 />
        </WipeIn>
      </Sequence>

      {/* Scene 3: wipe in from left */}
      <Sequence from={OFF3} durationInFrames={S3}>
        <WipeIn>
          <Scene3Reason2 />
        </WipeIn>
      </Sequence>

      {/* Scene 4: wipe in from left */}
      <Sequence from={OFF4} durationInFrames={S4}>
        <WipeIn>
          <Scene4Reason3 />
        </WipeIn>
      </Sequence>

      {/* Scene 5: wipe in from left */}
      <Sequence from={OFF5} durationInFrames={S5}>
        <WipeIn>
          <Scene5EndCard />
        </WipeIn>
      </Sequence>
    </AbsoluteFill>
  );
};
