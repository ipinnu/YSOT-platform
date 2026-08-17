# Migration Handoff: Supabase → Firebase + Cloudflare R2

**Project:** YSoT Platform (`ysotwebsite`)  
**Date:** 2026-08-10  
**Scope:** Replace Supabase Auth + Postgres with Firebase Auth + Firestore. Replace Supabase Storage with Cloudflare R2.  
**Estimated effort:** 7–12 working days for one developer familiar with Firebase and Cloudflare.

> **Reminder for next session:** Firebase lives on the **yotfulmastery** Google account. The Firebase project name is **`ipinnu`**. Log in with that account before touching Auth, Firestore, or env setup.

---

## 1. Executive summary

The app today is a Next.js 14 CMS with:

- **Supabase Auth** — single admin email/password login
- **Supabase Postgres** — 5 tables (`articles`, `authors`, `categories`, `gallery_items`, `events`)
- **Supabase Storage** — public `article-images` bucket + private `newspaper-imports` bucket

The migration is **moderate complexity**. The codebase is small (~20 files touch Supabase), but three subsystems change at once:

1. Session/auth plumbing (middleware, server components, client forms)
2. SQL/RLS → Firestore documents + Security Rules
3. Storage SDK → Cloudflare R2 presigned uploads + server-side reads/writes

**Recommended approach:** introduce a data access layer first, migrate auth second, Firestore third, R2 last (newspaper importer is the hardest storage feature).

---

## 2. Current state inventory

### 2.1 Supabase touchpoints

| Area | Files |
|------|-------|
| Client SDK | `app/lib/supabase/client.js` |
| Server SDK | `app/lib/supabase/server.js` |
| Middleware auth | `middleware.ts` |
| Admin gate | `app/admin/layout.js` |
| Login | `app/admin-login/page.js` |
| Data helpers | `app/lib/articles.js`, `app/lib/gallery.js`, `app/lib/events.js` |
| Upload helper | `app/lib/upload.js` |
| Admin CRUD | `app/admin/page.js`, `ArticleForm.js`, `authors/new`, `categories/new`, `gallery/*`, `events/*` |
| API routes | `app/api/admin/newspapers/analyze/route.js`, `finalize/route.js` |
| Newspaper UI | `app/admin/newspapers/NewspaperImporter.js` |
| Schema | `supabase/schema.sql` |

### 2.2 Database tables (Postgres → Firestore mapping)

| Postgres table | Rows / usage | Joins / special queries |
|----------------|--------------|-------------------------|
| `articles` | Core CMS | JOIN `authors`; filter by `status`, `category`, `featured`; order by `published_at` |
| `authors` | Writer profiles | Referenced by `articles.author_id` |
| `categories` | Dropdown list | Unique `name`; also denormalized on articles |
| `gallery_items` | Public gallery | Filter `published`; order by `sort_order`, `created_at` |
| `events` | Public events | Filter `published`; order by `event_date`, `sort_order` |

### 2.3 Storage buckets

| Bucket | Access | Used by |
|--------|--------|---------|
| `article-images` | Public | Articles, authors, gallery, events, newspaper finalize |
| `newspaper-imports` | Private per-user prefix | Newspaper analyze/finalize pipeline |

Path conventions today:

```
article-images/
  {timestamp}-{random}.{ext}           # articles
  authors/{timestamp}-{random}.{ext}
  gallery/{timestamp}-{random}.{ext}
  events/{timestamp}-{random}.{ext}
  events/recaps/{timestamp}-{random}.{ext}
  newspapers/{timestamp}-{slug}.jpg

newspaper-imports/
  {userId}/{timestamp}-page-{n}.jpg
```

### 2.4 Auth model today

- One or more admin users created manually in Supabase Auth
- No roles table — any authenticated user is an admin
- Middleware protects `/admin/*` (except `/admin-login`)
- RLS: public read where noted; authenticated users get full write access

---

