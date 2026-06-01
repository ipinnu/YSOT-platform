'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { createClient } from '../../../lib/supabase/client';

export default function NewAuthorPage() {
  const router = useRouter();
  const [form, setForm] = useState({ name: '', description: '' });
  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState('');
  const [uploading, setUploading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  function handleChange(e) {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  }

  function handleImageChange(e) {
    const file = e.target.files?.[0];
    if (!file) return;
    setImageFile(file);
    setImagePreview(URL.createObjectURL(file));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    if (!form.name.trim()) { setError('Name is required.'); return; }
    setSaving(true);
    setError('');

    try {
      const supabase = createClient();
      let image_url = '';

      if (imageFile) {
        setUploading(true);
        const ext = imageFile.name.split('.').pop();
        const filename = `authors/${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`;
        const { error: uploadError } = await supabase.storage
          .from('article-images')
          .upload(filename, imageFile, { upsert: true });
        if (uploadError) throw uploadError;
        const { data: { publicUrl } } = supabase.storage.from('article-images').getPublicUrl(filename);
        image_url = publicUrl;
        setUploading(false);
      }

      const { error: insertError } = await supabase
        .from('authors')
        .insert({ name: form.name.trim(), description: form.description.trim(), image_url });
      if (insertError) throw insertError;

      router.push('/admin');
      router.refresh();
    } catch (err) {
      setError(err.message || 'Something went wrong.');
      setSaving(false);
      setUploading(false);
    }
  }

  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <div className="admin-header-row">
            <div>
              <h1>New Author</h1>
              <p>Add a contributor profile for article attribution.</p>
            </div>
            <Link href="/admin" className="secondary">← Dashboard</Link>
          </div>
        </div>
      </section>

      <section className="section container">
        <div className="section-card">
          <form className="article-form" onSubmit={handleSubmit}>
            <div className="form-grid-2">
              <div className="form-field span-2">
                <label className="form-label">Name <span className="required">*</span></label>
                <input className="form-input" name="name" value={form.name} onChange={handleChange} placeholder="e.g. Prof. Sunday E. Atawodi" />
              </div>

              <div className="form-field span-2">
                <label className="form-label">Bio / Description</label>
                <textarea className="form-input" name="description" value={form.description} onChange={handleChange} rows={4} placeholder="Short biography shown at the bottom of articles" />
              </div>

              <div className="form-field span-2">
                <label className="form-label">Photo</label>
                {imagePreview && (
                  <div className="image-preview-wrap">
                    <img src={imagePreview} alt="Preview" className="image-preview" style={{ maxWidth: '160px', borderRadius: '50%' }} />
                  </div>
                )}
                <input className="form-input-file" type="file" accept="image/*" onChange={handleImageChange} />
                {uploading && <small className="form-hint">Uploading…</small>}
              </div>
            </div>

            {error && <p className="form-error" style={{ marginTop: '16px' }}>{error}</p>}

            <div className="form-actions" style={{ marginTop: '24px' }}>
              <Link href="/admin" className="secondary">Cancel</Link>
              <button type="submit" className="primary" disabled={saving}>
                {saving ? 'Saving…' : 'Save author'}
              </button>
            </div>
          </form>
        </div>
      </section>
    </div>
  );
}
