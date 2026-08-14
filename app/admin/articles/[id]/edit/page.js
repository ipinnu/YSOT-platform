import Link from 'next/link';
import { notFound } from 'next/navigation';
import { getArticleById } from '../../../../lib/firestore/articles';
import { getAuthors, getCategories } from '../../../../lib/firestore/taxonomy';
import ArticleForm from '../../ArticleForm';

export default async function EditArticlePage({ params }) {
  const { id } = await params;

  const [article, authors, categories] = await Promise.all([
    getArticleById(id),
    getAuthors(),
    getCategories(),
  ]);

  if (!article) notFound();

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
