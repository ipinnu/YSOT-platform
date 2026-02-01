import { articles } from '../lib/articles';

export default function PostsPage() {
  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <h1>All Posts</h1>
          <p>Explore the latest essays, research notes, and policy briefings.</p>
        </div>
      </section>

      <section className="section container">
        <div className="posts-grid">
          {articles.map((article) => (
            <article key={article.title} className="post-card">
              <div className="image-placeholder">Article image</div>
              <div className="post-card-content">
                <p className="post-date">{article.date}</p>
                <h3>{article.title}</h3>
                <p>{article.excerpt}</p>
                <p className="author">{article.author}</p>
                <button type="button" className="secondary">
                  Read article
                </button>
              </div>
            </article>
          ))}
        </div>
      </section>
    </div>
  );
}
