import { Timestamp } from '../firebase/admin';

export function toIso(value) {
  if (!value) return null;
  if (value instanceof Timestamp) return value.toDate().toISOString();
  if (typeof value.toDate === 'function') return value.toDate().toISOString();
  if (value instanceof Date) return value.toISOString();
  return value;
}

export function fromDoc(doc) {
  if (!doc?.exists) return null;
  const data = doc.data() || {};
  return {
    id: doc.id,
    ...data,
    created_at: toIso(data.created_at),
    updated_at: toIso(data.updated_at),
    published_at: toIso(data.published_at),
  };
}

export function fromSnapshot(snapshot) {
  return snapshot.docs.map(fromDoc).filter(Boolean);
}
