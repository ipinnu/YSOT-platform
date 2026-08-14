import Link from 'next/link';
import { notFound } from 'next/navigation';
import { getEventById } from '../../../../lib/events';
import EventForm from '../../EventForm';

export default async function EditEventPage({ params }) {
  const { id } = await params;
  const event = await getEventById(id);
  if (!event) notFound();

  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <div className="admin-header-row">
            <div>
              <h1>Edit Event</h1>
              <p>Update event details, images, and recap content.</p>
            </div>
            <Link href="/admin/events" className="secondary">← Events</Link>
          </div>
        </div>
      </section>

      <section className="section container">
        <div className="section-card">
          <EventForm event={event} />
        </div>
      </section>
    </div>
  );
}
