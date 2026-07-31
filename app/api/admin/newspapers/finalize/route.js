import { NextResponse } from 'next/server';
import sharp from 'sharp';
import { createClient } from '../../../../lib/supabase/server';
import { textToBlocks } from '../../../../lib/content';
import {
  GROQ_TEXT_MODEL,
  runGroqJson,
} from '../../../../lib/newspaper/groq';

export const runtime = 'nodejs';
export const maxDuration = 120;

const CATEGORIES = new Set([
  'Governance',
  'Economy',
  'Education',
  'Security',
  'Institutions',
  'Culture',
  'National Cohesion',
  'Economic Policy',
  'Public Finance',
  'General',
]);

function slugify(value) {
  return String(value || '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '')
    .slice(0, 80) || `newspaper-article-${Date.now()}`;
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, Number(value) || 0));
}

function readTime(body) {
  const words = String(body || '').trim().split(/\s+/).filter(Boolean).length;
  return `${Math.max(1, Math.ceil(words / 220))} min read`;
}

async function uniqueSlug(supabase, title) {
  const base = slugify(title);
  const { data } = await supabase
    .from('articles')
    .select('slug')
    .like('slug', `${base}%`);
  const used = new Set((data || []).map((row) => row.slug));
  if (!used.has(base)) return base;
  let suffix = 2;
  while (used.has(`${base}-${suffix}`)) suffix += 1;
  return `${base}-${suffix}`;
}

async function createArticleImage({ supabase, pagePath, bbox, slug }) {
  if (!pagePath || !bbox) return '';

  const { data: pageBlob, error: downloadError } = await supabase.storage
    .from('newspaper-imports')
    .download(pagePath);
  if (downloadError) throw downloadError;

  const input = Buffer.from(await pageBlob.arrayBuffer());
  const image = sharp(input, { failOn: 'none' });
  const metadata = await image.metadata();
  if (!metadata.width || !metadata.height) return '';

  const left = Math.floor(clamp(bbox.x, 0, 0.98) * metadata.width);
  const top = Math.floor(clamp(bbox.y, 0, 0.98) * metadata.height);
  const width = Math.floor(clamp(bbox.width, 0.03, 1) * metadata.width);
  const height = Math.floor(clamp(bbox.height, 0.03, 1) * metadata.height);
  const safeWidth = Math.min(width, metadata.width - left);
  const safeHeight = Math.min(height, metadata.height - top);

  if (safeWidth < 80 || safeHeight < 80) return '';

  const output = await image
    .extract({ left, top, width: safeWidth, height: safeHeight })
    .rotate()
    .jpeg({ quality: 88, mozjpeg: true })
    .toBuffer();

  const filename = `newspapers/${Date.now()}-${slug}.jpg`;
  const { error: uploadError } = await supabase.storage
    .from('article-images')
    .upload(filename, output, { contentType: 'image/jpeg', upsert: false });
  if (uploadError) throw uploadError;

  const {
    data: { publicUrl },
  } = supabase.storage.from('article-images').getPublicUrl(filename);
  return publicUrl;
}

function flattenFragments(pageResults) {
  return pageResults.flatMap((page) =>
    (Array.isArray(page.fragments) ? page.fragments : []).map((fragment, index) => ({
      ...fragment,
      id: fragment.id || `p${page.page}-a${index + 1}`,
      page: Number(page.page),
    }))
  );
}