## 3. Target architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Next.js App (Netlify/Vercel)            │
├─────────────────────────────────────────────────────────────┤
│  Public pages          │  Admin pages        │  API routes  │
│  /posts, /gallery,     │  /admin/*           │  /api/admin/ │
│  /events               │  /admin-login       │  newspapers/*│
├────────────────────────┴─────────────────────┴──────────────┤
│                    Data access layer (NEW)                  │
│  app/lib/db/articles.ts   app/lib/db/auth.ts                │
│  app/lib/db/authors.ts    app/lib/storage/r2.ts             │
│  app/lib/db/categories.ts app/lib/storage/paths.ts          │
│  app/lib/db/gallery.ts                                      │
│  app/lib/db/events.ts                                       │
├──────────────────────────────┬──────────────────────────────┤
│      Firebase Auth           │         Firestore            │
│  (email/password admins)     │  (articles, authors, etc.)   │
├──────────────────────────────┴──────────────────────────────┤
│                    Cloudflare R2                            │
│  bucket: ysot-media                                           │
│  public: articles, authors, gallery, events                   │
│  private: newspaper-imports/{uid}/...                        │
└─────────────────────────────────────────────────────────────┘
```

**Principle:** UI components never import Firebase or AWS/R2 SDKs directly. They call `app/lib/db/*` and `app/lib/storage/*`.

---

## 4. Proposed file layout (data access layer)

Create these modules before touching UI files:

```
app/lib/
├── db/
│   ├── client.ts              # Firebase Admin (server) + Firestore instance
│   ├── client-browser.ts      # Firebase client SDK (auth only in browser)
│   ├── auth.ts                # signIn, signOut, getSessionUser, verifyIdToken
│   ├── articles.ts            # list, getBySlug, getById, create, update, delete
│   ├── authors.ts
│   ├── categories.ts
│   ├── gallery.ts
│   ├── events.ts
│   ├── slugs.ts               # unique slug reservation (replaces SQL LIKE)
│   └── types.ts               # shared TypeScript interfaces
├── storage/
│   ├── r2.ts                  # upload, download, delete, getPublicUrl
│   ├── paths.ts               # path builders (gallery/, events/recaps/, etc.)
│   └── presign.ts             # optional: presigned PUT for browser uploads
└── dates.ts                   # keep as-is (formatEventDate)
```

**Delete after migration:**

```
app/lib/supabase/client.js
app/lib/supabase/server.js
middleware.ts                  → replace with Firebase session middleware
```

---

## 5. Firestore schema

Use **top-level collections**. Document IDs can be auto-generated Firestore IDs; keep legacy UUIDs in an `legacyId` field during migration if needed for image URL stability.

### 5.1 Collection: `articles`

```typescript
interface Article {
  id: string;                    // Firestore doc ID
  slug: string;                  // unique — enforced via slugs collection
  title: string;
  excerpt: string;
  content: ContentBlock[];       // same shape as today (JSONB → array)
  authorId: string | null;       // was author_id
  author: string;                // denormalized display name (KEEP)
  authorBio: string;             // was author_bio
  category: string;
  imageUrl: string;              // was image_url — R2 public URL
  readTime: string;              // was read_time
  featured: boolean;
  status: 'draft' | 'published';
  publishedAt: Timestamp | null; // was published_at
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

**Denormalization rule:** when an author is saved, optionally batch-update articles where `authorId == author.id` to refresh `author` and `authorBio`. For v1, updating on article save (as today) is enough.

**Indexes required:**

| Collection | Fields | Purpose |
|------------|--------|---------|
| `articles` | `status` ASC, `publishedAt` DESC | Public listing |
| `articles` | `slug` ASC | Slug lookup (also use slugs collection) |
| `articles` | `status` ASC, `featured` ASC, `publishedAt` DESC | Featured hero |
| `articles` | `category` ASC, `status` ASC | Admin filters |

### 5.2 Collection: `authors`

```typescript
interface Author {
  id: string;
  name: string;
  description: string;
  imageUrl: string;
  createdAt: Timestamp;
}
```

### 5.3 Collection: `categories`

```typescript
interface Category {
  id: string;
  name: string;                  // unique — enforce in app + rules
  createdAt: Timestamp;
}
```

**Alternative:** store categories as a single doc `config/categories` with a `names: string[]` array. Current app only needs names for dropdowns; either works. Keep a collection if you want CRUD parity with today.

### 5.4 Collection: `gallery_items`

```typescript
interface GalleryItem {
  id: string;
  alt: string;
  imageUrl: string;
  sortOrder: number;             // was sort_order
  published: boolean;
  createdAt: Timestamp;
}
```

**Index:** `published` ASC, `sortOrder` ASC, `createdAt` DESC

### 5.5 Collection: `events`

```typescript
interface Event {
  id: string;
  title: string;
  description: string;
  location: string;
  format: string;
  eventDate: string;             // ISO date "YYYY-MM-DD" (was DATE)
  status: 'upcoming' | 'past';
  imageUrl: string;
  recapImageUrl: string;
  recapTitle: string;
  recapDescription: string;
  published: boolean;
  sortOrder: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

**Index:** `published` ASC, `eventDate` ASC, `sortOrder` ASC

### 5.6 Collection: `slugs` (new — replaces SQL uniqueness)

```typescript
// Document ID = slug string, e.g. "who-is-thinking-for-nigeria"
interface SlugReservation {
  articleId: string;
  createdAt: Timestamp;
}
```

**Flow for new article:**

1. Generate base slug from title
2. Try `set(slugDoc, { articleId }, { merge: false })` in a transaction
3. On collision, append `-2`, `-3`, etc.
4. On article delete, delete slug doc in same batch

This replaces `uniqueSlug()` in `finalize/route.js` which uses `LIKE 'slug%'`.

### 5.7 Collection: `admins` (recommended)

```typescript
// Document ID = Firebase Auth UID
interface AdminUser {
  email: string;
  active: boolean;
  createdAt: Timestamp;
}
```

Use this instead of treating **any** authenticated Firebase user as admin. Seed your editor UID(s) manually after first login.

---

## 6. Field mapping reference (Postgres → Firestore)

| Postgres (snake_case) | Firestore (camelCase) |
|-----------------------|------------------------|
| `author_id` | `authorId` |
| `author_bio` | `authorBio` |
| `image_url` | `imageUrl` |
| `read_time` | `readTime` |
| `published_at` | `publishedAt` |
| `created_at` | `createdAt` |
| `updated_at` | `updatedAt` |
| `sort_order` | `sortOrder` |
| `event_date` | `eventDate` |
| `recap_image_url` | `recapImageUrl` |
| `recap_title` | `recapTitle` |
| `recap_description` | `recapDescription` |

**Content blocks:** keep identical structure from `app/lib/content.js` — no transform needed beyond JSON parse/stringify.

---

## 7. Firestore Security Rules (draft)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAdmin() {
      return request.auth != null
        && exists(/databases/$(database)/documents/admins/$(request.auth.uid))
        && get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.active == true;
    }

    // Public read: published articles only
    match /articles/{id} {
      allow read: if resource.data.status == 'published' || isAdmin();
      allow create, update, delete: if isAdmin();
    }

    match /authors/{id} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /categories/{id} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /gallery_items/{id} {
      allow read: if resource.data.published == true || isAdmin();
      allow write: if isAdmin();
    }

    match /events/{id} {
      allow read: if resource.data.published == true || isAdmin();
      allow write: if isAdmin();
    }

    match /slugs/{slug} {
      allow read: if isAdmin();
      allow write: if isAdmin();
    }

    match /admins/{uid} {
      allow read: if request.auth != null && request.auth.uid == uid;
      allow write: if false; // manage via Firebase console / Admin SDK only
    }
  }
}
```

**Note:** Public pages currently use the **server** Supabase client (service role via anon key + RLS). With Firestore, public reads can either:

- **Option A (recommended):** Server components use **Firebase Admin SDK** (bypasses rules, same as today’s server trust model)
- **Option B:** Client reads with rules (not needed for this app)

Use Admin SDK in `app/lib/db/client.ts` for all server-side reads/writes. Browser admin forms can use Admin-backed API routes or client SDK with rules — prefer **API routes + Admin SDK** for writes to avoid exposing Firestore client writes.

---

## 8. Firebase Auth + Next.js session

### 8.1 Packages to add

```bash
npm install firebase firebase-admin
npm uninstall @supabase/ssr @supabase/supabase-js
```

### 8.2 Environment variables

Firebase project: **`ipinnu`** (Google account: **yotfulmastery**)

```bash
# Firebase client (browser — login page only)
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=

# Firebase Admin (server)
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=          # escaped newlines: \n

# Cloudflare R2 (server)
R2_ACCOUNT_ID=
R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
R2_BUCKET_NAME=ysot-media
R2_PUBLIC_BASE_URL=            # e.g. https://media.ysot.ng or r2.dev URL
```

Remove:

```bash
NEXT_PUBLIC_SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY
```

### 8.3 Session strategy

Replace Supabase cookie refresh in `middleware.ts` with:

1. Admin signs in on `/admin-login` via Firebase client `signInWithEmailAndPassword`
2. Client gets ID token → POST to `/api/auth/session` 
3. API route verifies token with Admin SDK → sets **httpOnly session cookie** (7-day expiry)
4. Middleware reads cookie → verifies with Admin SDK → attaches user to request context
5. `app/admin/layout.js` checks session same way

**Reference libraries (pick one):**

- Roll your own with `firebase-admin` + `cookies()` (~100 lines)
- `next-firebase-auth-edge` if deploying to Edge middleware

### 8.4 Auth module API (`app/lib/db/auth.ts`)

```typescript
// Server
getSessionUser(): Promise<{ uid: string; email: string } | null>
requireAdmin(): Promise<{ uid: string; email: string }>  // throws / redirects

// Client (admin-login only)
signInWithPassword(email, password): Promise<void>
signOut(): Promise<void>
```

---

## 9. Cloudflare R2 storage design

### 9.1 Bucket structure

Single bucket `ysot-media`:

```
ysot-media/
├── public/
│   ├── articles/{id}/{filename}
│   ├── authors/{id}/{filename}
│   ├── gallery/{id}/{filename}
│   ├── events/{id}/{filename}
│   └── events/recaps/{id}/{filename}
└── private/
    └── newspaper-imports/{uid}/{importId}/page-{n}.jpg
```

Public objects served via:

- **Custom domain** (recommended): `https://media.ysot.ng/public/...`
- Or R2 public bucket URL

### 9.2 Upload flows

#### A. Admin image upload (articles, authors, gallery, events)

**Recommended: server-side upload via API route**

```
Browser Form
  → POST /api/admin/uploads (multipart/form-data, session required)
  → API verifies admin session
  → @aws-sdk/client-s3 PutObject to R2
  → returns { publicUrl }
  → form saves URL to Firestore on submit
```

Replace `app/lib/upload.js` with `app/lib/storage/r2.ts`:

```typescript
uploadPublicFile(file: Buffer | Blob, key: string, contentType: string): Promise<string>
uploadPrivateFile(file: Buffer, key: string, contentType: string): Promise<void>
downloadPrivateFile(key: string): Promise<Buffer>
deleteFile(key: string): Promise<void>
getPublicUrl(key: string): string
createPresignedUpload(key: string, contentType: string, expiresIn?: number): Promise<string>
```

Use `@aws-sdk/client-s3` with R2 endpoint:

```
https://{R2_ACCOUNT_ID}.r2.cloudflarestorage.com
```

#### B. Newspaper import (private temp → public crop)

Current flow:

1. Browser uploads pages to `newspaper-imports/{uid}/...`
2. Analyze route gets signed URLs
3. Finalize downloads page, crops with `sharp`, uploads to `article-images`

New flow:

1. Browser POSTs each page to `/api/admin/newspapers/upload-page` → R2 private prefix
2. Analyze route receives **storage keys** (not Supabase signed URLs); server generates short-lived presigned GET for Groq vision if needed, or reads bytes server-side
3. Finalize: `downloadPrivateFile` → `sharp` crop → `uploadPublicFile` → Firestore article insert → delete private prefix

### 9.3 CORS (if using presigned browser PUT)

Configure R2 bucket CORS for admin origin:

```json
[
  {
    "AllowedOrigins": ["https://ysot.ng", "http://localhost:3000"],
    "AllowedMethods": ["PUT", "GET"],
    "AllowedHeaders": ["*"],
    "MaxAgeSeconds": 3600
  }
]
```

---

## 10. Data access layer — function signatures

Implement these to mirror current Supabase usage. Server components and API routes import from here.

### `articles.ts`

```typescript
listArticles(options?: { status?: 'draft' | 'published' | 'all' }): Promise<Article[]>
getArticleBySlug(slug: string): Promise<Article | null>
getArticleById(id: string): Promise<Article | null>
createArticle(data: Omit<Article, 'id' | 'createdAt' | 'updatedAt'>): Promise<Article>
updateArticle(id: string, data: Partial<Article>): Promise<Article>
deleteArticle(id: string): Promise<void>
reserveUniqueSlug(title: string, articleId?: string): Promise<string>
listAllSlugs(): Promise<string[]>
```

### `authors.ts`

```typescript
listAuthors(): Promise<Author[]>
getAuthorById(id: string): Promise<Author | null>
createAuthor(data): Promise<Author>
```

### `categories.ts`

```typescript
listCategories(): Promise<Category[]>
createCategory(name: string): Promise<Category>
```

### `gallery.ts`

```typescript
listGalleryItems(options?: { publishedOnly?: boolean }): Promise<GalleryItem[]>
getGalleryItemById(id: string): Promise<GalleryItem | null>
createGalleryItem(data): Promise<GalleryItem>
updateGalleryItem(id, data): Promise<GalleryItem>
deleteGalleryItem(id: string): Promise<void>
```

### `events.ts`

```typescript
listEvents(options?: { publishedOnly?: boolean }): Promise<Event[]>
getEventById(id: string): Promise<Event | null>
createEvent(data): Promise<Event>
updateEvent(id, data): Promise<Event>
deleteEvent(id: string): Promise<void>
```

---

## 11. File-by-file migration map

| File | Action |
|------|--------|
| `middleware.ts` | Rewrite for Firebase session cookie verification |
| `app/lib/supabase/*` | Delete; replace imports with `app/lib/db/*` |
| `app/lib/articles.js` | Rewrite to call `db/articles.ts` (Admin SDK) |
| `app/lib/gallery.js` | Rewrite to call `db/gallery.ts` |
| `app/lib/events.js` | Rewrite to call `db/events.ts` |
| `app/lib/upload.js` | Replace with `storage/r2.ts` + `/api/admin/uploads` |
| `app/admin-login/page.js` | Firebase client sign-in + session cookie POST |
| `app/admin/layout.js` | `requireAdmin()` instead of Supabase `getUser()` |
| `app/admin/page.js` | Import from `db/*` modules |
| `app/admin/articles/ArticleForm.js` | Upload via API route; save via `db/articles` |
| `app/admin/authors/new/page.js` | Same pattern |
| `app/admin/gallery/GalleryForm.js` | Same pattern |
| `app/admin/events/EventForm.js` | Same pattern |
| `app/admin/gallery/page.js` | `db/gallery` CRUD |
| `app/admin/events/page.js` | `db/events` CRUD |
| `app/api/admin/newspapers/analyze/route.js` | R2 keys instead of Supabase signed URLs |
| `app/api/admin/newspapers/finalize/route.js` | R2 download/upload + Firestore insert |
| `app/admin/newspapers/NewspaperImporter.js` | Upload pages via new API route |
| `next.config.js` | Remove `*.supabase.co` image hostname; add R2/media domain if using `next/image` |
| `supabase/schema.sql` | Archive; no longer source of truth |
| `README.md` | Update setup instructions |

**New files to create:**

```
app/api/auth/session/route.js       # login cookie
app/api/auth/logout/route.js
app/api/admin/uploads/route.js      # image upload to R2
app/api/admin/newspapers/upload-page/route.js
app/lib/db/client.ts
app/lib/db/auth.ts
app/lib/db/articles.ts
app/lib/db/authors.ts
app/lib/db/categories.ts
app/lib/db/gallery.ts
app/lib/db/events.ts
app/lib/db/slugs.ts
app/lib/db/types.ts
app/lib/storage/r2.ts
app/lib/storage/paths.ts
firestore.rules
firestore.indexes.json
scripts/migrate-supabase-to-firebase.mjs
```

---

## 12. Phased implementation plan

### Phase 0 — Prep (Day 1)

- [ ] Log in to [Firebase Console](https://console.firebase.google.com) with the **yotfulmastery** account
- [ ] Open project **`ipinnu`** (create/link if not already wired to this repo)
- [ ] Enable Auth (email/password) and Firestore
- [ ] Create Cloudflare R2 bucket + API token + public domain
- [ ] Add env vars to local `.env.local` and deployment
- [ ] Create `admins/{uid}` doc for first editor after test login
- [ ] Deploy `firestore.rules` and indexes

### Phase 1 — Data layer skeleton (Day 1–2)

- [ ] Implement `app/lib/db/client.ts` (Admin SDK)
- [ ] Implement `app/lib/storage/r2.ts`
- [ ] Implement `articles`, `authors`, `categories`, `gallery`, `events`, `slugs` modules
- [ ] Unit-test slug reservation and date formatting

### Phase 2 — Auth (Day 2–3)

- [ ] `/api/auth/session` + `/api/auth/logout`
- [ ] Rewrite `middleware.ts`
- [ ] Update `admin-login`, `admin/layout`, sign-out in `admin/page.js`
- [ ] Verify `/admin` gate works before migrating data reads

### Phase 3 — Firestore CRUD (Day 3–6)

- [ ] Swap `app/lib/articles.js`, `gallery.js`, `events.js` to db layer
- [ ] Update all admin forms to use db layer + upload API
- [ ] Public pages: `/posts`, `/posts/[slug]`, `/gallery`, `/events`
- [ ] Remove all `@supabase/*` imports from admin UI

### Phase 4 — R2 storage (Day 6–8)

- [ ] `/api/admin/uploads` for public images
- [ ] Port newspaper upload/analyze/finalize to R2 private prefix
- [ ] Update `finalize/route.js` sharp pipeline to use `downloadPrivateFile` / `uploadPublicFile`

### Phase 5 — Data migration (Day 8–9)

- [ ] Export Supabase Postgres (JSON or CSV per table)
- [ ] Export/copy images from Supabase Storage to R2 (preserve or rewrite URLs)
- [ ] Run `scripts/migrate-supabase-to-firebase.mjs`
- [ ] Build slug reservation docs from existing articles
- [ ] Seed default categories if empty

### Phase 6 — Cutover & QA (Day 9–12)

- [ ] Full regression: login, CRUD all entities, public pages, newspaper import
- [ ] Remove Supabase deps and env vars
- [ ] Update README
- [ ] Monitor Firestore reads/writes and R2 egress for first week

---

## 13. Data migration script outline

`scripts/migrate-supabase-to-firebase.mjs` should:

1. Read Supabase export JSON (or query via service role one last time)
2. For each table, batch-write to Firestore (500 ops max per batch)
3. Map snake_case → camelCase
4. Convert timestamps to Firestore `Timestamp`
5. For each `image_url`, if hosted on `supabase.co`:
   - Download object
   - Upload to R2 under `public/{collection}/{id}/...`
   - Rewrite URL in document
6. Create `slugs/{slug}` doc for each article
7. Log failures to `migration-errors.json`

**Order:** authors → categories → articles → gallery_items → events

---

## 14. Content block shape (unchanged)

Keep `app/lib/content.js` as-is. Firestore stores:

```json
[
  { "type": "heading", "level": 2, "text": "Introduction" },
  { "type": "paragraph", "text": "..." },
  { "type": "quote", "text": "..." },
  { "type": "image", "url": "https://media.ysot.ng/...", "caption": "..." }
]
```

---

## 15. Testing checklist

### Auth

- [ ] Unauthenticated user redirected from `/admin` to `/admin-login`
- [ ] Valid login reaches dashboard; invalid shows error
- [ ] Sign out clears session
- [ ] Non-admin Firebase user (no `admins/{uid}` doc) cannot write

### Articles

- [ ] Create draft with image upload
- [ ] Publish / unpublish / feature / delete
- [ ] Public `/posts` shows only published
- [ ] `/posts/[slug]` resolves correctly
- [ ] Slug collision appends `-2`

### Authors, categories, gallery, events

- [ ] CRUD from admin
- [ ] Public pages reflect published items only
- [ ] Gallery lightbox works with R2 URLs
- [ ] Event recap modal shows per-event recap image

### Newspaper importer

- [ ] PDF/JPG/PNG upload to private R2 prefix
- [ ] Groq analyze receives readable images
- [ ] Finalize creates drafts with cropped hero image on R2
- [ ] Temp private files deleted after success

### Performance

- [ ] Public pages still render if Firestore slow (keep 2.5s timeout pattern from `articles.js` or equivalent)

---

## 16. Risks and mitigations

| Risk | Mitigation |
|------|------------|
| Firestore has no JOINs | Denormalize `author` on articles (already partially done) |
| Slug uniqueness | Dedicated `slugs` collection + transaction |
| Split vendors (Firebase + Cloudflare) | Hide behind `db/*` and `storage/*` modules |
| Firebase Admin in serverless cold starts | Keep Admin SDK singleton; min instance if needed |
| Image URL breakage after migration | Migration script rewrites URLs; keep redirect map optional |
| Newspaper importer complexity | Migrate last; highest regression risk |
| Accidental public write exposure | Prefer Admin SDK on server; strict Firestore rules |

---

## 17. Decisions needed before starting

| # | Question | Recommendation |
|---|----------|----------------|
| 1 | Firestore vs Firebase Realtime Database | **Firestore** — fits document CMS model |
| 2 | Client Firestore writes vs API routes | **API routes + Admin SDK** for admin writes |
| 3 | R2 public URL | **Custom domain** `media.ysot.ng` |
| 4 | Admin allowlist | **`admins` collection** — do not allow all authenticated users |
| 5 | Keep Postgres locally during transition | **No** — dual-write adds complexity; migrate in a maintenance window |
| 6 | Categories as collection vs config doc | **Collection** — matches current CRUD |

---

## 18. Rollback plan

During migration, before cutover:

- Keep Supabase project active read-only for 2 weeks
- Export final Postgres snapshot before DNS/env switch
- Env flag `CMS_PROVIDER=supabase|firebase` only if you need gradual rollout (optional, adds cost)

After cutover:

- Rollback = revert deploy + restore Supabase env vars (data written during Firebase window may be lost unless synced back)

---

## 19. Cost notes (rough)

| Service | Expected usage | Notes |
|---------|----------------|-------|
| Firebase Auth | Free tier | Few admin logins |
| Firestore | Low | Small CMS; watch read counts on admin dashboard |
| Cloudflare R2 | Low | No egress fee to internet; storage pennies |
| Groq | Unchanged | Newspaper importer |

---

## 20. Success criteria

Migration is complete when:

1. No `@supabase/*` packages or env vars remain
2. All admin and public CMS features work on Firestore + R2
3. Existing content (articles, images, events) visible on production
4. `docs/supabase-to-firebase-cloudflare-handoff.md` checklist in §15 is green
5. README documents Firebase + R2 setup for new developers

---

## Appendix A — Example R2 upload route (sketch)

```javascript
// app/api/admin/uploads/route.js
import { NextResponse } from 'next/server';
import { requireAdmin } from '@/app/lib/db/auth';
import { uploadPublicFile, getPublicUrl } from '@/app/lib/storage/r2';
import { buildPublicImageKey } from '@/app/lib/storage/paths';

export async function POST(request) {
  await requireAdmin();
  const form = await request.formData();
  const file = form.get('file');
  const folder = form.get('folder') || 'articles';
  if (!file || typeof file === 'string') {
    return NextResponse.json({ error: 'Missing file' }, { status: 400 });
  }
  const buffer = Buffer.from(await file.arrayBuffer());
  const key = buildPublicImageKey(folder, file.name);
  await uploadPublicFile(buffer, key, file.type || 'application/octet-stream');
  return NextResponse.json({ publicUrl: getPublicUrl(key), key });
}
```

## Appendix B — Example Firestore article list (Admin SDK sketch)

```typescript
import { getFirestore } from 'firebase-admin/firestore';

export async function listArticles({ status = 'all' } = {}) {
  const db = getFirestore();
  let q = db.collection('articles').orderBy('createdAt', 'desc');
  if (status !== 'all') q = q.where('status', '==', status);
  const snap = await q.get();
  return snap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}
```

---

**Document owner:** Engineering  
**Next step:** Review §17 decisions, then begin Phase 0.
