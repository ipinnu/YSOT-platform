import { createClient } from './supabase/server';

export async function getArticles() {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('articles')
    .select('*, authors(name, description, image_url)')
    .eq('status', 'published')
    .order('published_at', { ascending: false });
  if (error) return [];
  return (data || []).map(normalise);
}

export async function getArticleBySlug(slug) {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('articles')
    .select('*, authors(name, description, image_url)')
    .eq('slug', slug)
    .eq('status', 'published')
    .single();
  if (error || !data) return null;
  return normalise(data);
}

export async function getAllSlugs() {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('articles')
    .select('slug')
    .eq('status', 'published');
  return error ? [] : (data || []).map((r) => r.slug);
}

// Flatten the authors join and resolve display name.
function normalise(row) {
  const authorName = row.authors?.name || row.author || '';
  const authorBio = row.authors?.description || row.author_bio || '';
  const { authors: _authors, ...rest } = row;
  return { ...rest, author: authorName, author_bio: authorBio };
}
