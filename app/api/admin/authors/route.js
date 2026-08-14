import { NextResponse } from 'next/server';
import { requireAdminApi } from '../../../lib/auth/admin';
import { createAuthor } from '../../../lib/firestore/taxonomy';

export const runtime = 'nodejs';

export async function POST(request) {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  const payload = await request.json();
  if (!payload.name) {
    return NextResponse.json({ error: 'Author name is required.' }, { status: 400 });
  }
  const author = await createAuthor(payload);
  return NextResponse.json({ author });
}

