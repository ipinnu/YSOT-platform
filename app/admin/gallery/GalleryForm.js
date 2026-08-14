'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { uploadImage } from '../../lib/upload';

export default function GalleryForm({ item }) {
  const isEdit = Boolean(item);
  const router = useRouter();

  const [form, setForm] = useState({
    alt: item?.alt || '',
    sort_order: item?.sort_order ?? 0,
    published: item?.published ?? true,
    image_url: item?.image_url || '',
  });
  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState(item?.image_url || '');
  const [uploading, setUploading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  function handleChange(e) {
    const { name, value, type, checked } = e.target;
    setForm((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : type === 'number' ? Number(value) : value,
    }));
  }

  function handleImageChange(e) {
    const file = e.target.files?.[0];
    if (!file) return;
    setImageFile(file);
    setImagePreview(URL.createObjectURL(file));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    if (!form.alt.trim()) {
      setError('Caption is required.');
      return;
    }
    if (!isEdit && !imageFile && !form.image_url) {
      setError('Please choose an image.');
      return;
    }

    setSaving(true);
    setError('');

    try {
      let image_url = form.image_url;
      if (imageFile) {
        setUploading(true);
        image_url = await uploadImage(imageFile, 'gallery', item?.id || 'pending');
        setUploading(false);
      }

      if (!image_url) {
        setError('Please choose an image.');
        setSaving(false);
        return;
      }

      const payload = {
        alt: form.alt.trim(),
        sort_order: form.sort_order,
        published: form.published,
        image_url,
      };

      const response = await fetch(isEdit ? `/api/admin/gallery/${item.id}` : '/api/admin/gallery', {
        method: isEdit ? 'PATCH' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Could not save gallery item.');

      router.push('/admin/gallery');
      router.refresh();
    } catch (err) {
      setError(err.message || 'Something went wrong. Please try again.');
      setSaving(false);
      setUploading(false);
    }
  }

  return (
    <form className="article-form" onSubmit={handleSubmit}>
      <div className="form-grid-2">
        <div className="form-field span-2">
          <label className="form-label">Caption <span className="required">*</span></label>
          <input
            className="form-input"
            name="alt"
            value={form.alt}
            onChange={handleChange}
            placeholder="Describe this photo for accessibility"
          />
        </div>

        <div className="form-field">
          <label className="form-label">Sort order</label>
          <input
            className="form-input"
            type="number"
            name="sort_order"
            value={form.sort_order}
            onChange={handleChange}
            min="0"
          />
          <small className="form-hint">Lower numbers appear first.</small>
        </div>

        <div className="form-field">
          <label className="form-label" style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer', marginTop: '28px' }}>
            <input
              type="checkbox"
              name="published"
              checked={form.published}
              onChange={handleChange}
              style={{ width: '16px', height: '16px', flexShrink: 0 }}
            />
            Show on public gallery
          </label>
        </div>

        <div className="form-field span-2">
          <label className="form-label">Photo {!isEdit && <span className="required">*</span>}</label>
          {imagePreview && (
            <div className="image-preview-wrap">
              <img src={imagePreview} alt="Preview" className="image-preview" />
            </div>
          )}
          <input className="form-input-file" type="file" accept="image/*" onChange={handleImageChange} />
          {uploading && <small className="form-hint">Uploading image…</small>}
        </div>
      </div>

      {error && <p className="form-error" style={{ marginTop: '16px' }}>{error}</p>}

      <div className="form-actions" style={{ marginTop: '24px' }}>
        <button type="button" className="secondary" disabled={saving} onClick={() => router.push('/admin/gallery')}>
          Cancel
        </button>
        <button type="submit" className="primary" disabled={saving}>
          {saving ? 'Saving…' : isEdit ? 'Save changes' : 'Add photo'}
        </button>
      </div>
    </form>
  );
}
