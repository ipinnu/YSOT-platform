import { db, FieldValue, hasFirebaseAdminConfig } from '../firebase/admin';
import { fromDoc, fromSnapshot } from './serialize';

export async function getGalleryItems({ publishedOnly = true } = {}) {
  if (!hasFirebaseAdminConfig()) return [];
  try {
    const snapshot = await db().collection('galleryItems').get();
    const rows = fromSnapshot(snapshot);
    return (publishedOnly ? rows.filter((item) => item.published) : rows)
      .sort((a, b) => {
        const orderCompare = Number(a.sort_order || 0) - Number(b.sort_order || 0);
        if (orderCompare !== 0) return orderCompare;
        return String(b.created_at || '').localeCompare(String(a.created_at || ''));
      });
  } catch (error) {
    console.error('Firestore gallery read failed:', error);
    return [];
  }
}

export async function getGalleryItemById(id) {
  if (!hasFirebaseAdminConfig()) return null;
  try {
    return fromDoc(await db().collection('galleryItems').doc(id).get());
  } catch {
    return null;
  }
}

export async function createGalleryItem(payload) {
  const doc = db().collection('galleryItems').doc();
  await doc.set({
    ...payload,
    created_at: FieldValue.serverTimestamp(),
    updated_at: FieldValue.serverTimestamp(),
  });
  return { id: doc.id, ...payload };
}

export async function updateGalleryItem(id, payload) {
  await db().collection('galleryItems').doc(id).update({
    ...payload,
    updated_at: FieldValue.serverTimestamp(),
  });
}

export async function deleteGalleryItem(id) {
  await db().collection('galleryItems').doc(id).delete();
}
