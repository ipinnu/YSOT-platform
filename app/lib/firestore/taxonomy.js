import { db, FieldValue, hasFirebaseAdminConfig } from '../firebase/admin';
import { fromDoc, fromSnapshot } from './serialize';
import { DEFAULT_CATEGORIES } from './articles';

export async function getAuthors() {
  if (!hasFirebaseAdminConfig()) return [];
  try {
    const snapshot = await db().collection('authors').orderBy('name', 'asc').get();
    return fromSnapshot(snapshot);
  } catch (error) {
    console.error('Firestore authors read failed:', error);
    return [];
  }
}

export async function getAuthorById(id) {
  if (!hasFirebaseAdminConfig()) return null;
  try {
    return fromDoc(await db().collection('authors').doc(id).get());
  } catch {
    return null;
  }
}

export async function createAuthor(payload) {
  const doc = db().collection('authors').doc();
  await doc.set({
    ...payload,
    created_at: FieldValue.serverTimestamp(),
    updated_at: FieldValue.serverTimestamp(),
  });
  return { id: doc.id, ...payload };
}

export async function getCategories() {
  if (!hasFirebaseAdminConfig()) {
    return DEFAULT_CATEGORIES.map((name) => ({ id: name.toLowerCase().replace(/[^a-z0-9]+/g, '-'), name }));
  }
  try {
    const snapshot = await db().collection('categories').orderBy('name', 'asc').get();
    const rows = fromSnapshot(snapshot);
    if (rows.length) return rows;
  } catch (error) {
    console.error('Firestore categories read failed:', error);
  }
  return DEFAULT_CATEGORIES.map((name) => ({ id: name.toLowerCase().replace(/[^a-z0-9]+/g, '-'), name }));
}

export async function createCategory(name) {
  const id = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  await db().collection('categories').doc(id).set({
    name,
    created_at: FieldValue.serverTimestamp(),
    updated_at: FieldValue.serverTimestamp(),
  }, { merge: true });
  return { id, name };
}
