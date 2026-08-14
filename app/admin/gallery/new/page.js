import Link from 'next/link';
import GalleryForm from '../GalleryForm';

export default function NewGalleryItemPage() {
  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <div className="admin-header-row">
            <div>
              <h1>Add Gallery Photo</h1>
              <p>Upload a photo for the public gallery page.</p>
            </div>
            <Link href="/admin/gallery" className="secondary">← Gallery</Link>
          </div>
        </div>
      </section>

      <section className="section container">
        <div className="section-card">
          <GalleryForm />
        </div>
      </section>
    </div>
  );
}
