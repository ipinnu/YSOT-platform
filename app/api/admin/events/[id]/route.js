import { NextResponse } from 'next/server';
import { requireAdminApi } from '../../../../lib/auth/admin';
import { deleteEvent, updateEvent } from '../../../../lib/firestore/events';

export const runtime = 'nodejs';

export async function PATCH(request, { params }) {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  await updateEvent(params.id, await request.json());
  return NextResponse.json({ ok: true });
}

export async function DELETE(_request, { params }) {
  const admin = await requireAdminApi();
  if (!admin) return NextResponse.json({ error: 'Unauthorized.' }, { status: 401 });
  await deleteEvent(params.id);
  return NextResponse.json({ ok: true });
}
