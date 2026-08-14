'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { formatEventDate } from '../../lib/dates';

export default function AdminEventsPage() {
  const [events, setEvents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState('');
  const [workingId, setWorkingId] = useState(null);
  const [actionError, setActionError] = useState('');

  useEffect(() => {
    fetchEvents();
  }, []);

  async function fetchEvents() {
    setLoadError('');
    try {
      const response = await fetch('/api/admin/events');
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Events could not be loaded.');
      setEvents(data.events || []);
    } catch (error) {
      setLoadError(error.message || 'Events could not be loaded.');
    } finally {
      setLoading(false);
    }
  }

  async function handleDelete(id, title) {
    if (!confirm(`Delete "${title}"? This cannot be undone.`)) return;
    setWorkingId(id);
    setActionError('');
    try {
      const response = await fetch(`/api/admin/events/${id}`, { method: 'DELETE' });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'That event could not be deleted.');
      await fetchEvents();
    } catch (error) {
      setActionError(error.message || 'That event could not be deleted.');
    }
    setWorkingId(null);
  }

  async function handleTogglePublished(id, current) {
    setWorkingId(id);
    setActionError('');
    try {
      const response = await fetch(`/api/admin/events/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ published: !current }),
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'That change could not be saved.');
      await fetchEvents();
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
              Events
            </span>
            <h1>Event Calendar</h1>
            <p>Create upcoming events and add recap photos for past sessions.</p>
          </div>
          <div className="admin-command-actions">
            <Link href="/admin/events/new" className="primary admin-main-action">
              <span aria-hidden="true">+</span> New event
            </Link>
            <Link href="/admin" className="admin-import-action">← Dashboard</Link>
          </div>
        </div>
      </section>

      <main className="container admin-dashboard">
        {loadError && (
          <div className="admin-load-error" role="alert">
            <span>{loadError}</span>
            <button type="button" onClick={fetchEvents}>Try again</button>
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
              <span className="admin-section-kicker">Public events page</span>
              <h2>Events</h2>
              <p>{loading ? 'Loading events…' : `${events.length} event${events.length === 1 ? '' : 's'}`}</p>
            </div>
            <Link href="/admin/events/new" className="admin-round-plus" aria-label="Add an event" title="Add an event">+</Link>
          </div>

          {loading ? (
            <div className="admin-library-loading"><span /><span /><span /></div>
          ) : events.length === 0 ? (
            <div className="admin-library-empty">
              <div aria-hidden="true">E</div>
              <h3>No events yet</h3>
              <p>Create your first event to populate the public events page.</p>
              <Link href="/admin/events/new" className="primary">+ Create first event</Link>
            </div>
          ) : (
            <div className="admin-content-list">
              {events.map((event) => {
                const busy = workingId === event.id;
                return (
                  <article key={event.id} className="admin-content-row">
                    <div className="admin-content-thumb">
                      {event.image_url || event.recap_image_url ? (
                        <img src={event.image_url || event.recap_image_url} alt="" />
                      ) : (
                        <span>{event.format?.[0] || 'E'}</span>
                      )}
                    </div>
                    <div className="admin-content-main">
                      <div className="admin-content-flags">
                        <span className="admin-status-badge" data-status={event.status === 'upcoming' ? 'published' : 'draft'}>
                          {event.status}
                        </span>
                        <span className="admin-category-label">{event.format}</span>
                        {!event.published && (
                          <span className="admin-category-label">Hidden</span>
                        )}
                      </div>
                      <h3>
                        <Link href={`/admin/events/${event.id}/edit`}>{event.title}</Link>
                      </h3>
                      <div className="admin-content-meta">
                        <span>{formatEventDate(event.event_date)}</span>
                        <i />
                        <span>{event.location || 'Location not set'}</span>
                      </div>
                    </div>
                    <div className="admin-content-actions">
                      <Link href={`/admin/events/${event.id}/edit`} className="admin-row-edit">Edit</Link>
                      <button type="button" disabled={busy} onClick={() => handleTogglePublished(event.id, event.published)}>
                        {event.published ? 'Hide' : 'Publish'}
                      </button>
                      <button type="button" className="delete" disabled={busy} onClick={() => handleDelete(event.id, event.title)}>
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
