import { getEvents } from '../lib/events';
import EventsView from './EventsView';

const FALLBACK_EVENTS = [
  {
    id: 'fallback-1',
    title: 'Inaugural Webinar: Voices of Change',
    date: 'May 24, 2025',
    description:
      'An evening of policy debate featuring Prof. Francis Egbokhare, Dr. Richard Ikiebe, and the YSoT leadership team.',
    location: 'Online',
    format: 'Webinar',
    status: 'past',
    recap_title: 'Who is Thinking for Nigeria?',
    recap_description:
      "YSoT opened with a candid conversation on Nigeria's leadership gaps, featuring Ogie Eboigbe, Oyinkan Teriba, Prof. Francis Egbokhare, and Dr. Richard Ikiebe.",
    recap_image_url: '',
    image_url: '',
  },
  {
    id: 'fallback-2',
    title: 'Future of Cities Dialogue',
    date: 'Mar 14, 2026',
    description:
      'An interdisciplinary panel on housing, transit, and urban inclusion in fast-growing Nigerian cities.',
    location: 'Civic House, Yaba',
    format: 'Forum',
    status: 'upcoming',
    recap_title: '',
    recap_description: '',
    recap_image_url: '',
    image_url: '',
  },
];

export default async function EventsPage() {
  const events = await getEvents();
  const displayEvents = events.length > 0 ? events : FALLBACK_EVENTS;

  return <EventsView events={displayEvents} />;
}
