/**
 * Scene 3 — Lý do #2 (7s / 210 frames)
 * "Viết email + báo cáo" → punchline orange "#FF6B35"
 */
import React from 'react';
import { KineticQuote } from './KineticQuote';
import { palette } from '../theme';

export const Scene3Reason2: React.FC = () => (
  <KineticQuote
    tag="Lý do #2"
    headline="Viết email + báo cáo"
    punchline="siêu pro, đỡ stress"
    footnote="Bảo Claude tone gì là viết tone đó"
    highlightColor={palette.primary}
  />
);
