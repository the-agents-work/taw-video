/**
 * Scene 4 — Lý do #3 (7s / 210 frames)
 * "Tiếng Việt mượt mà" → punchline yellow "#F7B538"
 */
import React from 'react';
import { KineticQuote } from './KineticQuote';
import { palette } from '../theme';

export const Scene4Reason3: React.FC = () => (
  <KineticQuote
    tag="Lý do #3"
    headline="Tiếng Việt mượt mà"
    punchline="hiểu đúng ngữ cảnh"
    footnote="Không bị dịch máy cứng đơ như mấy bot khác"
    highlightColor={palette.accent}
  />
);
