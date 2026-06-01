import Link from 'next/link';
import { createClient } from '../../../lib/supabase/server';
import ArticleForm from '../ArticleForm';

export default async function NewArticlePage() {
  const supabase = await createClient();
  const [{ data: authors }, { data: categories }] = await Promise.all([
    supabase.from('authors').select('id, name').order('name'),
    supabase.from('categories').select('id, name').order('name'),
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
