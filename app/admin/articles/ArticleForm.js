'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '../../lib/supabase/client';
import { textToBlocks, blocksToText } from '../../lib/content';

const FALLBACK_CATEGORIES = [
  'Governance', 'Economy', 'Education', 'Security',
  'Institutions', 'Culture', 'National Cohesion',
  'Economic Policy', 'Public Finance', 'General',
];

function slugify(text) {
  return text.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
}

export default function ArticleForm({ article, authors = [], categories = [] }) {
  const isEdit = Boolean(article);
  const router = useRouter();

  const categoryList = categories.length > 0 ? categories.map((c) => c.name) : FALLBACK_CATEGORIES;
  const defaultCategory = article?.category || categoryList[0] || 'General';
  const contentText = article?.content ? blocksToText(article.content) : '';

  const [form, setForm] = useState({
    title: article?.title || '',
    slug: article?.slug || '',
    author_id: article?.author_id || '',
    author_bio: article?.author_bio || '',
    category: defaultCategory,
    excerpt: article?.excerpt || '',
    content: contentText,
    read_time: article?.read_time || '5 min read',
    image_url: article?.image_url || '',
    featured: article?.featured || false,
  });

  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState(article?.image_url || '');
  const [uploading, setUploading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [saveAction, setSaveAction] = useState(null);
  const [error, setError] = useState('');

  function handleChange(e) {
    const { name, value, type, checked } = e.target;
    const v = type === 'checkbox' ? checked : value;
    setForm((prev) => {
      const updated = { ...prev, [name]: v };
      if (name === 'title' && !isEdit) updated.slug = slugify(value);
      return updated;
    });
  }

  function handleImageChange(e) {
    const file = e.target.files?.[0];
    if (!file) return;
    setImageFile(file);
    setImagePreview(URL.createObjectURL(file));
  }

  async function uploadImage() {
    if (!imageFile) return form.image_url;
    const supabase = createClient();
    const ext = imageFile.name.split('.').pop();
    const filename = `${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`;
    const { error: uploadError } = await supabase.storage
      .from('article-images')
      .upload(filename, imageFile, { upsert: true });
    if (uploadError) throw uploadError;
    const { data: { publicUrl } } = supabase.storage.from('article-images').getPublicUrl(filename);
    return publicUrl;
  }

  async function handleSubmit(status) {
    if (!form.title || !form.slug || !form.excerpt || !form.content) {
      setError('Please fill in all required fields.');
      return;
    }
    setSaving(true);
    setSaveAction(status);
    setError('');

    try {
      setUploading(true);
      const image_url = await uploadImage();
      setUploading(false);

      const selectedAuthor = authors.find((a) => a.id === form.author_id);
      const supabase = createClient();

      const payload = {
        title: form.title,
        slug: form.slug,
        author_id: form.author_id || null,
        author: selectedAuthor?.name || '',
        author_bio: form.author_bio,
        category: form.category,
        excerpt: form.excerpt,
        content: textToBlocks(form.content),
        read_time: form.read_time,
        image_url,
        featured: form.featured,
        status,
        ...(status === 'published' && !article?.published_at
          ? { published_at: new Date().toISOString() }
          : {}),
      };

      if (isEdit) {
        const { error: e } = await supabase.from('articles').update(payload).eq('id', article.id);
        if (e) throw e;
      } else {
        const { error: e } = await supabase.from('articles').insert(payload);
        if (e) throw e;
      }

      router.push('/admin');
      router.refresh();
    } catch (err) {
      setError(err.message || 'Something went wrong. Please try again.');
      setSaving(false);
      setSaveAction(null);
      setUploading(false);
    }
  }

  return (
    <div className="article-form">
      <div className="form-grid-2">

        <div className="form-field span-2">
          <label className="form-label">Title <span className="required">*</span></label>
          <input className="form-input" name="title" value={form.title} onChange={handleChange} placeholder="Article title" />
        </div>

        <div className="form-field span-2">
          <label className="form-label">URL Slug <span className="required">*</span></label>
          <input className="form-input" name="slug" value={form.slug} onChange={handleChange} placeholder="article-url-slug" />
          <small className="form-hint">Public URL: /posts/{form.slug || 'your-slug'}</small>
        </div>

        <div className="form-field">
          <label className="form-label">Author</label>
          {authors.length > 0 ? (
            <select className="form-input" name="author_id" value={form.author_id} onChange={handleChange}>
              <option value="">— Select author —</option>
              {authors.map((a) => (
                <option key={a.id} value={a.id}>{a.name}</option>
              ))}
            </select>
          ) : (
            <p style={{ color: 'var(--muted)', fontSize: '0.85rem', padding: '10px 0' }}>
              No authors yet.{' '}
              <a href="/admin/authors/new" style={{ color: 'var(--primary)' }}>Add an author →</a>
            </p>
          )}
        </div>

        <div className="form-field">
          <label className="form-label">Category</label>
          <select className="form-input" name="category" value={form.category} onChange={handleChange}>
            {categoryList.map((c) => <option key={c}>{c}</option>)}
          </select>
        </div>

        <div className="form-field">
          <label className="form-label">Author bio</label>
          <input className="form-input" name="author_bio" value={form.author_bio} onChange={handleChange} placeholder="Short author description" />
        </div>

        <div className="form-field">
          <label className="form-label">Read time</label>
          <input className="form-input" name="read_time" value={form.read_time} onChange={handleChange} placeholder="e.g. 8 min read" />
        </div>

        <div className="form-field span-2">
          <label className="form-label" style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer' }}>
            <input
              type="checkbox"
              name="featured"
              checked={form.featured}
              onChange={handleChange}
              style={{ width: '16px', height: '16px', flexShrink: 0 }}
            />
            Feature this article — shown as the hero on the Posts page
          </label>
        </div>

        <div className="form-field span-2">
          <label className="form-label">Featured image</label>
          {imagePreview && (
            <div className="image-preview-wrap">
              <img src={imagePreview} alt="Preview" className="image-preview" />
            </div>
          )}
          <input className="form-input-file" type="file" accept="image/*" onChange={handleImageChange} />
          {uploading && <small className="form-hint">Uploading image…</small>}
        </div>

        <div className="form-field span-2">
          <label className="form-label">Excerpt / Summary <span className="required">*</span></label>
          <textarea
            className="form-input"
            name="excerpt"
            value={form.excerpt}
            onChange={handleChange}
            rows={3}
            placeholder="Short summary shown on listing and social preview"
          />
        </div>

        <div className="form-field span-2">
          <label className="form-label">Content <span className="required">*</span></label>
          <textarea
            className="form-input form-content"
            name="content"
            value={form.content}
            onChange={handleChange}
            rows={22}
            placeholder={`Write the full article here.\n\nSeparate paragraphs with a blank line.\n\n## Section heading (H2)\n\n### Sub-heading (H3)\n\n> Pull quote or blockquote text\n\n[img: https://example.com/photo.jpg | Optional caption]`}
          />
          <small className="form-hint">
            Blank line = new paragraph · ## H2 · ### H3 · &gt; blockquote · [img: url | caption]
          </small>
        </div>
      </div>

      {error && <p className="form-error" style={{ marginTop: '16px' }}>{error}</p>}

      <div className="form-actions" style={{ marginTop: '24px' }}>
        <button type="button" className="secondary" disabled={saving} onClick={() => handleSubmit('draft')}>
          {saving && saveAction === 'draft' ? 'Saving…' : 'Save as draft'}
        </button>
        <button type="button" className="primary" disabled={saving} onClick={() => handleSubmit('published')}>
          {saving && saveAction === 'published' ? 'Publishing…' : 'Publish'}
        </button>
      </div>
    </div>
  );
}
