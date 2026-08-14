import Link from 'next/link';
import EventForm from '../EventForm';

export default function NewEventPage() {
  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <div className="admin-header-row">
            <div>
              <h1>New Event</h1>
              <p>Create an upcoming event or add a past session with recap photos.</p>
            </div>
            <Link href="/admin/events" className="secondary">← Events</Link>
          </div>
        </div>
      </section>

      <section className="section container">
        <div className="section-card">
          <EventForm />
        </div>
      </section>
    </div>
  );
}
