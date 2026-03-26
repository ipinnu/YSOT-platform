import Image from 'next/image';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { articles } from '../../lib/articles';

export const dynamic = 'force-static';
export const dynamicParams = false;

export function generateStaticParams() {
  return articles.map((article) => ({ slug: article.slug }));
}

export async function generateMetadata({ params }) {
  const { slug } = await params;
  const article = articles.find((item) => item.slug === slug);
  if (!article) return {};
  return { title: article.title, description: article.excerpt };
}

export default async function PostDetailPage({ params }) {
  const { slug } = await params;
  const article = articles.find((item) => item.slug === slug);
  if (!article) notFound();

  const related = articles.filter((item) => item.slug !== article.slug);

  return (
    <div className="page post-detail">

      {/* ── Article header ── */}
      <header className="post-header">
        <div className="container post-header-nav">
          <Link className="post-back" href="/posts">
            ← All articles
          </Link>
          <span className="meta-chip">{article.category}</span>
        </div>
        <div className="container post-header-title">
          <h1>{article.title}</h1>
          <p className="post-excerpt">{article.excerpt}</p>
          <div className="post-header-meta">
            <span className="post-author-chip">{article.author}</span>
            <span className="post-meta-sep" />
            <span>{article.date}</span>
            <span className="post-meta-sep" />
            <span>{article.readTime}</span>
          </div>
        </div>
      </header>

      {/* ── Hero image ── */}
      <div className="post-banner-wrap">
        <div className="post-banner">
          <Image
            src={article.image}
            alt={`${article.title} cover`}
            fill
            priority
            sizes="(max-width: 900px) 100vw, 1200px"
            style={{ objectFit: 'cover' }}
          />
        </div>
      </div>

      {/* ── Body + sidebar ── */}
      <section className="section container post-body">
        <article className="post-article">
          {article.sections.map((section, i) => (
            <div key={section.heading} className="post-section">
              <h2>{section.heading}</h2>
              {section.paragraphs.map((para, j) => (
                <p key={j} className={i === 0 && j === 0 ? 'post-lead' : ''}>
                  {para}
                </p>
              ))}
            </div>
          ))}
        </article>

        <aside className="post-aside">
          <div className="aside-card">
            <h4 className="aside-heading">Key takeaways</h4>
            <ul className="takeaways">
              <li>Execution matters as much as policy design.</li>
              <li>Transparency rebuilds public trust faster.</li>
              <li>Visible wins create momentum for larger reforms.</li>
            </ul>
          </div>

          <div className="aside-card">
            <h4 className="aside-heading">More from YSoT</h4>
            <div className="related-links">
              {related.map((item) => (
                <Link key={item.slug} className="related-link" href={`/posts/${item.slug}`}>
                  <span className="related-link-cat">{item.category}</span>
                  <span className="related-link-title">{item.title}</span>
                </Link>
              ))}
            </div>
          </div>

          <Link className="aside-back secondary" href="/posts">
            ← Back to all articles
          </Link>
        </aside>
      </section>

      {/* ── More articles ── */}
      {related.length > 0 && (
        <section className="section" style={{ background: 'var(--surface)', paddingTop: '56px' }}>
          <div className="container">
            <p className="eyebrow about-eyebrow">Keep reading</p>
            <h2 className="section-heading">More from YSoT</h2>
            <div className="posts-grid">
              {related.map((item) => (
                <article key={item.slug} className="post-card">
                  <div className="image-frame wide">
                    <Image
                      src={item.image}
                      alt={`${item.title} cover`}
                      fill
                      sizes="(max-width: 900px) 100vw, 360px"
                    />
                  </div>
                  <div className="post-card-content">
                    <p className="post-date">{item.category} · {item.readTime}</p>
                    <h3>{item.title}</h3>
                    <p>{item.excerpt}</p>
                    <p className="author">{item.author}</p>
                    <Link className="link" href={`/posts/${item.slug}`} style={{ marginTop: '4px' }}>
                      Read article →
                    </Link>
                  </div>
                </article>
              ))}
            </div>
          </div>
        </section>
      )}

    </div>
  );
}
