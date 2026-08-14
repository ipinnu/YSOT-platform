import 'server-only';
import crypto from 'node:crypto';

const encoder = new TextEncoder();

function base64url(input) {
  const buffer = Buffer.isBuffer(input) ? input : Buffer.from(input);
  return buffer
    .toString('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
}

function fromBase64url(input) {
  const normalized = input.replace(/-/g, '+').replace(/_/g, '/');
  return Buffer.from(normalized, 'base64').toString('utf8');
}

function sessionSecret() {
  const secret = process.env.ADMIN_SESSION_SECRET || process.env.FIREBASE_PRIVATE_KEY;
  if (!secret) throw new Error('ADMIN_SESSION_SECRET is not configured.');
  return secret;
}

function sign(value) {
  return base64url(
    crypto
      .createHmac('sha256', sessionSecret())
      .update(value)
      .digest()
  );
}

export function createAdminSessionToken({ uid, email, expiresInMs }) {
  const payload = base64url(JSON.stringify({
    uid,
    email: email || '',
    exp: Date.now() + expiresInMs,
  }));
  return `${payload}.${sign(payload)}`;
}

export function verifyAdminSessionToken(token) {
  if (!token || !token.includes('.')) return null;
  const [payload, signature] = token.split('.');
  const expected = sign(payload);
  const a = encoder.encode(signature);
  const b = encoder.encode(expected);
  if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) return null;

  try {
    const data = JSON.parse(fromBase64url(payload));
    if (!data.exp || Date.now() > data.exp) return null;
    return data;
  } catch {
    return null;
  }
}

export async function verifyFirebaseIdTokenViaRest(idToken) {
  const apiKey = process.env.NEXT_PUBLIC_FIREBASE_API_KEY;
  if (!apiKey) throw new Error('Firebase API key is not configured.');

  const response = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${apiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ idToken }),
    }
  );
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.error?.message || 'Firebase token verification failed.');
  }

  const user = data.users?.[0];
  if (!user?.localId) throw new Error('Firebase token verification failed.');
  return {
    uid: user.localId,
    email: user.email || '',
  };
}
