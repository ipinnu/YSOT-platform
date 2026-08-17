-- ============================================================
-- YSoT Platform — Supabase Schema
-- Run this in the Supabase SQL Editor to set up your database
-- ============================================================

-- Authors
CREATE TABLE IF NOT EXISTS authors (
  id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT          NOT NULL,
  description TEXT          DEFAULT '',
  image_url   TEXT          DEFAULT '',
  created_at  TIMESTAMPTZ   DEFAULT NOW()
);

-- Categories
CREATE TABLE IF NOT EXISTS categories (
  id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT          NOT NULL UNIQUE,
  created_at  TIMESTAMPTZ   DEFAULT NOW()
);

-- Seed default categories
INSERT INTO categories (name) VALUES
  ('Governance'),
  ('Economy'),
  ('Education'),
  ('Security'),
  ('Institutions'),
  ('Culture'),
  ('National Cohesion'),
  ('Economic Policy'),
  ('Public Finance'),
  ('General')
ON CONFLICT (name) DO NOTHING;

-- Articles
CREATE TABLE IF NOT EXISTS articles (
  id           UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  slug         TEXT          UNIQUE NOT NULL,
  title        TEXT          NOT NULL,
  excerpt      TEXT          DEFAULT '',
  content      JSONB         DEFAULT '[]',
  author_id    UUID          REFERENCES authors(id) ON DELETE SET NULL,
  author       TEXT          DEFAULT '',
  author_bio   TEXT          DEFAULT '',
  category     TEXT          DEFAULT 'General',
  image_url    TEXT          DEFAULT '',
  read_time    TEXT          DEFAULT '5 min read',
  featured     BOOLEAN       DEFAULT false,
  status       TEXT          DEFAULT 'draft'
                             CHECK (status IN ('draft', 'published')),
  published_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ   DEFAULT NOW(),
  updated_at   TIMESTAMPTZ   DEFAULT NOW()
);

-- Auto-update updated_at on row changes
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER articles_updated_at
  BEFORE UPDATE ON articles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Row Level Security — articles
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read published articles" ON articles;
DROP POLICY IF EXISTS "Admins full access" ON articles;
CREATE POLICY "Public read published articles"
  ON articles FOR SELECT
  USING (status = 'published');

CREATE POLICY "Admins full access"
  ON articles FOR ALL
  USING (auth.role() = 'authenticated');

-- Row Level Security — authors
ALTER TABLE authors ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read authors" ON authors;
DROP POLICY IF EXISTS "Admins manage authors" ON authors;
CREATE POLICY "Public read authors"
  ON authors FOR SELECT
  USING (true);

CREATE POLICY "Admins manage authors"
  ON authors FOR ALL
  USING (auth.role() = 'authenticated');

-- Row Level Security — categories
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read categories" ON categories;
DROP POLICY IF EXISTS "Admins manage categories" ON categories;
CREATE POLICY "Public read categories"
  ON categories FOR SELECT
  USING (true);

CREATE POLICY "Admins manage categories"
  ON categories FOR ALL
  USING (auth.role() = 'authenticated');

-- ============================================================
-- Storage bucket for article images
-- ============================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('article-images', 'article-images', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public read images" ON storage.objects;
DROP POLICY IF EXISTS "Admins upload images" ON storage.objects;
DROP POLICY IF EXISTS "Admins update images" ON storage.objects;
DROP POLICY IF EXISTS "Admins delete images" ON storage.objects;
CREATE POLICY "Public read images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'article-images');

CREATE POLICY "Admins upload images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'article-images' AND auth.role() = 'authenticated');

CREATE POLICY "Admins update images"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'article-images' AND auth.role() = 'authenticated');

CREATE POLICY "Admins delete images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'article-images' AND auth.role() = 'authenticated');

-- ============================================================
-- Private temporary newspaper pages
-- Pages are deleted automatically after drafts are created.
-- ============================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'newspaper-imports',
  'newspaper-imports',
  false,
  10485760,
  ARRAY['image/jpeg', 'image/png']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Admins read own newspaper pages" ON storage.objects;
DROP POLICY IF EXISTS "Admins upload own newspaper pages" ON storage.objects;
DROP POLICY IF EXISTS "Admins update own newspaper pages" ON storage.objects;
DROP POLICY IF EXISTS "Admins delete own newspaper pages" ON storage.objects;

CREATE POLICY "Admins read own newspaper pages"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'newspaper-imports'
    AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
  );

