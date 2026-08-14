'use client';

import Image from 'next/image';
import { useState } from 'react';

export default function GalleryGrid({ items }) {
  const [activeImage, setActiveImage] = useState(null);

  if (items.length === 0) {
    return (
      <div className="admin-library-empty" style={{ margin: '0 auto', maxWidth: '520px' }}>
        <div aria-hidden="true">G</div>
        <h3>Gallery coming soon</h3>
        <p>Photos from our conversations and forums will appear here.</p>
      </div>
    );
  }

  return (
    <>
      <div className="gallery-grid">
        {items.map((item) => (
          <button
            key={item.id}
            className="image-frame gallery-item"
            type="button"
            onClick={() => setActiveImage(item)}
          >
            <Image
              src={item.image_url}
              alt={item.alt}
              fill
              sizes="(max-width: 900px) 100vw, 280px"
            />
          </button>
        ))}
      </div>

      {activeImage ? (
        <div className="lightbox" role="dialog" aria-modal="true">
          <button
            className="lightbox-backdrop"
            type="button"
            aria-label="Close image preview"
            onClick={() => setActiveImage(null)}
          />
          <div className="lightbox-content">
            <button
              className="lightbox-close"
              type="button"
              aria-label="Close image preview"
              onClick={() => setActiveImage(null)}
            >
              Close
            </button>
            <div className="lightbox-image">
              <Image
                src={activeImage.image_url}
                alt={activeImage.alt}
                fill
                sizes="100vw"
              />
            </div>
          </div>
        </div>
      ) : null}
    </>
  );
}
