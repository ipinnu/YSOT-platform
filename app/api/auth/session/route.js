import { NextResponse } from 'next/server';
import { adminAuth } from '../../../lib/firebase/admin';
import { isAdminEmail, isAdminUid, sessionMaxAgeMs, SESSION_COOKIE } from '../../../lib/auth/admin';

export const runtime = 'nodejs';

export async function POST(request) {
  try {
    const { idToken } = await request.json();
    if (!idToken) {
      return NextResponse.json({ error: 'Missing Firebase ID token.' }, { status: 400 });
    }

    const decoded = await adminAuth().verifyIdToken(idToken);
    if (!isAdminEmail(decoded.email) && !isAdminUid(decoded.uid)) {
      return NextResponse.json({ error: 'This account is not an admin.' }, { status: 403 });
    }

    const sessionCookie = await adminAuth().createSessionCookie(idToken, {
      expiresIn: sessionMaxAgeMs(),
    });

    const response = NextResponse.json({ ok: true });
    response.cookies.set(SESSION_COOKIE, sessionCookie, {
      maxAge: sessionMaxAgeMs() / 1000,
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
    });
    return response;
  } catch (error) {
    console.error('Firebase session creation failed:', error);
    return NextResponse.json({ error: 'Could not create admin session.' }, { status: 401 });
  }
}

export async function DELETE() {
  const response = NextResponse.json({ ok: true });
  response.cookies.set(SESSION_COOKIE, '', {
    maxAge: 0,
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
  });
  return response;
}
