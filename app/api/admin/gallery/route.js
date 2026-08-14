import { NextResponse } from 'next/server';
import { requireAdminApi } from '../../../lib/auth/admin';
import { createGalleryItem, getGalleryItems } from '../../../lib/firestore/gallery';

export const runtime = 'nodejs';

export async function GET() {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  const items = await getGalleryItems({ publishedOnly: false });
  return NextResponse.json({ items });
}

export async function POST(request) {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  const payload = await request.json();
  if (!payload.alt || !payload.image_url) {
    return NextResponse.json({ error: 'Caption and image are required.' }, { status: 400 });
  }
  const item = await createGalleryItem(payload);
  return NextResponse.json({ item });
}

