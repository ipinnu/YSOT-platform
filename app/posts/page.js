import { getArticles } from '../lib/articles';
import PostsClient from './PostsClient';

export const dynamic = 'force-dynamic';

export default async function PostsPage() {
  const articles = await getArticles();
  const featured = articles.find((a) => a.featured) || articles[0] || null;
  const rest = articles.filter((a) => a !== featured);

  return (
    <div className="page">
      <section className="page-hero">
        <div className="page-hero-text">
          <p className="eyebrow" style={{ color: '#93c5fd', marginBottom: '10px' }}>Ideas in print</p>
          <h1>Articles, Research &amp;<br />Policy Briefings</h1>
          <p style={{ color: '#c7d2fe', fontSize: '1.05rem', lineHeight: '1.75', marginTop: '12px' }}>
            Rigorous thinking on Nigeria&apos;s most pressing challenges — written by people who live them.
          </p>
        </div>
      </section>

      <PostsClient featured={featured} rest={rest} />

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
