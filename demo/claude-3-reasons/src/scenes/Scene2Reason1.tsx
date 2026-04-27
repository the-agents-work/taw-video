/**
 * Scene 2 — Lý do #1 (7s / 210 frames)
 * "Tóm tắt tài liệu 100 trang" → punchline teal "#4ECDC4"
 */
import React from 'react';
import { KineticQuote } from './KineticQuote';
import { palette } from '../theme';

export const Scene2Reason1: React.FC = () => (
  <KineticQuote
    tag="Lý do #1"
    headline="Tóm tắt tài liệu 100 trang"
    punchline="trong 5 giây"
    footnote="Hợp đồng, email dài, báo cáo — gửi vào là xong"
    highlightColor={palette.highlight}
  />
);
