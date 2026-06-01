import Image from 'next/image';
import Link from 'next/link';
import { getArticles } from './lib/articles';
import aboutImage from '../images/cat.jpg';
import heroImage from '../images/hero.jpg';
import eventPoster from '../images/ysotposter.jpg';
import videoPreview from '../images/yt_preview.png';

export const dynamic = 'force-dynamic';

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

export default async function HomePage() {
  const articles = await getArticles();
  const featuredArticle = articles[0] || null;
  return (
    <>
      <section className="hero">
        <div className="container hero-inner">
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
          <div className="hero-media">
            <div className="image-frame hero-image">
              <Image
                src={heroImage}
                alt="Yaba School of Thought highlight"
                fill
                priority
                sizes="(max-width: 900px) 100vw, 560px"
              />
            </div>
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
              Founded in 2025 and based in Yaba, Lagos -- a historic hub of
              education and innovation -- YSoT brings together leading voices
              across diverse fields to tackle Nigeria's most pressing governance,
              cohesion, and development challenges.
            </p>
          </div>
          <div className="image-frame">
            <Image
              src={aboutImage}
              alt="Yaba School of Thought in action"
              fill
              sizes="(max-width: 900px) 100vw, 460px"
            />
          </div>
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
        </div>
        <div className="topics-carousel" aria-label="Core topics carousel">
          <div className="topic-track">
            {[...topics, ...topics].map((topic, i) => (
              <span key={`${topic}-${i}`}>{topic}</span>
            ))}
          </div>
        </div>
      </section>

      <section className="section talk">
        <div className="container talk-grid">
          <div className="talk-content">
            <p className="eyebrow">Talk of the Town</p>
            <h2>Yaba School of Thought Inaugural Webinar</h2>
            <p>
              In a moment that called for more than commentary, the voices that
              matter showed up. Led by Ogie Eboigbe, with moderation by Oyinkan
              Teriba, the session featured deeply rooted insights from Prof.
              Francis Egbokhare and Dr. Richard Ikiebe -- each tackling Nigeria's
              systemic gaps not with slogans, but with thought.
            </p>
            <Link className="link" href="/events">
              See what happened &gt;
            </Link>
          </div>
          <div className="talk-media">
            <div className="image-frame wide contain poster-frame">
              <Image
                src={eventPoster}
                alt="YSoT event poster"
                fill
                sizes="(max-width: 900px) 100vw, 320px"
              />
            </div>
            <a
              className="video-card compact"
              href="https://www.youtube.com/watch?v=9wQiFJHTGbY&pp=ygUWeWFiYSBzY2hvb2wgb2YgdGhvdWdodNgGAw%3D%3D"
              target="_blank"
              rel="noreferrer"
            >
              <div className="image-frame wide">
                <Image
                  src={videoPreview}
                  alt="Webinar highlight preview"
                  fill
                  sizes="(max-width: 900px) 100vw, 360px"
                />
              </div>
              <span className="play-badge" aria-hidden="true">Play</span>
              <span>Watch highlights</span>
            </a>
          </div>
        </div>
      </section>

      {featuredArticle && (
        <section className="section blog">
          <div className="container blog-card">
            <div className="blog-image">
              <div className="image-frame wide">
                {featuredArticle.image_url ? (
                  <Image
                    src={featuredArticle.image_url}
                    alt="Featured article cover"
                    fill
                    sizes="(max-width: 900px) 100vw, 520px"
                  />
                ) : (
                  <div className="image-placeholder" />
                )}
              </div>
              {featuredArticle.published_at && (
                <span>
                  {new Date(featuredArticle.published_at).toLocaleDateString('en-GB', {
                    day: 'numeric', month: 'short', year: 'numeric',
                  })}
                </span>
              )}
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
      )}

      <section className="section cta">
        <div className="container cta-card">
          <h2>Join the Movement</h2>
          <p>
            Be a part of the voices shaping our generation's future. Share your
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
