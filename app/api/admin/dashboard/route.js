import { NextResponse } from 'next/server';
import { requireAdminApi } from '../../../lib/auth/admin';
import { getAdminArticles } from '../../../lib/firestore/articles';
import { getAuthors, getCategories } from '../../../lib/firestore/taxonomy';

export const runtime = 'nodejs';

export async function GET() {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  const [articles, authors, categories] = await Promise.all([
    getAdminArticles(),
    getAuthors(),
    getCategories(),
  ]);
  return NextResponse.json({ articles, authors, categories });
}

