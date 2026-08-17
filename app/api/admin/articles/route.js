import { NextResponse } from 'next/server';
import { requireAdminApi } from '../../../lib/auth/admin';
import { createArticle, uniqueArticleSlug } from '../../../lib/firestore/articles';

export const runtime = 'nodejs';

export async function POST(request) {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  const payload = await request.json();
  if (!payload.title || !payload.excerpt || !payload.content) {
    return NextResponse.json({ error: 'Missing required article fields.' }, { status: 400 });
  }
  const article = await createArticle({
    ...payload,
    slug: await uniqueArticleSlug(payload.slug || payload.title),
  });
  return NextResponse.json({ article });
}

