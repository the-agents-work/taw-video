/**
 * NFC-normalize text then split into grapheme clusters.
 * Keeps Vietnamese combining marks attached to their base letter.
 * e.g. "ầ" stays as one element, not split into a + combining marks.
 */
export function toGraphemes(text: string): string[] {
  const normalized = text.normalize('NFC');
  // Use Intl.Segmenter when available (modern V8), fall back to Array.from
  if (typeof Intl !== 'undefined' && 'Segmenter' in Intl) {
    const segmenter = new Intl.Segmenter('vi', { granularity: 'grapheme' });
    return Array.from(segmenter.segment(normalized), (s) => s.segment);
  }
  return Array.from(normalized);
}

/**
 * Split text into words, normalizing each word via NFC.
 * Preserves spaces as separate tokens so layout is correct.
 */
export function toWords(text: string): string[] {
  return text.normalize('NFC').split(/(\s+)/).filter(Boolean);
}

/**
 * Split into displayable words only (no whitespace tokens).
 */
export function toWordTokens(text: string): string[] {
  return text.normalize('NFC').split(/\s+/).filter(Boolean);
}
