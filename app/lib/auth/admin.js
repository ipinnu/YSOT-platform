import 'server-only';
import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import { adminAuth } from '../firebase/admin';

export const SESSION_COOKIE = '__session';
const SESSION_DAYS = 5;

export function sessionMaxAgeMs() {
  return SESSION_DAYS * 24 * 60 * 60 * 1000;
}

export function adminEmails() {
  return new Set(
    String(process.env.ADMIN_EMAILS || '')
      .split(',')
      .map((email) => email.trim().toLowerCase())
      .filter(Boolean)
  );
}

export function adminUids() {
  return new Set(
    String(process.env.ADMIN_UIDS || '')
      .split(',')
      .map((uid) => uid.trim())
      .filter(Boolean)
  );
}

export function isAdminEmail(email) {
  const allowed = adminEmails();
  return Boolean(email && allowed.has(String(email).toLowerCase()));
}

export function isAdminUid(uid) {
  const allowed = adminUids();
  return Boolean(uid && allowed.has(uid));
}

export async function verifyAdminSession() {
  const cookieStore = await cookies();
  const session = cookieStore.get(SESSION_COOKIE)?.value;
  if (!session) return null;

  try {
    const decoded = await adminAuth().verifySessionCookie(session, true);
    if (!isAdminEmail(decoded.email) && !isAdminUid(decoded.uid)) return null;
    return decoded;
  } catch {
    return null;
  }
}

export async function requireAdmin() {
  const admin = await verifyAdminSession();
  if (!admin) redirect('/admin-login');
  return admin;
}

export async function requireAdminApi() {
  return verifyAdminSession();
}
