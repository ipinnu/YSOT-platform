export default function AdminLoginPage() {
  return (
    <div className="page">
      <section className="page-hero compact">
        <div className="page-hero-text">
          <h1>Admin Login</h1>
          <p>Secure access for editors and content managers.</p>
        </div>
      </section>

      <section className="section container">
        <div className="login-card">
          <h2>Sign in</h2>
          <form className="form">
            <label>
              Email
              <input type="email" placeholder="editor@ysot.ng" />
            </label>
            <label>
              Password
              <input type="password" placeholder="••••••••" />
            </label>
            <button type="button" className="primary">
              Sign in
            </button>
          </form>
          <p className="hint">
            Integrate your authentication provider (Firebase Auth, Supabase, or
            a custom API) to secure access.
          </p>
        </div>
      </section>
    </div>
  );
}
