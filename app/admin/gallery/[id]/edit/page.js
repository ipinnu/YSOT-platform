import Link from 'next/link';
import { notFound } from 'next/navigation';
import { getGalleryItemById } from '../../../../lib/gallery';
import GalleryForm from '../../GalleryForm';

export default async function EditGalleryItemPage({ params }) {
  const { id } = await params;
  const item = await getGalleryItemById(id);
  if (!item) notFound();

  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <div className="admin-header-row">
            <div>
              <h1>Edit Gallery Photo</h1>
              <p>Update the caption, order, or image.</p>
            </div>
            <Link href="/admin/gallery" className="secondary">← Gallery</Link>
          </div>
        </div>
      </section>

      <section className="section container">
        <div className="section-card">
          <GalleryForm item={item} />
        </div>
      </section>
    </div>
  );
}
