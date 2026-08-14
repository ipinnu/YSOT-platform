'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

function formatDate(value) {
  if (!value) return 'Not published';
  return new Date(value).toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });
}

function initials(name) {
  return String(name || 'Unassigned')
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0])
    .join('')
    .toUpperCase();
}

export default function AdminPage() {
  const [articles, setArticles] = useState([]);
  const [authors, setAuthors] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState('');
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [authorFilter, setAuthorFilter] = useState('all');
  const [workingId, setWorkingId] = useState(null);
  const [actionError, setActionError] = useState('');
  const router = useRouter();

  useEffect(() => {
    fetchAll();
  }, []);

  async function fetchAll() {
    setLoadError('');
    try {
      const response = await fetch('/api/admin/dashboard');
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'The editorial library could not be loaded.');
      setArticles(data.articles || []);
      setAuthors(data.authors || []);
      setCategories(data.categories || []);
    } catch (error) {
      setLoadError(error.message || 'The editorial library could not be loaded.');
    } finally {
      setLoading(false);
    }
  }

  async function runArticleAction(id, requestOptions) {
    setWorkingId(id);
    setActionError('');
    try {
      const response = await fetch(`/api/admin/articles/${id}`, requestOptions);
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'That change could not be saved.');
      await fetchAll();
    } catch (error) {
      setActionError(error?.message || 'That change could not be saved. Please try again.');
    } finally {
      setWorkingId(null);
    }
  }

  async function handleDelete(id, title) {
    if (!confirm(`Delete "${title}"? This cannot be undone.`)) return;
    await runArticleAction(id, { method: 'DELETE' });
  }

  async function handlePublish(id) {
    await runArticleAction(id, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: 'published', published_at: new Date().toISOString() }),
    });
  }

  async function handleUnpublish(id) {
    await runArticleAction(id, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: 'draft', published_at: null }),
    });
  }

  async function handleToggleFeatured(id, current) {
    await runArticleAction(id, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ featured: !current }),
    });
  }

  async function handleSignOut() {
    await fetch('/api/auth/session', { method: 'DELETE' });
    router.push('/admin-login');
    router.refresh();
  }

  const published = articles.filter((article) => article.status === 'published').length;
  const drafts = articles.filter((article) => article.status === 'draft').length;

  const categoryRows = useMemo(() => {
    const names = new Set(categories.map((category) => category.name));
    articles.forEach((article) => article.category && names.add(article.category));
    return [...names]
      .sort((a, b) => a.localeCompare(b))
      .map((name) => ({
        name,
        count: articles.filter((article) => article.category === name).length,
      }));
  }, [articles, categories]);

  const authorRows = useMemo(() => {
    const rows = authors.map((author) => ({
      ...author,
      count: articles.filter(
        (article) => article.author_id === author.id || article.author === author.name
      ).length,
    }));
    const unassigned = articles.filter(
      (article) => !article.author_id && !article.author
    ).length;
    return { rows, unassigned };
  }, [articles, authors]);

  const filteredArticles = useMemo(() => {
    const query = search.trim().toLowerCase();
    return articles.filter((article) => {
      const matchesSearch =
        !query ||
        [article.title, article.excerpt, article.author, article.category, article.slug]
          .filter(Boolean)
          .some((value) => value.toLowerCase().includes(query));
      const matchesStatus =
        statusFilter === 'all' || article.status === statusFilter;
      const matchesCategory =
        categoryFilter === 'all' || article.category === categoryFilter;
      const selectedAuthor = authors.find((author) => author.id === authorFilter);
      const matchesAuthor =
        authorFilter === 'all' ||
        (authorFilter === 'unassigned'
          ? !article.author_id && !article.author
          : article.author_id === authorFilter ||
            (selectedAuthor && article.author === selectedAuthor.name));
      return matchesSearch && matchesStatus && matchesCategory && matchesAuthor;
    });
  }, [articles, authors, search, statusFilter, categoryFilter, authorFilter]);

  const filtersActive =
    search || statusFilter !== 'all' || categoryFilter !== 'all' || authorFilter !== 'all';

  function clearFilters() {
    setSearch('');
    setStatusFilter('all');
    setCategoryFilter('all');
    setAuthorFilter('all');
  }

  return (
    <div className="page admin-page">
      <section className="admin-command-hero">
        <div className="container admin-command-inner">
          <div className="admin-command-copy">
            <span className="admin-eyebrow">
              <span className="admin-live-dot" />
              YSoT Editorial Desk
            </span>
            <h1>Content Control Room</h1>
            <p>
              Everything you publish lives here—articles, writers, categories,
              gallery, events, newspaper imports, and editorial status.
            </p>
          </div>

          <div className="admin-command-actions">
            <Link href="/admin/articles/new" className="primary admin-main-action">
              <span aria-hidden="true">+</span> New article
            </Link>
            <Link href="/admin/newspapers" className="admin-import-action">
              Newspaper importer
            </Link>
            <Link href="/admin/gallery" className="admin-import-action">
              Manage gallery
            </Link>
            <Link href="/admin/events" className="admin-import-action">
              Manage events
            </Link>
            <button type="button" className="admin-signout" onClick={handleSignOut}>
              Sign out
            </button>
          </div>
        </div>
      </section>

      <main className="container admin-dashboard">
        <section className="admin-overview" aria-label="Editorial overview">
          {[
            { label: 'All articles', value: articles.length, tone: 'blue', note: 'Entire library' },
            { label: 'Published', value: published, tone: 'green', note: 'Live on the website' },
            { label: 'Drafts', value: drafts, tone: 'gold', note: 'Waiting for review' },
            { label: 'Writers', value: authors.length, tone: 'ink', note: 'Contributor profiles' },
          ].map((stat) => (
            <div key={stat.label} className="admin-overview-card" data-tone={stat.tone}>
              <span className="admin-overview-label">{stat.label}</span>
              <strong>{loading ? '—' : stat.value}</strong>
              <small>{stat.note}</small>
            </div>
          ))}
        </section>

        {loadError && (
          <div className="admin-load-error" role="alert">
            <span>{loadError}</span>
            <button type="button" onClick={fetchAll}>Try again</button>
          </div>
        )}

        {actionError && (
          <div className="admin-load-error" role="alert">
            <span>{actionError}</span>
            <button type="button" onClick={() => setActionError('')}>Dismiss</button>
          </div>
        )}

        <div className="admin-workspace-grid">
          <section className="admin-library-panel">
            <div className="admin-panel-heading">
              <div>
                <span className="admin-section-kicker">Content library</span>
                <h2>Articles</h2>
                <p>
                  {loading
                    ? 'Loading your editorial library…'
                    : `${filteredArticles.length} of ${articles.length} articles shown`}
                </p>
              </div>
              <Link
                href="/admin/articles/new"
                className="admin-round-plus"
                aria-label="Add a new article"
                title="Add a new article"
              >
                +
              </Link>
            </div>

            <div className="admin-library-tools">
              <label className="admin-search">
                <span aria-hidden="true">⌕</span>
                <input
                  type="search"
                  value={search}
                  onChange={(event) => setSearch(event.target.value)}
                  placeholder="Search title, writer, category…"
                  aria-label="Search articles"
                />
              </label>

              <div className="admin-status-filter" aria-label="Filter articles by status">
                {[
                  { value: 'all', label: 'All' },
                  { value: 'published', label: 'Published' },
                  { value: 'draft', label: 'Drafts' },
                ].map((option) => (
                  <button
                    key={option.value}
                    type="button"
                    className={statusFilter === option.value ? 'active' : ''}
                    onClick={() => setStatusFilter(option.value)}
                  >
                    {option.label}
                  </button>
                ))}
              </div>

              <select
                className="admin-filter-select"
                value={categoryFilter}
                onChange={(event) => setCategoryFilter(event.target.value)}
                aria-label="Filter articles by category"
              >
                <option value="all">Every category</option>
                {categoryRows.map((category) => (
                  <option key={category.name} value={category.name}>
                    {category.name}
                  </option>
                ))}
              </select>

              {filtersActive && (
                <button type="button" className="admin-clear-filters" onClick={clearFilters}>
                  Clear
                </button>
              )}
            </div>

            {loading ? (
              <div className="admin-library-loading">
                <span />
                <span />
                <span />
              </div>
            ) : filteredArticles.length === 0 ? (
              <div className="admin-library-empty">
                <div aria-hidden="true">Y</div>
                <h3>{articles.length === 0 ? 'Your library is ready' : 'No articles match'}</h3>
                <p>
                  {articles.length === 0
                    ? 'Create an article to begin.'
                    : 'Try clearing a filter or searching for another phrase.'}
                </p>
                {articles.length === 0 ? (
                  <Link href="/admin/articles/new" className="primary">+ Create first article</Link>
                ) : (
                  <button type="button" className="secondary" onClick={clearFilters}>
                    Clear filters
                  </button>
                )}
              </div>
            ) : (
              <div className="admin-content-list">
                {filteredArticles.map((article) => {
                  const busy = workingId === article.id;
                  return (
                    <article key={article.id} className="admin-content-row">
                      <div className="admin-content-thumb">
                        {article.image_url ? (
                          <img src={article.image_url} alt="" />
                        ) : (
                          <span>{initials(article.title)}</span>
                        )}
                        {article.featured && <b title="Featured article">★</b>}
                      </div>

                      <div className="admin-content-main">
                        <div className="admin-content-flags">
                          <span className="admin-status-badge" data-status={article.status}>
                            {article.status}
                          </span>
                          {article.category && (
                            <span className="admin-category-label">{article.category}</span>
                          )}
                        </div>
                        <h3>
                          <Link href={`/admin/articles/${article.id}/edit`}>
                            {article.title}
                          </Link>
                        </h3>
                        <div className="admin-content-meta">
                          <span>{article.author || 'Writer not assigned'}</span>
                          <i />
                          <span>{article.read_time || 'Read time not set'}</span>
                          <i />
                          <span>
                            {article.status === 'published'
                              ? formatDate(article.published_at)
                              : `Created ${formatDate(article.created_at)}`}
                          </span>
                        </div>
                      </div>

                      <div className="admin-content-actions" aria-label={`Actions for ${article.title}`}>
                        <Link href={`/admin/articles/${article.id}/edit`} className="admin-row-edit">
                          Edit
                        </Link>
                        <button
                          type="button"
                          onClick={() => handleToggleFeatured(article.id, article.featured)}
                          disabled={busy}
                          title={article.featured ? 'Remove from featured' : 'Mark as featured'}
                        >
                          {article.featured ? 'Unfeature' : 'Feature'}
                        </button>
                        {article.status === 'draft' ? (
                          <button
                            type="button"
                            className="publish"
                            onClick={() => handlePublish(article.id)}
                            disabled={busy}
                          >
                            {busy ? 'Working…' : 'Publish'}
                          </button>
                        ) : (
                          <button
                            type="button"
                            onClick={() => handleUnpublish(article.id)}
                            disabled={busy}
                          >
                            {busy ? 'Working…' : 'Move to drafts'}
                          </button>
                        )}
                        <button
                          type="button"
                          className="delete"
                          onClick={() => handleDelete(article.id, article.title)}
                          disabled={busy}
                        >
                          Delete
                        </button>
                      </div>
                    </article>
                  );
                })}
              </div>
            )}
          </section>

          <aside className="admin-collections">
            <section className="admin-collection-card">
              <div className="admin-collection-heading">
                <div>
                  <span className="admin-section-kicker">People</span>
                  <h2>Writers</h2>
                </div>
                <Link
                  href="/admin/authors/new"
                  className="admin-mini-plus"
                  aria-label="Add a writer"
                  title="Add a writer"
                >
                  +
                </Link>
              </div>

              <div className="admin-writer-list">
                {authorRows.rows.length === 0 && !loading ? (
                  <div className="admin-mini-empty">
                    <p>No writer profiles yet.</p>
                    <Link href="/admin/authors/new">+ Add the first writer</Link>
                  </div>
                ) : (
                  authorRows.rows.map((author) => (
                    <button
                      type="button"
                      key={author.id}
                      className={authorFilter === author.id ? 'admin-writer active' : 'admin-writer'}
                      onClick={() =>
                        setAuthorFilter((current) => current === author.id ? 'all' : author.id)
                      }
                    >
                      <span className="admin-writer-avatar">
                        {author.image_url ? (
                          <img src={author.image_url} alt="" />
                        ) : (
                          initials(author.name)
                        )}
                      </span>
                      <span className="admin-writer-name">
                        <strong>{author.name}</strong>
                        <small>{author.count} article{author.count === 1 ? '' : 's'}</small>
                      </span>
                      <span aria-hidden="true">›</span>
                    </button>
                  ))
                )}

                {authorRows.unassigned > 0 && (
                  <button
                    type="button"
                    className={authorFilter === 'unassigned' ? 'admin-writer active' : 'admin-writer'}
                    onClick={() =>
                      setAuthorFilter((current) => current === 'unassigned' ? 'all' : 'unassigned')
                    }
                  >
                    <span className="admin-writer-avatar unassigned">?</span>
                    <span className="admin-writer-name">
                      <strong>Writer not assigned</strong>
                      <small>{authorRows.unassigned} article{authorRows.unassigned === 1 ? '' : 's'}</small>
                    </span>
                    <span aria-hidden="true">›</span>
                  </button>
                )}
              </div>
            </section>

            <section className="admin-collection-card">
              <div className="admin-collection-heading">
                <div>
                  <span className="admin-section-kicker">Organisation</span>
                  <h2>Categories</h2>
                </div>
                <Link
                  href="/admin/categories/new"
                  className="admin-mini-plus"
                  aria-label="Add a category"
                  title="Add a category"
                >
                  +
                </Link>
              </div>

              <div className="admin-category-list">
                {categoryRows.map((category) => (
                  <button
                    type="button"
                    key={category.name}
                    className={categoryFilter === category.name ? 'active' : ''}
                    onClick={() =>
                      setCategoryFilter((current) =>
                        current === category.name ? 'all' : category.name
                      )
                    }
                  >
                    <span>{category.name}</span>
                    <b>{category.count}</b>
                  </button>
                ))}
              </div>
            </section>

            <Link href="/admin/newspapers" className="admin-import-card">
              <span className="admin-import-mark">N</span>
              <span>
                <small>Coming soon</small>
                <strong>Newspaper importer</strong>
                <em>PDF, JPG or PNG to article drafts</em>
              </span>
              <b aria-hidden="true">→</b>
            </Link>

            <Link href="/admin/gallery" className="admin-import-card">
              <span className="admin-import-mark">G</span>
              <span>
                <small>Visual archive</small>
                <strong>Manage gallery</strong>
                <em>Upload photos for the public gallery</em>
              </span>
              <b aria-hidden="true">→</b>
            </Link>

            <Link href="/admin/events" className="admin-import-card">
              <span className="admin-import-mark">E</span>
              <span>
                <small>Calendar &amp; recaps</small>
                <strong>Manage events</strong>
                <em>Upcoming sessions and past event photos</em>
              </span>
              <b aria-hidden="true">→</b>
            </Link>
          </aside>
        </div>
      </main>
    </div>
  );
}
