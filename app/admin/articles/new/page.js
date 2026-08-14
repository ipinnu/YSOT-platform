import Link from 'next/link';
import { getAuthors, getCategories } from '../../../lib/firestore/taxonomy';
import ArticleForm from '../ArticleForm';

export default async function NewArticlePage() {
  const [authors, categories] = await Promise.all([
    getAuthors(),
    getCategories(),
  ]);

  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <div className="admin-header-row">
            <div>
              <h1>New Article</h1>
              <p>Create a new article, research paper, or policy brief.</p>
            </div>
            <Link href="/admin" className="secondary">← Back to dashboard</Link>
          </div>
        </div>
      </section>

      <section className="section container">
        <div className="section-card">
          <ArticleForm authors={authors || []} categories={categories || []} />
        </div>
      </section>
    </div>
  );
}
