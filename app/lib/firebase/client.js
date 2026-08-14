'use client';

import { getApps, initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
};

export function firebaseApp() {
  if (!firebaseConfig.apiKey || !firebaseConfig.appId) {
    throw new Error('Firebase web app config is missing.');
  }
  return getApps().length ? getApps()[0] : initializeApp(firebaseConfig);
}

export function firebaseAuth() {
  return getAuth(firebaseApp());
}
