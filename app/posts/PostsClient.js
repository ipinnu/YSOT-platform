'use client';

import { useState, useMemo } from 'react';
import Image from 'next/image';
import Link from 'next/link';

export default function PostsClient({ featured, rest }) {
  const [active, setActive] = useState('All');

  const categories = useMemo(() => {
    const seen = new Set();
    [...(featured ? [featured] : []), ...rest].forEach((a) => {
      if (a.category) seen.add(a.category);
    });
    return Array.from(seen);
  }, [featured, rest]);

  const filtered = useMemo(
    () => (active === 'All' ? rest : rest.filter((a) => a.category === active)),
    [active, rest]
  );

  return (
    <>
      {featured && (
        <section className="section container" style={{ paddingBottom: 0 }}>
          <Link href={`/posts/${featured.slug}`} className="posts-hero-card">
            <div className="posts-hero-image-wrap">
              {featured.image_url ? (
                <Image
                  src={featured.image_url}
                  alt={`${featured.title} cover`}
                  fill
                  priority
                  sizes="(max-width: 900px) 100vw, 660px"
                  style={{ objectFit: 'cover' }}
                />
              ) : (
                <div className="image-placeholder" />
              )}
              <div className="posts-hero-image-overlay" />
            </div>
            <div className="posts-hero-content">
              <span className="featured-badge">Featured</span>
              <h2>{featured.title}</h2>
              <p>{featured.excerpt}</p>
              <div className="posts-hero-meta">
                <span className="meta-chip-dark">{featured.category}</span>
                <span>{featured.read_time}</span>
                {featured.published_at && (
                  <span>
                    {new Date(featured.published_at).toLocaleDateString('en-GB', {
                      day: 'numeric', month: 'short', year: 'numeric',
                    })}
                  </span>
                )}
              </div>
              <span className="posts-hero-cta">Read full article →</span>
            </div>
          </Link>
        </section>
      )}

      <section className="section posts-grid-section">
        <div className="container">
          <div className="posts-filter-row">
            <h3 className="posts-grid-label">All posts</h3>
            <div className="post-filters" aria-label="Filter by category">
              {['All', ...categories].map((cat) => (
                <button
                  key={cat}
                  type="button"
                  className={`filter-pill${active === cat ? ' active' : ''}`}
                  onClick={() => setActive(cat)}
                >
                  {cat}
                </button>
              ))}
            </div>
          </div>

          {filtered.length === 0 && (
            <p className="posts-empty">No articles in this category yet.</p>
          )}

          <div className="posts-grid" style={{ marginTop: '28px' }}>
            {filtered.map((article) => (
              <article key={article.id} className="post-card">
                <div className="image-frame wide post-card-image">
                  {article.image_url ? (
                    <Image
                      src={article.image_url}
                      alt={`${article.title} cover`}
                      fill
                      sizes="(max-width: 900px) 100vw, 360px"
                    />
                  ) : (
                    <div className="image-placeholder" />
                  )}
                  <div className="post-card-image-overlay" />
                  <span className="post-card-cat-badge">{article.category}</span>
                </div>
                <div className="post-card-content">
                  <p className="post-date">{article.read_time}</p>
                  <h3>
                    <Link href={`/posts/${article.slug}`}>{article.title}</Link>
                  </h3>
                  <p className="post-card-excerpt">{article.excerpt}</p>
                  <div className="post-card-footer">
                    <span className="author">{article.author}</span>
                    <Link className="post-card-read" href={`/posts/${article.slug}`}>
                      Read →
                    </Link>
                  </div>
                </div>
              </article>
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
