'use client';

import Image from 'next/image';
import { useState } from 'react';

export default function EventsView({ events }) {
  const [activeRecap, setActiveRecap] = useState(null);
  const upcomingEvents = events.filter((event) => event.status === 'upcoming');
  const pastEvents = events.filter((event) => event.status === 'past');

  return (
    <div className={`page ${activeRecap ? 'modal-open' : ''}`}>
      <div className="page-content">
        <section className="page-hero">
          <div className="page-hero-text">
            <p className="eyebrow" style={{ color: '#93c5fd', marginBottom: '10px' }}>What&apos;s happening</p>
            <h1>Forums, Webinars &amp;<br />Policy Dialogues</h1>
            <p style={{ color: '#c7d2fe', fontSize: '1.05rem', lineHeight: '1.75', marginTop: '12px' }}>
              Live conversations that move ideas from the margins to the mainstream.
            </p>
          </div>
        </section>

        <section className="section container">
          <div className="events-section-header">
            <div>
              <p className="eyebrow about-eyebrow">On the calendar</p>
              <h2 className="section-heading" style={{ marginBottom: 0 }}>Upcoming Events</h2>
            </div>
            <p className="events-section-sub">Reserve a seat and join the next conversation.</p>
          </div>
          {upcomingEvents.length === 0 ? (
            <p style={{ marginTop: '28px', color: 'var(--muted)' }}>No upcoming events scheduled yet.</p>
          ) : (
            <div className="events-grid" style={{ marginTop: '28px' }}>
              {upcomingEvents.map((event) => (
                <article key={event.id} className="event-card event-card-upcoming">
                  {event.image_url ? (
                    <div className="event-card-image">
                      <Image src={event.image_url} alt="" fill sizes="(max-width: 900px) 100vw, 360px" />
                    </div>
                  ) : null}
                  <div className="event-card-top">
                    <span className="event-tag">{event.format}</span>
                    <span className="event-date">{event.date}</span>
                  </div>
                  <h3>{event.title}</h3>
                  <p>{event.description}</p>
                  <div className="event-meta">
                    <span>📍 {event.location}</span>
                    <span className="event-status-live">Registration open</span>
                  </div>
                  <button type="button" className="primary" style={{ marginTop: '4px', width: 'fit-content' }}>
                    Reserve your seat
                  </button>
                </article>
              ))}
            </div>
          )}
        </section>

        <section className="section" style={{ background: 'var(--surface)' }}>
          <div className="container">
            <div className="events-section-header">
              <div>
                <p className="eyebrow about-eyebrow">In the archive</p>
                <h2 className="section-heading" style={{ marginBottom: 0 }}>Past Events</h2>
              </div>
              <p className="events-section-sub">Revisit highlights, briefs, and recorded sessions.</p>
            </div>
            {pastEvents.length === 0 ? (
              <p style={{ marginTop: '28px', color: 'var(--muted)' }}>Past events will appear here once added.</p>
            ) : (
              <div className="events-grid" style={{ marginTop: '28px' }}>
                {pastEvents.map((event) => (
                  <article key={event.id} className="event-card event-card-past">
                    {event.image_url ? (
                      <div className="event-card-image">
                        <Image src={event.image_url} alt="" fill sizes="(max-width: 900px) 100vw, 360px" />
                      </div>
                    ) : null}
                    <div className="event-card-top">
                      <span className="event-tag event-tag-past">{event.format}</span>
                      <span className="event-date">{event.date}</span>
                    </div>
                    <h3>{event.title}</h3>
                    <p>{event.description}</p>
                    <div className="event-meta">
                      <span>📍 {event.location}</span>
                      <span className="event-status-past">
                        {event.recap_image_url || event.recap_description ? 'Recap available' : 'Completed'}
                      </span>
                    </div>
                    {(event.recap_image_url || event.recap_description || event.recap_title) ? (
                      <button
                        type="button"
                        className="secondary"
                        style={{ marginTop: '4px', width: 'fit-content' }}
                        onClick={() => setActiveRecap(event)}
                      >
                        View recap
                      </button>
                    ) : null}
                  </article>
                ))}
              </div>
            )}
          </div>
        </section>

        <section className="section cta">
          <div className="container cta-card">
            <p className="eyebrow" style={{ color: '#93c5fd', marginBottom: '10px' }}>Get involved</p>
            <h2>Host a dialogue with YSoT</h2>
            <p>
              We partner with institutions to curate policy forums, community
              dialogues, and research briefings tailored to your audience.
            </p>
            <div style={{ display: 'flex', gap: '14px', flexWrap: 'wrap', justifyContent: 'center' }}>
              <button type="button" className="primary">Propose an event</button>
              <button type="button" className="secondary" style={{ borderColor: 'rgba(255,255,255,0.3)', color: '#fff', background: 'transparent' }}>
                Download event deck
              </button>
            </div>
          </div>
        </section>
      </div>

      {activeRecap ? (
        <div className="event-recap-modal" role="dialog" aria-modal="true">
          <button
            type="button"
            className="recap-backdrop"
            aria-label="Close recap"
            onClick={() => setActiveRecap(null)}
          />
          <div className="recap-card">
            <button type="button" className="recap-close" onClick={() => setActiveRecap(null)}>
              ✕ Close
            </button>
            {activeRecap.recap_image_url ? (
              <div className="recap-image">
                <Image
                  src={activeRecap.recap_image_url}
                  alt={activeRecap.recap_title || activeRecap.title}
                  fill
                  sizes="(max-width: 900px) 100vw, 520px"
                />
              </div>
            ) : null}
            <div className="recap-content">
              <p className="eyebrow about-eyebrow">
                {activeRecap.title} · {activeRecap.date}
              </p>
              <h2>{activeRecap.recap_title || activeRecap.title}</h2>
              <p>{activeRecap.recap_description || activeRecap.description}</p>
              <div className="recap-actions">
                <button type="button" className="primary">Watch the recap</button>
                <button type="button" className="secondary" onClick={() => setActiveRecap(null)}>
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      ) : null}
    </div>
  );
}
