import { getGalleryItems } from '../lib/gallery';
import GalleryGrid from './GalleryGrid';

export default async function GalleryPage() {
  const items = await getGalleryItems();

  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <h1>Gallery</h1>
          <p>Moments from our conversations, workshops, and public forums.</p>
        </div>
      </section>

      <section className="section container">
        <GalleryGrid items={items} />
      </section>
    </div>
  );
}
