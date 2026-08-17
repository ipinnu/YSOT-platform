import { db, FieldValue, hasFirebaseAdminConfig, Timestamp } from '../firebase/admin';
import { fromDoc, fromSnapshot } from './serialize';

export const DEFAULT_CATEGORIES = [
  'Governance',
  'Economy',
  'Education',
  'Security',
  'Institutions',
  'Culture',
  'National Cohesion',
  'Economic Policy',
  'Public Finance',
  'General',
];

function articlesRef() {
  return db().collection('articles');
}

export function normalizeArticle(row) {
  if (!row) return null;
  return {
    ...row,
    author: row.author || '',
    author_bio: row.author_bio || '',
    category: row.category || 'General',
    content: Array.isArray(row.content) ? row.content : [],
    excerpt: row.excerpt || '',
    featured: Boolean(row.featured),
    image_url: row.image_url || '',
    read_time: row.read_time || '5 min read',
    status: row.status || 'draft',
  };
}

function timeValue(value) {
  if (!value) return 0;
  const date = value instanceof Date ? value : new Date(value);
  return Number.isNaN(date.getTime()) ? 0 : date.getTime();
}

export async function getPublishedArticles() {
  if (!hasFirebaseAdminConfig()) return [];
  try {
    const snapshot = await articlesRef()
      .where('status', '==', 'published')
      .get();
    return fromSnapshot(snapshot)
      .map(normalizeArticle)
      .sort((a, b) => timeValue(b.published_at) - timeValue(a.published_at));
  } catch (error) {
    console.error('Firestore articles read failed:', error);
    return [];
  }
}

export async function getPublishedArticleBySlug(slug) {
  if (!hasFirebaseAdminConfig()) return null;
  try {
    const snapshot = await articlesRef()
      .where('slug', '==', slug)
      .limit(1)
      .get();
    const article = normalizeArticle(fromDoc(snapshot.docs[0]));
    return article?.status === 'published' ? article : null;
  } catch (error) {
    console.error('Firestore article read failed:', error);
    return null;
  }
}

export async function getPublishedSlugs() {
  if (!hasFirebaseAdminConfig()) return [];
  try {
    const snapshot = await articlesRef().where('status', '==', 'published').select('slug').get();
    return snapshot.docs.map((doc) => doc.data().slug).filter(Boolean);
  } catch {
    return [];
  }
}

export async function getAdminArticles() {
  if (!hasFirebaseAdminConfig()) return [];
  const snapshot = await articlesRef().get();
  return fromSnapshot(snapshot)
    .map(normalizeArticle)
    .sort((a, b) => timeValue(b.updated_at || b.created_at) - timeValue(a.updated_at || a.created_at));
}

export async function getArticleById(id) {
  if (!hasFirebaseAdminConfig()) return null;
  try {
    return normalizeArticle(fromDoc(await articlesRef().doc(id).get()));
  } catch {
    return null;
  }
}

export async function articleSlugExists(slug, exceptId) {
  const snapshot = await articlesRef().where('slug', '==', slug).limit(2).get();
  return snapshot.docs.some((doc) => doc.id !== exceptId);
}

export async function uniqueArticleSlug(baseSlug, exceptId) {
  const cleanBase = String(baseSlug || 'article')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '') || 'article';

  let slug = cleanBase;
  let suffix = 2;
  while (await articleSlugExists(slug, exceptId)) {
    slug = `${cleanBase}-${suffix}`;
    suffix += 1;
  }
  return slug;
}

export async function createArticle(payload) {
  const now = FieldValue.serverTimestamp();
  const doc = articlesRef().doc();
  await doc.set({
    ...payload,
    created_at: now,
    updated_at: now,
    published_at: payload.status === 'published'
      ? Timestamp.fromDate(new Date(payload.published_at || Date.now()))
      : null,
  });
  return { id: doc.id, ...payload };
}

export async function updateArticle(id, payload) {
  const current = await getArticleById(id);
  const next = {
    ...payload,
    updated_at: FieldValue.serverTimestamp(),
  };
  if (payload.status === 'published' && !current?.published_at) {
    next.published_at = Timestamp.fromDate(new Date());
  }
  if (payload.status !== 'published') {
    next.published_at = null;
  }
  await articlesRef().doc(id).update(next);
}

export async function deleteArticle(id) {
  await articlesRef().doc(id).delete();
}
