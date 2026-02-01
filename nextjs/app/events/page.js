const events = [
  {
    title: 'Inaugural Webinar: Voices of Change',
    date: 'May 24, 2025',
    description:
      'An evening of policy debate featuring Prof. Francis Egbokhare, Dr. Richard Ikiebe, and the YSoT leadership team.'
  },
  {
    title: 'Policy Roundtable: Lagos Innovation Corridor',
    date: 'Jun 17, 2025',
    description:
      'A closed-door session exploring governance reforms that can unlock investment across Yaba and the mainland.'
  },
  {
    title: 'Youth Thought Lab',
    date: 'Jul 2, 2025',
    description:
      'Emerging scholars share research briefs on education, security, and social order.'
  }
];

export default function EventsPage() {
  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <h1>Events</h1>
          <p>Highlights from our forums, webinars, and strategic dialogues.</p>
        </div>
      </section>

      <section className="section container">
        <div className="events-list">
          {events.map((event) => (
            <div key={event.title} className="event-card">
              <div>
                <h3>{event.title}</h3>
                <p>{event.description}</p>
              </div>
              <span>{event.date}</span>
            </div>
          ))}
        </div>
        <div className="event-actions">
          <button type="button" className="primary">
            View event recap
          </button>
          <button type="button" className="secondary">
            Download report
          </button>
        </div>
      </section>
    </div>
  );
}
