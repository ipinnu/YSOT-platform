import Link from 'next/link';
import { featuredArticle } from './lib/articles';

const stats = [
  { value: '20+', label: 'Years of Experience' },
  { value: '20+', label: 'Industry Awards' },
  { value: '10+', label: 'Projects Delivered' },
  { value: '50+', label: 'Happy Partners' }
];

const topics = [
  'Governance Reform',
  'National Cohesion',
  'Education Innovation',
  'Economic Development',
  'Security & Social Order',
  'Institutional Renewal'
];

export default function HomePage() {
  return (
    <>
      <section className="hero">
        <div className="hero-content">
          <p className="eyebrow">Voices of Change</p>
          <h1>Stories that matter</h1>
          <p>
            The Yaba School of Thought amplifies Nigeria&apos;s brightest policy
            thinkers, highlighting bold ideas that shape the future.
          </p>
          <div className="hero-actions">
            <Link className="primary" href="/posts">
              Read the latest
            </Link>
            <Link className="secondary" href="/about">
              About YSoT
            </Link>
          </div>
        </div>
      </section>

      <section className="section">
        <div className="container about-card">
          <div>
            <h2>About Us</h2>
            <p>
              The Yaba School of Thought (YSoT) is an independent, non-partisan
              community of Nigerian thinkers, scholars, and innovators dedicated
              to building a stronger intellectual foundation for the nation.
              Founded in 2025 and based in Yaba, Lagos — a historic hub of
              education and innovation — YSoT brings together leading voices
              across diverse fields to tackle Nigeria’s most pressing governance,
              cohesion, and development challenges.
            </p>
          </div>
          <div className="image-placeholder">Thinkers group photo</div>
        </div>
      </section>

      <section className="section stats">
        <div className="container stats-grid">
          {stats.map((stat) => (
            <div key={stat.label} className="stat-card">
              <span>{stat.value}</span>
              <p>{stat.label}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="section topics">
        <div className="container">
          <h3>Core Topics</h3>
          <div className="topic-pillars">
            {topics.map((topic) => (
              <span key={topic}>{topic}</span>
            ))}
          </div>
        </div>
      </section>

      <section className="section talk">
        <div className="container talk-grid">
          <div className="talk-media">
            <div className="image-placeholder">Event poster</div>
            <div className="video-card">
              <div className="image-placeholder">Video preview</div>
              <span>Watch highlights</span>
            </div>
          </div>
          <div className="talk-content">
            <p className="eyebrow">Talk of the Town</p>
            <h2>Yaba School of Thought Inaugural Webinar</h2>
            <p>
              In a moment that called for more than commentary, the voices that
              matter showed up. Led by Ogie Eboigbe, with moderation by Oyinkan
              Teriba, the session featured deeply rooted insights from Prof.
              Francis Egbokhare and Dr. Richard Ikiebe — each tackling Nigeria’s
              systemic gaps not with slogans, but with thought.
            </p>
            <Link className="link" href="/events">
              See what happened →
            </Link>
          </div>
        </div>
      </section>

      <section className="section blog">
        <div className="container blog-card">
          <div className="blog-image">
            <div className="image-placeholder">Featured article image</div>
            <span>{featuredArticle.date}</span>
          </div>
          <div className="blog-content">
            <h3>Recent Blog Post</h3>
            <h2>{featuredArticle.title}</h2>
            <p>{featuredArticle.excerpt}</p>
            <p className="author">{featuredArticle.author}</p>
            <Link className="secondary" href="/posts">
              Show more
            </Link>
          </div>
        </div>
      </section>

      <section className="section cta">
        <div className="container cta-card">
          <h2>Join the Movement</h2>
          <p>
            Be a part of the voices shaping our generation’s future. Share your
            story, join our community, and build the intellectual infrastructure
            Nigeria deserves.
          </p>
          <Link className="primary" href="/about">
            Get Involved
          </Link>
        </div>
      </section>
    </>
  );
}
