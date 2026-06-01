// Converts the editorial textarea format to JSONB blocks and back.
//
// Textarea syntax:
//   ## Heading Two         → { type: 'heading', level: 2, text }
//   ### Heading Three      → { type: 'heading', level: 3, text }
//   > Quote text           → { type: 'quote', text }
//   [img: url | caption]   → { type: 'image', url, caption }
//   anything else          → { type: 'paragraph', text }
//
// Blocks are separated by one or more blank lines.

export function textToBlocks(text) {
  if (!text || typeof text !== 'string') return [];
  return text
    .split(/\n\n+/)
    .map((raw) => {
      const t = raw.trim();
      if (!t) return null;
      if (t.startsWith('### ')) return { type: 'heading', level: 3, text: t.slice(4) };
      if (t.startsWith('## ')) return { type: 'heading', level: 2, text: t.slice(3) };
      if (t.startsWith('> ')) return { type: 'quote', text: t.slice(2).trim() };
      const img = t.match(/^\[img:\s*([^\]|]+?)(?:\s*\|\s*([^\]]*))?\]$/i);
      if (img) return { type: 'image', url: img[1].trim(), caption: (img[2] || '').trim() };
      return { type: 'paragraph', text: t };
    })
    .filter(Boolean);
}

export function blocksToText(blocks) {
  if (!blocks || !Array.isArray(blocks)) return '';
  return blocks
    .map((b) => {
      if (!b) return '';
      switch (b.type) {
        case 'heading': return `${'#'.repeat(b.level || 2)} ${b.text || ''}`;
        case 'quote': return `> ${b.text || ''}`;
        case 'image': return `[img: ${b.url || ''}${b.caption ? ' | ' + b.caption : ''}]`;
        default: return b.text || '';
      }
    })
    .join('\n\n');
}
