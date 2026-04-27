import React from 'react';
import { Composition } from 'remotion';
import { MainScene } from './scenes/MainScene';
import { TOTAL_FRAMES, FPS, WIDTH, HEIGHT } from './theme';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="claude-3-reasons-9x16"
        component={MainScene}
        durationInFrames={TOTAL_FRAMES}
        fps={FPS}
        width={WIDTH}
        height={HEIGHT}
        defaultProps={{}}
      />
    </>
  );
};
