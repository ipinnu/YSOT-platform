'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { uploadImage } from '../../lib/upload';

const FORMATS = ['Webinar', 'Roundtable', 'Workshop', 'Forum', 'Dialogue', 'Panel'];

export default function EventForm({ event }) {
  const isEdit = Boolean(event);
  const router = useRouter();

  const [form, setForm] = useState({
    title: event?.title || '',
    description: event?.description || '',
    location: event?.location || '',
    format: event?.format || 'Forum',
    event_date: event?.event_date || '',
    status: event?.status || 'upcoming',
    published: event?.published ?? true,
    sort_order: event?.sort_order ?? 0,
    image_url: event?.image_url || '',
    recap_image_url: event?.recap_image_url || '',
    recap_title: event?.recap_title || '',
    recap_description: event?.recap_description || '',
  });

  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState(event?.image_url || '');
  const [recapFile, setRecapFile] = useState(null);
  const [recapPreview, setRecapPreview] = useState(event?.recap_image_url || '');
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

  function handleImageChange(e, kind) {
    const file = e.target.files?.[0];
    if (!file) return;
    const preview = URL.createObjectURL(file);
    if (kind === 'recap') {
      setRecapFile(file);
      setRecapPreview(preview);
      return;
    }
    setImageFile(file);
    setImagePreview(preview);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    if (!form.title.trim() || !form.description.trim() || !form.event_date) {
      setError('Title, description, and date are required.');
      return;
    }

    setSaving(true);
    setError('');

    try {
      setUploading(true);
      let image_url = form.image_url;
      let recap_image_url = form.recap_image_url;

      if (imageFile) {
        image_url = await uploadImage(imageFile, 'events', event?.id || 'pending');
      }
      if (recapFile) {
        recap_image_url = await uploadImage(recapFile, 'events/recap', event?.id || 'pending');
      }
      setUploading(false);

      const payload = {
        title: form.title.trim(),
        description: form.description.trim(),
        location: form.location.trim(),
        format: form.format,
        event_date: form.event_date,
        status: form.status,
        published: form.published,
        sort_order: form.sort_order,
        image_url,
        recap_image_url,
        recap_title: form.recap_title.trim(),
        recap_description: form.recap_description.trim(),
      };

      const response = await fetch(isEdit ? `/api/admin/events/${event.id}` : '/api/admin/events', {
        method: isEdit ? 'PATCH' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Could not save event.');

      router.push('/admin/events');
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
          <label className="form-label">Title <span className="required">*</span></label>
          <input className="form-input" name="title" value={form.title} onChange={handleChange} placeholder="Event title" />
        </div>

        <div className="form-field">
          <label className="form-label">Date <span className="required">*</span></label>
          <input className="form-input" type="date" name="event_date" value={form.event_date} onChange={handleChange} />
        </div>

        <div className="form-field">
          <label className="form-label">Format</label>
          <select className="form-input" name="format" value={form.format} onChange={handleChange}>
            {FORMATS.map((format) => (
              <option key={format} value={format}>{format}</option>
            ))}
          </select>
        </div>

        <div className="form-field">
          <label className="form-label">Location</label>
          <input className="form-input" name="location" value={form.location} onChange={handleChange} placeholder="e.g. Online, Yaba, Lagos" />
        </div>

        <div className="form-field">
          <label className="form-label">Status</label>
          <select className="form-input" name="status" value={form.status} onChange={handleChange}>
            <option value="upcoming">Upcoming</option>
            <option value="past">Past</option>
          </select>
        </div>

        <div className="form-field">
          <label className="form-label">Sort order</label>
          <input className="form-input" type="number" name="sort_order" value={form.sort_order} onChange={handleChange} min="0" />
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
            Show on public events page
          </label>
        </div>

        <div className="form-field span-2">
          <label className="form-label">Description <span className="required">*</span></label>
          <textarea
            className="form-input"
            name="description"
            value={form.description}
            onChange={handleChange}
            rows={4}
            placeholder="Short summary shown on the event card"
          />
        </div>

        <div className="form-field span-2">
          <label className="form-label">Card image</label>
          {imagePreview && (
            <div className="image-preview-wrap">
              <img src={imagePreview} alt="Card preview" className="image-preview" />
            </div>
          )}
          <input className="form-input-file" type="file" accept="image/*" onChange={(e) => handleImageChange(e, 'card')} />
        </div>

        {form.status === 'past' && (
          <>
            <div className="form-field span-2">
              <label className="form-label">Recap title</label>
              <input className="form-input" name="recap_title" value={form.recap_title} onChange={handleChange} placeholder="Optional headline for the recap modal" />
            </div>

            <div className="form-field span-2">
              <label className="form-label">Recap description</label>
              <textarea
                className="form-input"
                name="recap_description"
                value={form.recap_description}
                onChange={handleChange}
                rows={4}
                placeholder="Longer recap copy shown in the modal"
              />
            </div>

            <div className="form-field span-2">
              <label className="form-label">Recap image</label>
              {recapPreview && (
                <div className="image-preview-wrap">
                  <img src={recapPreview} alt="Recap preview" className="image-preview" />
                </div>
              )}
              <input className="form-input-file" type="file" accept="image/*" onChange={(e) => handleImageChange(e, 'recap')} />
            </div>
          </>
        )}
      </div>

      {uploading && <small className="form-hint" style={{ display: 'block', marginTop: '12px' }}>Uploading images…</small>}
      {error && <p className="form-error" style={{ marginTop: '16px' }}>{error}</p>}

      <div className="form-actions" style={{ marginTop: '24px' }}>
        <button type="button" className="secondary" disabled={saving} onClick={() => router.push('/admin/events')}>
          Cancel
        </button>
        <button type="submit" className="primary" disabled={saving}>
          {saving ? 'Saving…' : isEdit ? 'Save changes' : 'Create event'}
        </button>
      </div>
    </form>
  );
}