CREATE POLICY "Admins upload own newspaper pages"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'newspaper-imports'
    AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
  );

CREATE POLICY "Admins update own newspaper pages"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'newspaper-imports'
    AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
  )
  WITH CHECK (
    bucket_id = 'newspaper-imports'
    AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
  );

CREATE POLICY "Admins delete own newspaper pages"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'newspaper-imports'
    AND (storage.foldername(name))[1] = (SELECT auth.uid()::text)
  );

-- ============================================================
-- Gallery
-- ============================================================

CREATE TABLE IF NOT EXISTS gallery_items (
  id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  alt         TEXT          NOT NULL DEFAULT '',
  image_url   TEXT          NOT NULL,
  sort_order  INTEGER       DEFAULT 0,
  published   BOOLEAN       DEFAULT true,
  created_at  TIMESTAMPTZ   DEFAULT NOW()
);

ALTER TABLE gallery_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read published gallery" ON gallery_items;
DROP POLICY IF EXISTS "Admins manage gallery" ON gallery_items;
CREATE POLICY "Public read published gallery"
  ON gallery_items FOR SELECT
  USING (published = true);

CREATE POLICY "Admins manage gallery"
  ON gallery_items FOR ALL
  USING (auth.role() = 'authenticated');

-- ============================================================
-- Events
-- ============================================================

CREATE TABLE IF NOT EXISTS events (
  id                 UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  title              TEXT          NOT NULL,
  description        TEXT          DEFAULT '',
  location           TEXT          DEFAULT '',
  format             TEXT          DEFAULT 'Forum',
  event_date         DATE          NOT NULL,
  status             TEXT          DEFAULT 'upcoming'
                                   CHECK (status IN ('upcoming', 'past')),
  image_url          TEXT          DEFAULT '',
  recap_image_url    TEXT          DEFAULT '',
  recap_title        TEXT          DEFAULT '',
  recap_description  TEXT          DEFAULT '',
  published          BOOLEAN       DEFAULT true,
  sort_order         INTEGER       DEFAULT 0,
  created_at         TIMESTAMPTZ   DEFAULT NOW(),
  updated_at         TIMESTAMPTZ   DEFAULT NOW()
);

CREATE OR REPLACE TRIGGER events_updated_at
  BEFORE UPDATE ON events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

ALTER TABLE events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read published events" ON events;
DROP POLICY IF EXISTS "Admins manage events" ON events;
CREATE POLICY "Public read published events"
  ON events FOR SELECT
  USING (published = true);

CREATE POLICY "Admins manage events"
  ON events FOR ALL
  USING (auth.role() = 'authenticated');

-- Seed default events when the table is empty (matches original static page content)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM events LIMIT 1) THEN
    INSERT INTO events (title, description, location, format, event_date, status, recap_title, recap_description, sort_order)
    VALUES
      (
        'Inaugural Webinar: Voices of Change',
        'An evening of policy debate featuring Prof. Francis Egbokhare, Dr. Richard Ikiebe, and the YSoT leadership team.',
        'Online',
        'Webinar',
        '2025-05-24',
        'past',
        'Who is Thinking for Nigeria?',
        'YSoT opened with a candid conversation on Nigeria''s leadership gaps, featuring Ogie Eboigbe, Oyinkan Teriba, Prof. Francis Egbokhare, and Dr. Richard Ikiebe. The session mapped practical reforms, civic responsibility, and the power of ideas in rebuilding trust.',
        1
      ),
      (
        'Policy Roundtable: Lagos Innovation Corridor',
        'A closed-door session exploring governance reforms that can unlock investment across Yaba and the mainland.',
        'Yaba, Lagos',
        'Roundtable',
        '2025-06-17',
        'past',
        '',
        '',
        2
      ),
      (
        'Youth Thought Lab',
        'Emerging scholars share research briefs on education, security, and social order.',
        'Yaba, Lagos',
        'Workshop',
        '2025-07-02',
        'past',
        '',
        '',
        3
      ),
      (
        'Future of Cities Dialogue',
        'An interdisciplinary panel on housing, transit, and urban inclusion in fast-growing Nigerian cities.',
        'Civic House, Yaba',
        'Forum',
        '2026-03-14',
        'upcoming',
        '',
        '',
        4
      ),
      (
        'Public Finance Reset',
        'Policy leaders and researchers map reforms to strengthen public budgeting and fiscal trust.',
        'Online',
        'Webinar',
        '2026-04-09',
        'upcoming',
        '',
        '',
        5
      );
  END IF;
END $$;
