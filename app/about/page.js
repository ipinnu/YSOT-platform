import Image from 'next/image';
import thinkerTeam from '../../images/Author.png';

const focusAreas = [
  'Governance Reform',
  'National Cohesion',
  'Education Innovation',
  'Economic Development',
  'Security & Social Order',
  'Institutional Renewal',
];

const facts = [
  { label: 'Founded',     value: '2025' },
  { label: 'Location',    value: 'Yaba, Lagos' },
  { label: 'Team Size',   value: '12 thinkers' },
  { label: 'Nature',      value: 'Non-partisan, independent' },
  { label: 'Focus Areas', value: '6 core policy domains' },
  { label: 'First Event', value: 'Inaugural Webinar, 2025' },
];

export default function AboutPage() {
  return (
    <div className="page">

      {/* ── Hero ── */}
      <section className="page-hero">
        <div className="container about-hero-inner">
          <div>
            <p className="eyebrow">About us</p>
            <h1>Where ideas meet<br />Nigeria's future</h1>
            <p className="about-hero-sub">
              An independent, non-partisan collective of Nigerian scholars
              and public intellectuals — building the intellectual
              infrastructure the nation deserves.
            </p>
          </div>
          <div className="about-hero-card">
            <div className="about-hero-meta">
              <div><strong>2025</strong>Founded</div>
              <div><strong>Yaba, Lagos</strong>Based in</div>
              <div><strong>12+</strong>Thinkers</div>
            </div>
            <div className="focus-chips">
              {focusAreas.map((area) => (
                <span key={area}>{area}</span>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ── Mission ── */}
      <section className="section">
        <div className="container">
          <p className="eyebrow about-eyebrow">What drives us</p>
          <h2 className="section-heading">Our Mission</h2>
          <div className="mission-grid">
            <div className="mission-card">
              <span className="mission-number">01</span>
              <h2>Bridge the gap</h2>
              <p>Close Nigeria's intellectual leadership gap by elevating homegrown scholarship to where policy is shaped.</p>
            </div>
            <div className="mission-card">
              <span className="mission-number">02</span>
              <h2>Root ideas locally</h2>
              <p>Deliver domestically rooted, actionable policy ideas — not borrowed frameworks, but solutions built from Nigeria's realities.</p>
            </div>
            <div className="mission-card">
              <span className="mission-number">03</span>
              <h2>Foster collaboration</h2>
              <p>Cultivate collaborative leadership among the country's top thinkers, scholars, and innovators.</p>
            </div>
          </div>
        </div>
      </section>

      {/* ── Who we are ── */}
      <section className="section" style={{ background: 'var(--surface)' }}>
        <div className="container about-story">
          <div className="story-panel">
            <p className="eyebrow about-eyebrow">Our story</p>
            <h2 className="section-heading">Who We Are</h2>
            <p>
              The Yaba School of Thought (YSoT) is a non-partisan collective of
              Nigerian scholars, public intellectuals, and policy thinkers committed
              to addressing the country's deep-rooted governance and development
              challenges through rigorous, context-specific research.
            </p>
            <p>
              Founded in 2025 and based in Yaba, Lagos — a historic hub of education
              and innovation — YSoT brings together 12–15 leading voices from diverse
              fields to generate high-impact, locally grounded ideas.
            </p>
            <p>
              Our work influences public discourse, supports evidence-based
              policymaking, and rebuilds the intellectual infrastructure needed for
              long-term national development.
            </p>
          </div>
          <div className="story-panel about-quote">
            <p className="about-quote-mark">&ldquo;</p>
            <h3>
              Meaningful national transformation demands a renewal of intellectual
              leadership rooted in Nigeria&apos;s unique realities.
            </h3>
            <p>
              We believe borrowed models cannot solve locally grown problems. Every
              idea we surface is tested against Nigeria&apos;s context — its history,
              its institutions, its people.
            </p>
            <div className="focus-chips">
              {focusAreas.map((area) => (
                <span key={area}>{area}</span>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ── At a glance ── */}
      <section className="section">
        <div className="container">
          <p className="eyebrow about-eyebrow">Quick facts</p>
          <h2 className="section-heading">At a Glance</h2>
          <div className="facts-grid refined">
            {facts.map((f) => (
              <div key={f.label} className="fact-card">
                <h4>{f.label}</h4>
                <p>{f.value}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── Thinkers ── */}
      <section className="section thinkers-section">
        <div className="container">
          <p className="eyebrow about-eyebrow">The people</p>
          <h2 className="section-heading">Meet our Thinkers</h2>
          <p className="thinkers-intro">
            A carefully assembled collective of scholars, policy experts, and
            public intellectuals from across Nigeria&apos;s most critical disciplines.
          </p>
        </div>
        <div className="thinkers-image-wrap">
          <div className="image-frame contain thinkers-frame">
            <Image
              src={thinkerTeam}
              alt="YSoT thinkers team"
              fill
              priority
              sizes="100vw"
            />
          </div>
        </div>
      </section>

    </div>
  );
}
