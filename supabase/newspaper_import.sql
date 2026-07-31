-- Run this migration once in the Supabase SQL Editor before using the importer.

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
