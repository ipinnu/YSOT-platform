import { NextResponse } from 'next/server';
import { requireAdminApi } from '../../../lib/auth/admin';
import { createEvent, getEvents } from '../../../lib/firestore/events';

export const runtime = 'nodejs';

export async function GET() {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  const events = await getEvents({ publishedOnly: false });
  return NextResponse.json({ events });
}

export async function POST(request) {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  const payload = await request.json();
  if (!payload.title || !payload.description || !payload.event_date) {
    return NextResponse.json({ error: 'Title, description, and date are required.' }, { status: 400 });
  }
  const event = await createEvent(payload);
  return NextResponse.json({ event });
}

