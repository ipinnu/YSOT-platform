import 'server-only';
import fs from 'node:fs';
import path from 'node:path';
import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue, Timestamp } from 'firebase-admin/firestore';

function getServiceAccount() {
  if (process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
    return {
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    };
  }

  const localPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  if (localPath) {
    const resolved = path.resolve(process.cwd(), localPath);
    if (fs.existsSync(resolved)) {
      const json = JSON.parse(fs.readFileSync(resolved, 'utf8'));
      return {
        projectId: json.project_id,
        clientEmail: json.client_email,
        privateKey: json.private_key,
      };
    }
  }

  throw new Error('Firebase Admin credentials are not configured.');
}

export function hasFirebaseAdminConfig() {
  if (process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) return true;
  const localPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  return Boolean(localPath && fs.existsSync(path.resolve(process.cwd(), localPath)));
}

export function getAdminApp() {
  if (getApps().length > 0) return getApps()[0];

  return initializeApp({
    credential: cert(getServiceAccount()),
    projectId: process.env.FIREBASE_PROJECT_ID || 'ysot-web-project',
  });
}

export async function adminAuth() {
  const { getAuth } = await import('firebase-admin/auth');
  return getAuth(getAdminApp());
}

export function db() {
  return getFirestore(getAdminApp());
}

export { FieldValue, Timestamp };
