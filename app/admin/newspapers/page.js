import Link from 'next/link';

export const metadata = {
  title: 'Newspaper importer coming soon | YSoT Admin',
};

export default function NewspaperImportPage() {
  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <div className="admin-header-row">
            <div>
              <span className="newspaper-kicker">Editorial automation</span>
              <h1>Newspaper Importer</h1>
              <p>This feature is coming soon.</p>
            </div>
            <Link href="/admin" className="secondary">Dashboard</Link>
          </div>
        </div>
      </section>

      <section className="section container newspaper-import-section">
        <div className="newspaper-importer">
          <div className="newspaper-dropzone newspaper-coming-soon">
            <div className="newspaper-drop-icon" aria-hidden="true">N</div>
            <div>
              <h2>Newspaper conversion is coming soon</h2>
              <p>
                You can already create articles, upload gallery photos, manage
                events, and add authors from the dashboard. Newspaper upload is
                not active yet. When it is enabled, you will be able to upload a
                scanned newspaper or PDF and turn it into articles.
              </p>
            </div>
          </div>
        </div>

        <aside className="newspaper-safety-note">
          <strong>Draft-first by design</strong>
          <p>
            When this ships, imported articles will stay private until an editor
            reviews attribution, category, transcription, and images.
          </p>
        </aside>
      </section>
    </div>
  );
}
