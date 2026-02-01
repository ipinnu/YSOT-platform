export default function AboutPage() {
  return (
    <div className="page">
      <section className="page-hero">
        <div className="page-hero-text">
          <h1>About Yaba School of Thought</h1>
          <p>
            An independent think-tank promoting evidence-based discourse and
            homegrown solutions for Nigeria.
          </p>
        </div>
      </section>

      <section className="section container">
        <div className="section-card">
          <h2>Our Mission</h2>
          <ul>
            <li>Bridge Nigeria’s intellectual leadership gap.</li>
            <li>Deliver domestically rooted, actionable policy ideas.</li>
            <li>Foster collaborative leadership among top thinkers.</li>
          </ul>
        </div>
      </section>

      <section className="section container">
        <h2>Who We Are</h2>
        <p>
          The Yaba School of Thought (YSoT) is a non-partisan collective of
          Nigerian scholars, public intellectuals, and policy thinkers committed
          to addressing the country’s deep-rooted governance and development
          challenges through rigorous, context-specific research.
        </p>
        <p>
          Founded in 2025 and based in Yaba, Lagos — a historic hub of education
          and innovation — YSoT brings together 12–15 leading voices from diverse
          fields to generate high-impact, locally grounded ideas. We believe that
          meaningful national transformation requires more than borrowed models;
          it demands a renewal of intellectual leadership rooted in Nigeria’s
          unique realities.
        </p>
        <p>
          Our work focuses on critical areas including governance, national
          cohesion, education, and institutional reform. We aim to influence
          public discourse, support evidence-based policymaking, and rebuild the
          intellectual infrastructure needed for long-term national development.
        </p>
      </section>

      <section className="section container">
        <div className="facts-grid">
          <div>
            <h4>Founded</h4>
            <p>2025</p>
          </div>
          <div>
            <h4>Location</h4>
            <p>Yaba, Lagos</p>
          </div>
          <div>
            <h4>Team Size</h4>
            <p>12 thinkers</p>
          </div>
          <div>
            <h4>Focus Areas</h4>
            <p>
              Nationality, social order, security, intellectual crises, economic
              solutions, policies & more
            </p>
          </div>
        </div>
      </section>

      <section className="section container thinkers">
        <h2>Meet our Thinkers</h2>
        <div className="thinker-grid">
          <div className="image-placeholder">Thinker profile 1</div>
          <div className="image-placeholder">Thinker profile 2</div>
          <div className="image-placeholder">Thinker team</div>
        </div>
      </section>
    </div>
  );
}
