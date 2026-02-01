const galleryImages = ['1', '2', '3', '4', '5', '6'];

export default function GalleryPage() {
  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <h1>Gallery</h1>
          <p>Moments from our conversations, workshops, and public forums.</p>
        </div>
      </section>

      <section className="section container">
        <div className="gallery-grid">
          {galleryImages.map((label) => (
            <div key={label} className="image-placeholder">
              Gallery image {label}
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
