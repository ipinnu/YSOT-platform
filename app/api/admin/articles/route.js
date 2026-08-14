import { NextResponse } from 'next/server';
import { requireAdminApi } from '../../../lib/auth/admin';
import { articleSlugExists, createArticle } from '../../../lib/firestore/articles';

export const runtime = 'nodejs';

export async function POST(request) {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  const payload = await request.json();
  if (!payload.title || !payload.slug || !payload.excerpt || !payload.content) {
    return NextResponse.json({ error: 'Missing required article fields.' }, { status: 400 });
  }
  if (await articleSlugExists(payload.slug)) {
    return NextResponse.json({ error: 'An article with this slug already exists.' }, { status: 409 });
  }
  const article = await createArticle(payload);
  return NextResponse.json({ article });
}

