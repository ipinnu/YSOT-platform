import Image from 'next/image';
import Link from 'next/link';
import { articles } from '../lib/articles';

const categories = [
  'Governance',
  'Economy',
  'Education',
  'Security',
  'Institutions',
  'Culture'
];

export default function PostsPage() {
  const [featured, ...rest] = articles;
  return (
    <div className="page">

      {/* ── Hero ── */}
      <section className="page-hero">
        <div className="page-hero-text">
          <p className="eyebrow" style={{ color: '#93c5fd', marginBottom: '10px' }}>Ideas in print</p>
          <h1>Articles, Research &amp;<br />Policy Briefings</h1>
          <p style={{ color: '#c7d2fe', fontSize: '1.05rem', lineHeight: '1.75', marginTop: '12px' }}>
            Rigorous thinking on Nigeria's most pressing challenges — written by people who live them.
          </p>
        </div>
      </section>

      {/* ── Featured post ── */}
      <section className="section container">
        <div className="posts-hero-card">
          <div className="image-frame wide posts-featured-image">
            <Image
              src={featured.image}
              alt={`${featured.title} cover`}
              fill
              priority
              sizes="(max-width: 900px) 100vw, 620px"
            />
          </div>
          <div className="posts-hero-content">
            <span className="featured-badge">Featured</span>
            <h2>{featured.title}</h2>
            <p>{featured.excerpt}</p>
            <div className="posts-hero-meta">
              <span className="meta-chip">{featured.category}</span>
              <span>{featured.readTime}</span>
              <span>{featured.date}</span>
            </div>
            <Link className="primary" href={`/posts/${featured.slug}`}>
              Read full article
            </Link>
          </div>
        </div>
      </section>

      {/* ── Filter + grid ── */}
      <section className="section" style={{ background: 'var(--surface)', paddingTop: '48px' }}>
        <div className="container">
          <div className="posts-filter-row">
            <h3 className="posts-grid-label">All posts</h3>
            <div className="post-filters" aria-label="Post categories">
              {categories.map((cat) => (
                <button key={cat} type="button" className="filter-pill">{cat}</button>
              ))}
            </div>
          </div>
          <div className="posts-grid" style={{ marginTop: '28px' }}>
            {rest.map((article) => (
              <article key={article.title} className="post-card">
                <div className="image-frame wide">
                  <Image
                    src={article.image}
                    alt={`${article.title} cover`}
                    fill
                    sizes="(max-width: 900px) 100vw, 360px"
                  />
                </div>
                <div className="post-card-content">
                  <p className="post-date">{article.category} · {article.readTime}</p>
                  <h3>{article.title}</h3>
                  <p>{article.excerpt}</p>
                  <p className="author">{article.author}</p>
                  <Link className="link" href={`/posts/${article.slug}`} style={{ marginTop: '4px' }}>
                    Read article →
                  </Link>
                </div>
              </article>
            ))}
          </div>
        </div>
      </section>

      {/* ── Newsletter CTA ── */}
      <section className="section cta">
        <div className="container cta-card">
          <p className="eyebrow" style={{ color: '#93c5fd', marginBottom: '10px' }}>Stay connected</p>
          <h2>Stay in the loop</h2>
          <p>
            Get a monthly briefing of new articles, event recaps, and policy
            notes — straight from YSoT to your inbox.
          </p>
          <div style={{ display: 'flex', gap: '14px', flexWrap: 'wrap', justifyContent: 'center' }}>
            <button type="button" className="primary">Join the newsletter</button>
            <button type="button" className="secondary" style={{ borderColor: 'rgba(255,255,255,0.3)', color: '#fff', background: 'transparent' }}>
              Submit a piece
            </button>
          </div>
        </div>
      </section>

    </div>
  );
}