export async function POST(request) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
    }

    const body = await request.json();
    const pageResults = Array.isArray(body.pageResults) ? body.pageResults : [];
    const uploadedPages = Array.isArray(body.uploadedPages) ? body.uploadedPages : [];
    const fragments = flattenFragments(pageResults);

    if (fragments.length === 0) {
      return NextResponse.json(
        { error: 'No readable article fragments were found.' },
        { status: 400 }
      );
    }

    const mergePrompt = `You are the senior editor completing a newspaper digitisation import.
Group fragments that belong to the same article, including continuations across pages.
Do not rewrite or reproduce article bodies; select fragment IDs in correct reading order.
Remove obvious duplicate fragments and exclude adverts, navigation, mastheads, and captions
that are not articles.

Return JSON only:
{
  "articles": [
    {
      "title": "",
      "author": "",
      "category": "General",
      "excerpt": "One accurate sentence based only on the supplied text.",
      "fragment_ids": ["p1-a1"],
      "lead_image": { "fragment_id": "p1-a1", "image_index": 0 }
    }
  ]
}

lead_image may be null. Use only image indexes that exist. Allowed categories:
Governance, Economy, Education, Security, Institutions, Culture, National Cohesion,
Economic Policy, Public Finance, General.

FRAGMENTS:
${JSON.stringify(fragments)}`;

    const merged = await runGroqJson({
      model: GROQ_TEXT_MODEL,
      messages: [{ role: 'user', content: mergePrompt }],
      maxTokens: 8000,
    });

    const plans = Array.isArray(merged.data.articles) ? merged.data.articles : [];
    const fragmentMap = new Map(fragments.map((fragment) => [fragment.id, fragment]));
    const pagePathMap = new Map(
      uploadedPages.map((page) => [Number(page.page), page.path])
    );
    const created = [];

    for (const plan of plans) {
      const ordered = (Array.isArray(plan.fragment_ids) ? plan.fragment_ids : [])
        .map((id) => fragmentMap.get(id))
        .filter(Boolean);
      if (!plan.title || ordered.length === 0) continue;

      const bodyText = ordered
        .map((fragment) => String(fragment.body || '').trim())
        .filter(Boolean)
        .join('\n\n');
      if (!bodyText) continue;

      const slug = await uniqueSlug(supabase, plan.title);
      let imageUrl = '';
      const lead = plan.lead_image;
      if (lead?.fragment_id && Number.isInteger(Number(lead.image_index))) {
        const sourceFragment = fragmentMap.get(lead.fragment_id);
        const candidate = sourceFragment?.images?.[Number(lead.image_index)];
        if (candidate?.bbox) {
          try {
            imageUrl = await createArticleImage({
              supabase,
              pagePath: pagePathMap.get(Number(sourceFragment.page)),
              bbox: candidate.bbox,
              slug,
            });
          } catch (imageError) {
            console.warn(`Could not crop image for ${slug}:`, imageError);
          }
        }
      }

      const payload = {
        title: String(plan.title).trim(),
        slug,
        author: String(plan.author || ordered.find((item) => item.author)?.author || '').trim(),
        author_bio: '',
        category: CATEGORIES.has(plan.category) ? plan.category : 'General',
        excerpt: String(plan.excerpt || bodyText.replace(/\s+/g, ' ').slice(0, 220)).trim(),
        content: textToBlocks(bodyText),
        read_time: readTime(bodyText),
        image_url: imageUrl,
        featured: false,
        status: 'draft',
        published_at: null,
      };

      const { data: inserted, error: insertError } = await supabase
        .from('articles')
        .insert(payload)
        .select('id, title, slug, image_url')
        .single();
      if (insertError) throw insertError;
      created.push(inserted);
    }

    if (created.length === 0) {
      return NextResponse.json(
        { error: 'The newspaper was readable, but no complete articles could be assembled.' },
        { status: 422 }
      );
    }

    const paths = uploadedPages.map((page) => page.path).filter(Boolean);
    if (paths.length > 0) {
      const { error: cleanupError } = await supabase.storage
        .from('newspaper-imports')
        .remove(paths);
      if (cleanupError) console.warn('Newspaper source cleanup failed:', cleanupError);
    }

    return NextResponse.json({
      articles: created,
      usage: merged.usage,
      model: merged.model,
    });
  } catch (error) {
    console.error('Newspaper finalization error:', error);
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Could not create article drafts.' },
      { status: 500 }
    );
  }
}
