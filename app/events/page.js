"use client";

import Image from 'next/image';
import { useState } from 'react';
import recapImage from '../../images/ysotauthors.jpg';

const events = [
  {
    title: 'Inaugural Webinar: Voices of Change',
    date: 'May 24, 2025',
    description:
      'An evening of policy debate featuring Prof. Francis Egbokhare, Dr. Richard Ikiebe, and the YSoT leadership team.',
    location: 'Online',
    format: 'Webinar',
    status: 'past'
  },
  {
    title: 'Policy Roundtable: Lagos Innovation Corridor',
    date: 'Jun 17, 2025',
    description:
      'A closed-door session exploring governance reforms that can unlock investment across Yaba and the mainland.',
    location: 'Yaba, Lagos',
    format: 'Roundtable',
    status: 'past'
  },
  {
    title: 'Youth Thought Lab',
    date: 'Jul 2, 2025',
    description:
      'Emerging scholars share research briefs on education, security, and social order.',
    location: 'Yaba, Lagos',
    format: 'Workshop',
    status: 'past'
  },
  {
    title: 'Future of Cities Dialogue',
    date: 'Mar 14, 2026',
    description:
      'An interdisciplinary panel on housing, transit, and urban inclusion in fast-growing Nigerian cities.',
    location: 'Civic House, Yaba',
    format: 'Forum',
    status: 'upcoming'
  },
  {
    title: 'Public Finance Reset',
    date: 'Apr 9, 2026',
    description:
      'Policy leaders and researchers map reforms to strengthen public budgeting and fiscal trust.',
    location: 'Online',
    format: 'Webinar',
    status: 'upcoming'
  }
];

export default function EventsPage() {
  const [isRecapOpen, setIsRecapOpen] = useState(false);
  const upcomingEvents = events.filter((e) => e.status === 'upcoming');
  const pastEvents    = events.filter((e) => e.status === 'past');

  return (
    <div className={`page ${isRecapOpen ? 'modal-open' : ''}`}>
      <div className="page-content">

        {/* ── Hero ── */}
        <section className="page-hero">
          <div className="page-hero-text">
            <p className="eyebrow" style={{ color: '#93c5fd', marginBottom: '10px' }}>What's happening</p>
            <h1>Forums, Webinars &amp;<br />Policy Dialogues</h1>
            <p style={{ color: '#c7d2fe', fontSize: '1.05rem', lineHeight: '1.75', marginTop: '12px' }}>
              Live conversations that move ideas from the margins to the mainstream.
            </p>
          </div>
        </section>

        {/* ── Upcoming ── */}
        <section className="section container">
          <div className="events-section-header">
            <div>
              <p className="eyebrow about-eyebrow">On the calendar</p>
              <h2 className="section-heading" style={{ marginBottom: 0 }}>Upcoming Events</h2>
            </div>
            <p className="events-section-sub">Reserve a seat and join the next conversation.</p>
          </div>
          <div className="events-grid" style={{ marginTop: '28px' }}>
            {upcomingEvents.map((event) => (
              <article key={event.title} className="event-card event-card-upcoming">
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
        </section>

        {/* ── Past ── */}
        <section className="section" style={{ background: 'var(--surface)' }}>
          <div className="container">
            <div className="events-section-header">
              <div>
                <p className="eyebrow about-eyebrow">In the archive</p>
                <h2 className="section-heading" style={{ marginBottom: 0 }}>Past Events</h2>
              </div>
              <p className="events-section-sub">Revisit highlights, briefs, and recorded sessions.</p>
            </div>
            <div className="events-grid" style={{ marginTop: '28px' }}>
              {pastEvents.map((event) => (
                <article key={event.title} className="event-card event-card-past">
                  <div className="event-card-top">
                    <span className="event-tag event-tag-past">{event.format}</span>
                    <span className="event-date">{event.date}</span>
                  </div>
                  <h3>{event.title}</h3>
                  <p>{event.description}</p>
                  <div className="event-meta">
                    <span>📍 {event.location}</span>
                    <span className="event-status-past">Recap available</span>
                  </div>
                  <button
                    type="button"
                    className="secondary"
                    style={{ marginTop: '4px', width: 'fit-content' }}
                    onClick={() => setIsRecapOpen(true)}
                  >
                    View recap
                  </button>
                </article>
              ))}
            </div>
          </div>
        </section>

        {/* ── CTA ── */}
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

      {/* ── Recap modal ── */}
      {isRecapOpen && (
        <div className="event-recap-modal" role="dialog" aria-modal="true">
          <button
            type="button"
            className="recap-backdrop"
            aria-label="Close recap"
            onClick={() => setIsRecapOpen(false)}
          />
          <div className="recap-card">
            <button
              type="button"
              className="recap-close"
              onClick={() => setIsRecapOpen(false)}
            >
              ✕ Close
            </button>
            <div className="recap-image">
              <Image
                src={recapImage}
                alt="Inaugural webinar speakers and host"
                fill
                sizes="(max-width: 900px) 100vw, 520px"
              />
            </div>
            <div className="recap-content">
              <p className="eyebrow about-eyebrow">Inaugural Webinar · May 2025</p>
              <h2>Who is Thinking for Nigeria?</h2>
              <p>
                YSoT opened with a candid conversation on Nigeria&apos;s leadership
                gaps, featuring Ogie Eboigbe, Oyinkan Teriba, Prof. Francis
                Egbokhare, and Dr. Richard Ikiebe. The session mapped practical
                reforms, civic responsibility, and the power of ideas in
                rebuilding trust.
              </p>
              <div className="recap-actions">
                <button type="button" className="primary">Watch the recap</button>
                <button type="button" className="secondary" onClick={() => setIsRecapOpen(false)}>
                  Close
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
