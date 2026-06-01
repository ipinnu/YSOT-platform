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
