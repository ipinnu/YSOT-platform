import { NextResponse } from 'next/server';

export const runtime = 'nodejs';

export async function POST() {
  return NextResponse.json(
    { error: 'Newspaper import is coming soon.' },
    { status: 503 }
  );
}
