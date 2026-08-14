import { NextResponse } from 'next/server';
import { requireAdminApi } from '../../../../lib/auth/admin';
import { articleSlugExists, deleteArticle, updateArticle } from '../../../../lib/firestore/articles';

export const runtime = 'nodejs';

export async function PATCH(request, { params }) {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  const payload = await request.json();
  if (payload.slug && await articleSlugExists(payload.slug, params.id)) {
    return NextResponse.json({ error: 'An article with this slug already exists.' }, { status: 409 });
  }
  await updateArticle(params.id, payload);
  return NextResponse.json({ ok: true });
}

export async function DELETE(_request, { params }) {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  await deleteArticle(params.id);
  return NextResponse.json({ ok: true });
}
