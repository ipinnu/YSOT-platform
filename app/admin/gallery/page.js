'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';

export default function AdminGalleryPage() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState('');
  const [workingId, setWorkingId] = useState(null);
  const [actionError, setActionError] = useState('');

  useEffect(() => {
    fetchItems();
  }, []);

  async function fetchItems() {
    setLoadError('');
    try {
      const response = await fetch('/api/admin/gallery');
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Gallery items could not be loaded.');
      setItems(data.items || []);
    } catch (error) {
      setLoadError(error.message || 'Gallery items could not be loaded.');
    } finally {
      setLoading(false);
    }
  }

  async function handleDelete(id, alt) {
    if (!confirm(`Delete "${alt || 'this photo'}"? This cannot be undone.`)) return;
    setWorkingId(id);
    setActionError('');
    try {
      const response = await fetch(`/api/admin/gallery/${id}`, { method: 'DELETE' });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'That photo could not be deleted.');
      await fetchItems();
    } catch (error) {
      setActionError(error.message || 'That photo could not be deleted.');
    }
    setWorkingId(null);
  }

  async function handleTogglePublished(id, current) {
    setWorkingId(id);
    setActionError('');
    try {
      const response = await fetch(`/api/admin/gallery/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ published: !current }),
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'That change could not be saved.');
      await fetchItems();
    } catch (error) {
      setActionError(error.message || 'That change could not be saved.');
    }
    setWorkingId(null);
  }

  return (
    <div className="page admin-page">
      <section className="admin-command-hero">
        <div className="container admin-command-inner">
          <div className="admin-command-copy">
            <span className="admin-eyebrow">
              <span className="admin-live-dot" />
              Gallery
            </span>
            <h1>Photo Library</h1>
            <p>Upload and manage photos shown on the public gallery page.</p>
          </div>
          <div className="admin-command-actions">
            <Link href="/admin/gallery/new" className="primary admin-main-action">
              <span aria-hidden="true">+</span> Add photo
            </Link>
            <Link href="/admin" className="admin-import-action">← Dashboard</Link>
          </div>
        </div>
      </section>

      <main className="container admin-dashboard">
        {loadError && (
          <div className="admin-load-error" role="alert">
            <span>{loadError}</span>
            <button type="button" onClick={fetchItems}>Try again</button>
          </div>
        )}

        {actionError && (
          <div className="admin-load-error" role="alert">
            <span>{actionError}</span>
            <button type="button" onClick={() => setActionError('')}>Dismiss</button>
          </div>
        )}

        <section className="admin-library-panel">
          <div className="admin-panel-heading">
            <div>
              <span className="admin-section-kicker">Public gallery</span>
              <h2>Photos</h2>
              <p>{loading ? 'Loading gallery…' : `${items.length} photo${items.length === 1 ? '' : 's'}`}</p>
            </div>
            <Link href="/admin/gallery/new" className="admin-round-plus" aria-label="Add a photo" title="Add a photo">+</Link>
          </div>

          {loading ? (
            <div className="admin-library-loading"><span /><span /><span /></div>
          ) : items.length === 0 ? (
            <div className="admin-library-empty">
              <div aria-hidden="true">G</div>
              <h3>No gallery photos yet</h3>
              <p>Upload your first photo to populate the public gallery.</p>
              <Link href="/admin/gallery/new" className="primary">+ Add first photo</Link>
            </div>
          ) : (
            <div className="admin-content-list">
              {items.map((item) => {
                const busy = workingId === item.id;
                return (
                  <article key={item.id} className="admin-content-row">
                    <div className="admin-content-thumb">
                      {item.image_url ? (
                        <img src={item.image_url} alt="" />
                      ) : (
                        <span>?</span>
                      )}
                    </div>
                    <div className="admin-content-main">
                      <div className="admin-content-flags">
                        <span className="admin-status-badge" data-status={item.published ? 'published' : 'draft'}>
                          {item.published ? 'Published' : 'Hidden'}
                        </span>
                        <span className="admin-category-label">Order {item.sort_order}</span>
                      </div>
                      <h3>
                        <Link href={`/admin/gallery/${item.id}/edit`}>{item.alt || 'Untitled photo'}</Link>
                      </h3>
                    </div>
                    <div className="admin-content-actions">
                      <Link href={`/admin/gallery/${item.id}/edit`} className="admin-row-edit">Edit</Link>
                      <button type="button" disabled={busy} onClick={() => handleTogglePublished(item.id, item.published)}>
                        {item.published ? 'Hide' : 'Publish'}
                      </button>
                      <button type="button" className="delete" disabled={busy} onClick={() => handleDelete(item.id, item.alt)}>
                        Delete
                      </button>
                    </div>
                  </article>
                );
              })}
            </div>
          )}
        </section>
      </main>
    </div>
  );
}
