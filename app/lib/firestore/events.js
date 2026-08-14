import { db, FieldValue, hasFirebaseAdminConfig } from '../firebase/admin';
import { formatEventDate } from '../dates';
import { fromDoc, fromSnapshot } from './serialize';

function normalize(row) {
  if (!row) return null;
  return {
    ...row,
    image_url: row.image_url || '',
    recap_image_url: row.recap_image_url || '',
    date: formatEventDate(row.event_date),
  };
}

function sortEvents(rows) {
  return rows.sort((a, b) => {
    const dateCompare = String(a.event_date || '').localeCompare(String(b.event_date || ''));
    if (dateCompare !== 0) return dateCompare;
    return Number(a.sort_order || 0) - Number(b.sort_order || 0);
  });
}

export async function getEvents({ publishedOnly = true } = {}) {
  if (!hasFirebaseAdminConfig()) return [];
  try {
    const snapshot = await db().collection('events').get();
    const rows = fromSnapshot(snapshot).map(normalize);
    return sortEvents(publishedOnly ? rows.filter((item) => item.published) : rows);
  } catch (error) {
    console.error('Firestore events read failed:', error);
    return [];
  }
}

export async function getEventById(id) {
  if (!hasFirebaseAdminConfig()) return null;
  try {
    return normalize(fromDoc(await db().collection('events').doc(id).get()));
  } catch {
    return null;
  }
}

export async function createEvent(payload) {
  const doc = db().collection('events').doc();
  await doc.set({
    ...payload,
    created_at: FieldValue.serverTimestamp(),
    updated_at: FieldValue.serverTimestamp(),
  });
  return { id: doc.id, ...payload };
}

export async function updateEvent(id, payload) {
  await db().collection('events').doc(id).update({
    ...payload,
    updated_at: FieldValue.serverTimestamp(),
  });
}

export async function deleteEvent(id) {
  await db().collection('events').doc(id).delete();
}
