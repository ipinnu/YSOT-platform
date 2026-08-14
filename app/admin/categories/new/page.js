'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

export default function NewCategoryPage() {
  const router = useRouter();
  const [name, setName] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  async function handleSubmit(e) {
    e.preventDefault();
    if (!name.trim()) { setError('Category name is required.'); return; }
    setSaving(true);
    setError('');

    const response = await fetch('/api/admin/categories', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: name.trim() }),
    });
    const data = await response.json();

    if (!response.ok) {
      setError(data.error || 'Could not save category.');
      setSaving(false);
      return;
    }

    router.push('/admin');
    router.refresh();
  }

  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <div className="admin-header-row">
            <div>
              <h1>New Category</h1>
              <p>Add a content category for articles.</p>
            </div>
            <Link href="/admin" className="secondary">← Dashboard</Link>
          </div>
        </div>
      </section>

      <section className="section container">
        <div className="section-card" style={{ maxWidth: '480px' }}>
          <form className="article-form" onSubmit={handleSubmit}>
            <div className="form-field">
              <label className="form-label">Category name <span className="required">*</span></label>
              <input
                className="form-input"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="e.g. Foreign Policy"
                autoFocus
              />
            </div>

            {error && <p className="form-error" style={{ marginTop: '12px' }}>{error}</p>}

            <div className="form-actions" style={{ marginTop: '24px' }}>
              <Link href="/admin" className="secondary">Cancel</Link>
              <button type="submit" className="primary" disabled={saving}>
                {saving ? 'Saving…' : 'Save category'}
              </button>
            </div>
          </form>
        </div>
      </section>
    </div>
  );
}
