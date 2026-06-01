import Image from 'next/image';
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { getArticleBySlug, getArticles } from '../../lib/articles';

export const dynamic = 'force-dynamic';

export async function generateMetadata({ params }) {
  const { slug } = await params;
  const article = await getArticleBySlug(slug);
  if (!article) return {};
  return { title: article.title, description: article.excerpt };
}

function renderBlocks(content) {
  if (!content || !Array.isArray(content)) return null;
  return content.map((block, i) => {
    if (!block) return null;
    switch (block.type) {
      case 'heading': {
        const Tag = block.level === 3 ? 'h3' : 'h2';
        return <Tag key={i}>{block.text}</Tag>;
      }
      case 'quote':
        return (
          <blockquote key={i} className="post-blockquote">
            <p>{block.text}</p>
          </blockquote>
        );
      case 'image':
        return (
          <figure key={i} className="post-figure">
            <img src={block.url} alt={block.caption || ''} className="post-figure-img" />
            {block.caption && <figcaption className="post-figure-caption">{block.caption}</figcaption>}
          </figure>
        );
      default:
        return (
          <p key={i} className={i === 0 ? 'post-lead' : ''}>
            {block.text}
          </p>
        );
    }
  });
}

export default async function PostDetailPage({ params }) {
  const { slug } = await params;
  const [article, allArticles] = await Promise.all([
    getArticleBySlug(slug),
    getArticles(),
  ]);

  if (!article) notFound();

  const related = allArticles.filter((a) => a.slug !== slug).slice(0, 3);
  const publishedDate = article.published_at
    ? new Date(article.published_at).toLocaleDateString('en-GB', {
        day: 'numeric', month: 'long', year: 'numeric',
      })
    : '';

  return (
    <div className="page post-detail">

      <header className="post-header">
        <div className="container post-header-nav">
          <Link className="post-back" href="/posts">← All articles</Link>
          <span className="meta-chip">{article.category}</span>
        </div>
        <div className="container post-header-title">
          <h1>{article.title}</h1>
          <p className="post-excerpt">{article.excerpt}</p>
          <div className="post-header-meta">
            <span className="post-author-chip">{article.author}</span>
            <span className="post-meta-sep" />
            <span>{publishedDate}</span>
            <span className="post-meta-sep" />
            <span>{article.read_time}</span>
          </div>
        </div>
      </header>

      {article.image_url && (
        <div className="post-banner-wrap">
          <div className="post-banner">
            <Image
              src={article.image_url}
              alt={`${article.title} cover`}
              fill
              priority
              sizes="(max-width: 900px) 100vw, 1200px"
              style={{ objectFit: 'cover' }}
            />
          </div>
        </div>
      )}

      <section className="section container post-body">
        <article className="post-article">
          {renderBlocks(article.content)}
          {article.author_bio && (
            <div className="author-bio-box">
              <strong>{article.author}</strong>
              <p>{article.author_bio}</p>
            </div>
          )}
        </article>

        <aside className="post-aside">
          {related.length > 0 && (
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
          )}
          <Link className="aside-back secondary" href="/posts">← Back to all articles</Link>
        </aside>
      </section>

      {related.length > 0 && (
        <section className="section" style={{ background: 'var(--surface)', paddingTop: '56px' }}>
          <div className="container">
            <p className="eyebrow about-eyebrow">Keep reading</p>
            <h2 className="section-heading">More from YSoT</h2>
            <div className="posts-grid">
              {related.map((item) => (
                <article key={item.slug} className="post-card">
                  <div className="image-frame wide">
                    {item.image_url ? (
                      <Image src={item.image_url} alt={`${item.title} cover`} fill sizes="(max-width: 900px) 100vw, 360px" />
                    ) : (
                      <div className="image-placeholder" />
                    )}
                  </div>
                  <div className="post-card-content">
                    <p className="post-date">{item.category} · {item.read_time}</p>
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
