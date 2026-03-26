const recentDrafts = [
  {
    title: 'Reimagining national cohesion through civic trust',
    status: 'Draft',
    updated: 'Aug 2, 2025'
  },
  {
    title: 'Public finance reset: what Nigeria can learn from city budgets',
    status: 'In Review',
    updated: 'Jul 28, 2025'
  }
];

export default function AdminPage() {
  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <h1>Editorial Dashboard</h1>
          <p>
            Manage articles, schedule releases, and coordinate the YSoT content
            pipeline.
          </p>
        </div>
      </section>

      <section className="section container admin-grid">
        <div className="section-card">
          <h2>Create a new article</h2>
          <form className="form">
            <label>
              Title
              <input type="text" placeholder="Article title" />
            </label>
            <label>
              Author
              <input type="text" placeholder="Author name" />
            </label>
            <label>
              Category
              <select>
                <option>Governance</option>
                <option>National Cohesion</option>
                <option>Education</option>
                <option>Economic Policy</option>
                <option>Security</option>
              </select>
            </label>
            <label>
              Summary
              <textarea
                rows="4"
                placeholder="Short excerpt for the homepage"
              />
            </label>
            <label>
              Content
              <textarea rows="8" placeholder="Markdown or rich text body" />
            </label>
            <div className="form-actions">
              <button type="button" className="secondary">
                Save draft
              </button>
              <button type="button" className="primary">
                Publish article
              </button>
            </div>
          </form>
          <p className="hint">
            Connect this form to your backend (REST or Firebase) to persist
            articles and manage publishing workflows.
          </p>
        </div>

        <div className="section-card">
          <h2>Recent drafts</h2>
          <ul className="draft-list">
            {recentDrafts.map((draft) => (
              <li key={draft.title}>
                <div>
                  <h4>{draft.title}</h4>
                  <p>{draft.status}</p>
                </div>
                <span>{draft.updated}</span>
              </li>
            ))}
          </ul>
          <button type="button" className="secondary">
            Manage all drafts
          </button>
        </div>
      </section>
    </div>
  );
}
