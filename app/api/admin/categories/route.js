import { NextResponse } from 'next/server';
import { requireAdminApi } from '../../../lib/auth/admin';
import { createCategory } from '../../../lib/firestore/taxonomy';

export const runtime = 'nodejs';

export async function POST(request) {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  const { name } = await request.json();
  if (!name?.trim()) {
    return NextResponse.json({ error: 'Category name is required.' }, { status: 400 });
  }
  const category = await createCategory(name.trim());
  return NextResponse.json({ category });
}

