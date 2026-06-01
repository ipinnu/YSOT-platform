'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { createClient } from '../lib/supabase/client';

export default function AdminPage() {
  const [articles, setArticles] = useState([]);
  const [authors, setAuthors] = useState([]);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    fetchAll();
  }, []);

  async function fetchAll() {
    const supabase = createClient();
    const [{ data: arts }, { data: auths }] = await Promise.all([
      supabase
        .from('articles')
        .select('id, slug, title, author, category, status, featured, published_at, created_at')
        .order('created_at', { ascending: false }),
      supabase.from('authors').select('id, name').order('name'),
    ]);
    setArticles(arts || []);
    setAuthors(auths || []);
    setLoading(false);
  }

  async function handleDelete(id, title) {
    if (!confirm(`Delete "${title}"? This cannot be undone.`)) return;
    const supabase = createClient();
    await supabase.from('articles').delete().eq('id', id);
    fetchAll();
  }

  async function handlePublish(id) {
    const supabase = createClient();
    await supabase
      .from('articles')
      .update({ status: 'published', published_at: new Date().toISOString() })
      .eq('id', id);
    fetchAll();
  }

  async function handleUnpublish(id) {
    const supabase = createClient();
    await supabase.from('articles').update({ status: 'draft', published_at: null }).eq('id', id);
    fetchAll();
  }

  async function handleToggleFeatured(id, current) {
    const supabase = createClient();
    await supabase.from('articles').update({ featured: !current }).eq('id', id);
    fetchAll();
  }

  async function handleSignOut() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push('/admin-login');
    router.refresh();
  }

  const published = articles.filter((a) => a.status === 'published').length;
  const drafts = articles.filter((a) => a.status === 'draft').length;

  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <div className="admin-header-row">
            <div>
              <h1>Editorial Dashboard</h1>
              <p>Manage articles, papers, and policy briefs for YSoT.</p>
            </div>
            <div className="admin-header-actions">
              <Link href="/admin/articles/new" className="primary">+ New Article</Link>
              <Link href="/admin/authors/new" className="secondary">+ Author</Link>
              <Link href="/admin/categories/new" className="secondary">+ Category</Link>
              <button type="button" className="secondary" onClick={handleSignOut}>Sign out</button>
            </div>
          </div>
        </div>
      </section>

      <section className="section container">
        <div className="admin-stats-row">
          {[
            { label: 'Total articles', value: articles.length },
            { label: 'Published', value: published },
            { label: 'Drafts', value: drafts },
            { label: 'Authors', value: authors.length },
          ].map((stat) => (
            <div key={stat.label} className="admin-stat-card">
              <span className="admin-stat-value">{stat.value}</span>
              <span className="admin-stat-label">{stat.label}</span>
            </div>
          ))}
        </div>

        <div className="section-card" style={{ marginTop: '32px' }}>
          <h2 style={{ marginBottom: '20px' }}>All articles</h2>
          {loading ? (
            <p style={{ color: 'var(--muted)' }}>Loading…</p>
          ) : articles.length === 0 ? (
            <p style={{ color: 'var(--muted)' }}>
              No articles yet.{' '}
              <Link href="/admin/articles/new" style={{ color: 'var(--primary)' }}>Create the first one.</Link>
            </p>
          ) : (
            <div className="admin-article-list">
              {articles.map((article) => (
                <div key={article.id} className="admin-article-row">
                  <div className="admin-article-info">
                    <span className="admin-article-title">
                      {article.featured && (
                        <span className="meta-chip" style={{ fontSize: '0.65rem', padding: '1px 7px', marginRight: '8px', background: 'var(--primary)', color: '#fff' }}>
                          featured
                        </span>
                      )}
                      {article.title}
                    </span>
                    <span className="admin-article-meta">
                      {article.author && `${article.author} · `}
                      {article.category && (
                        <span className="meta-chip" style={{ fontSize: '0.7rem', padding: '1px 8px' }}>
                          {article.category}
                        </span>
                      )}
                      {' · '}
                      <span className="admin-status-badge" data-status={article.status}>
                        {article.status}
                      </span>
                    </span>
                    <span className="admin-article-slug">/posts/{article.slug}</span>
                  </div>
                  <div className="admin-article-actions">
                    <button
                      type="button"
                      className="admin-action-link"
                      title={article.featured ? 'Unfeature' : 'Feature'}
                      onClick={() => handleToggleFeatured(article.id, article.featured)}
                    >
                      {article.featured ? '★' : '☆'}
                    </button>
                    <Link href={`/admin/articles/${article.id}/edit`} className="admin-action-link">
                      Edit
                    </Link>
                    {article.status === 'draft' ? (
                      <button type="button" className="admin-action-link publish" onClick={() => handlePublish(article.id)}>
                        Publish
                      </button>
                    ) : (
                      <button type="button" className="admin-action-link unpublish" onClick={() => handleUnpublish(article.id)}>
                        Unpublish
                      </button>
                    )}
                    <button type="button" className="admin-action-link delete" onClick={() => handleDelete(article.id, article.title)}>
                      Delete
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </section>
    </div>
  );
}
