import { NextResponse } from 'next/server';
import { requireAdminApi } from '../../../lib/auth/admin';
import { sanitizeFilename, uploadBufferToR2 } from '../../../lib/r2/server';

export const runtime = 'nodejs';
export const maxDuration = 60;

const PREFIXES = new Set([
  'articles',
  'authors',
  'gallery',
  'events',
  'events/recap',
  'newspapers/imports',
  'newspapers/crops',
]);

export async function POST(request) {
  try {
    const admin = await requireAdminApi();
    if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
    const formData = await request.formData();
    const file = formData.get('file');
    const prefix = String(formData.get('prefix') || '').replace(/^\/|\/$/g, '');
    const ownerId = String(formData.get('ownerId') || 'pending').replace(/[^a-zA-Z0-9-_]/g, '-');

    if (!file || typeof file.arrayBuffer !== 'function') {
      return NextResponse.json({ error: 'No file supplied.' }, { status: 400 });
    }
    if (!PREFIXES.has(prefix)) {
      return NextResponse.json({ error: 'Invalid upload destination.' }, { status: 400 });
    }

    const filename = sanitizeFilename(file.name);
    const bytes = Buffer.from(await file.arrayBuffer());
    const key = `${prefix}/${ownerId}/${Date.now()}-${filename}`;
    const publicUrl = await uploadBufferToR2({
      key,
      body: bytes,
      contentType: file.type,
    });

    return NextResponse.json({
      key,
      url: publicUrl,
      uploadedBy: admin.uid,
    });
  } catch (error) {
    console.error('Upload failed:', error);
    return NextResponse.json({ error: error.message || 'Upload failed.' }, { status: 500 });
  }
}

