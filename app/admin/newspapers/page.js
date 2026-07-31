import Link from 'next/link';
import NewspaperImporter from './NewspaperImporter';

export const metadata = {
  title: 'Import newspaper | YSoT Admin',
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
              <p>Turn complete newspaper pages into clean, reviewable article drafts.</p>
            </div>
            <Link href="/admin" className="secondary">← Dashboard</Link>
          </div>
        </div>
      </section>

      <section className="section container newspaper-import-section">
        <NewspaperImporter />
        <aside className="newspaper-safety-note">
          <strong>Draft-first by design</strong>
          <p>
            Every article stays private until an editor checks the transcription,
            attribution, category, and photograph and chooses Publish.
          </p>
        </aside>
      </section>
    </div>
  );
}

