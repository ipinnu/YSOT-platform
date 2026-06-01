import Link from 'next/link';
import { notFound } from 'next/navigation';
import { createClient } from '../../../../lib/supabase/server';
import ArticleForm from '../../ArticleForm';

export default async function EditArticlePage({ params }) {
  const { id } = await params;
  const supabase = await createClient();

  const [{ data: article, error }, { data: authors }, { data: categories }] = await Promise.all([
    supabase.from('articles').select('*').eq('id', id).single(),
    supabase.from('authors').select('id, name').order('name'),
    supabase.from('categories').select('id, name').order('name'),
  ]);

  if (error || !article) notFound();

  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <div className="admin-header-row">
            <div>
              <h1>Edit Article</h1>
              <p>Update content, metadata, and image for this article.</p>
            </div>
            <div className="admin-header-actions">
              <Link href={`/posts/${article.slug}`} className="secondary" target="_blank">
                View live ↗
              </Link>
              <Link href="/admin" className="secondary">← Dashboard</Link>
            </div>
          </div>
        </div>
      </section>

      <section className="section container">
        <div className="section-card">
          <ArticleForm
            article={article}
            authors={authors || []}
            categories={categories || []}
          />
        </div>
      </section>
    </div>
  );
}
