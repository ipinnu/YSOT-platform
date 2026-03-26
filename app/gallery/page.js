"use client";

import Image from 'next/image';
import { useState } from 'react';
import gallery1 from '../../images/1.jpg';
import gallery2 from '../../images/2.jpg';
import gallery3 from '../../images/3.jpg';
import gallery4 from '../../images/4.jpg';
import gallery5 from '../../images/5.jpg';
import gallery6 from '../../images/6.jpg';

const galleryImages = [
  { src: gallery1, alt: 'Gallery moment 1' },
  { src: gallery2, alt: 'Gallery moment 2' },
  { src: gallery3, alt: 'Gallery moment 3' },
  { src: gallery4, alt: 'Gallery moment 4' },
  { src: gallery5, alt: 'Gallery moment 5' },
  { src: gallery6, alt: 'Gallery moment 6' }
];

export default function GalleryPage() {
  const [activeImage, setActiveImage] = useState(null);
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
            <button
              key={label.alt}
              className="image-frame gallery-item"
              type="button"
              onClick={() => setActiveImage(label)}
            >
              <Image
                src={label.src}
                alt={label.alt}
                fill
                sizes="(max-width: 900px) 100vw, 280px"
              />
            </button>
          ))}
        </div>
      </section>

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
                src={activeImage.src}
                alt={activeImage.alt}
                fill
                sizes="100vw"
              />
            </div>
          </div>
        </div>
      ) : null}
    </div>
  );
}
