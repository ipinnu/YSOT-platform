'use client';

import { useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '../../lib/supabase/client';

const MAX_PAGES = 40;
const MAX_FILE_BYTES = 100 * 1024 * 1024;
const ACCEPTED_TYPES = new Set(['application/pdf', 'image/jpeg', 'image/png']);

function canvasToJpeg(canvas, quality = 0.92) {
  return new Promise((resolve, reject) => {
    canvas.toBlob(
      (blob) => (blob ? resolve(blob) : reject(new Error('Could not render this page.'))),
      'image/jpeg',
      quality
    );
  });
}

async function normaliseImage(file) {
  const bitmap = await createImageBitmap(file);
  const maxSide = 3000;
  const scale = Math.min(1, maxSide / Math.max(bitmap.width, bitmap.height));
  const width = Math.max(1, Math.round(bitmap.width * scale));
  const height = Math.max(1, Math.round(bitmap.height * scale));
  const canvas = document.createElement('canvas');
  canvas.width = width;
  canvas.height = height;
  const context = canvas.getContext('2d', { alpha: false });
  context.fillStyle = '#ffffff';
  context.fillRect(0, 0, width, height);
  context.drawImage(bitmap, 0, 0, width, height);
  bitmap.close();
  return [await canvasToJpeg(canvas)];
}

async function renderPdf(file, onProgress) {
  const pdfjs = await import('pdfjs-dist/legacy/build/pdf.mjs');
  pdfjs.GlobalWorkerOptions.workerSrc = '/pdf.worker.min.mjs';

  const data = new Uint8Array(await file.arrayBuffer());
  const pdf = await pdfjs.getDocument({ data }).promise;
  if (pdf.numPages > MAX_PAGES) {
    throw new Error(`This importer currently accepts up to ${MAX_PAGES} pages at once.`);
  }

  const pages = [];
  for (let pageNumber = 1; pageNumber <= pdf.numPages; pageNumber += 1) {
    onProgress(`Rendering page ${pageNumber} of ${pdf.numPages}…`);
    const page = await pdf.getPage(pageNumber);
    const base = page.getViewport({ scale: 1 });
    const scale = Math.min(2.5, 2600 / Math.max(base.width, base.height));
    const viewport = page.getViewport({ scale });
    const canvas = document.createElement('canvas');
    canvas.width = Math.ceil(viewport.width);
    canvas.height = Math.ceil(viewport.height);
    const context = canvas.getContext('2d', { alpha: false });
    context.fillStyle = '#ffffff';
    context.fillRect(0, 0, canvas.width, canvas.height);
    await page.render({ canvasContext: context, viewport }).promise;
    pages.push(await canvasToJpeg(canvas));
    page.cleanup();
  }
  await pdf.destroy();
  return pages;
}

export default function NewspaperImporter() {
  const router = useRouter();
  const inputRef = useRef(null);
  const previewUrlsRef = useRef([]);
  const [file, setFile] = useState(null);
  const [pages, setPages] = useState([]);
  const [jobId, setJobId] = useState('');
  const [stage, setStage] = useState('Choose a newspaper to begin.');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [result, setResult] = useState(null);

  useEffect(() => {
    return () => previewUrlsRef.current.forEach((url) => URL.revokeObjectURL(url));
  }, []);

  async function selectFile(event) {
    const selected = event.target.files?.[0];
    if (!selected) return;

    setError('');
    setResult(null);
    setFile(null);
    previewUrlsRef.current.forEach((url) => URL.revokeObjectURL(url));
    previewUrlsRef.current = [];
    setPages([]);

    if (!ACCEPTED_TYPES.has(selected.type)) {
      setError('Choose a PDF, JPG, or PNG newspaper file.');
      return;
    }
    if (selected.size > MAX_FILE_BYTES) {
      setError('The newspaper must be 100 MB or smaller.');
      return;
    }

    setBusy(true);
    try {
      setStage(selected.type === 'application/pdf' ? 'Opening PDF…' : 'Preparing image…');
      const rendered = selected.type === 'application/pdf'
        ? await renderPdf(selected, setStage)
        : await normaliseImage(selected);
      const prepared = rendered.map((blob, index) => ({
        page: index + 1,
        blob,
        preview: URL.createObjectURL(blob),
      }));
      previewUrlsRef.current = prepared.map((page) => page.preview);
      setFile(selected);
      setPages(prepared);
      setJobId(crypto.randomUUID());
      setStage(`${prepared.length} page${prepared.length === 1 ? '' : 's'} ready to import.`);
    } catch (err) {
      setError(err.message || 'Could not open this newspaper.');
      setStage('Choose another newspaper to try again.');
    } finally {
      setBusy(false);
    }
  }

  async function uploadPages(supabase, userId) {
    const uploaded = [];
    for (let index = 0; index < pages.length; index += 1) {
      setStage(`Uploading page ${index + 1} of ${pages.length}…`);
      const path = `${userId}/${jobId}/page-${String(index + 1).padStart(3, '0')}.jpg`;
      const { error: uploadError } = await supabase.storage
        .from('newspaper-imports')
        .upload(path, pages[index].blob, {
          contentType: 'image/jpeg',
          cacheControl: '3600',
          upsert: true,
        });
      if (uploadError) throw uploadError;
      uploaded.push({ page: index + 1, path });
    }
    return uploaded;
  }

  async function importNewspaper() {
    if (!file || pages.length === 0 || busy) return;
    setBusy(true);
    setError('');
    setResult(null);

    try {
      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Your admin session has expired. Please sign in again.');

      const uploadedPages = await uploadPages(supabase, user.id);
      const pageResults = [];
      const batches = Math.ceil(uploadedPages.length / 3);

      for (let start = 0; start < uploadedPages.length; start += 3) {
        const batchNumber = Math.floor(start / 3) + 1;
        setStage(`Reading newspaper batch ${batchNumber} of ${batches}…`);
        const response = await fetch('/api/admin/newspapers/analyze', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ pages: uploadedPages.slice(start, start + 3) }),
        });
        const data = await response.json();
        if (!response.ok) throw new Error(data.error || 'A page batch could not be read.');
        pageResults.push(...(data.pages || []));
      }

      setStage('Assembling articles and cropping photographs…');
      const finalResponse = await fetch('/api/admin/newspapers/finalize', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ pageResults, uploadedPages }),
      });
      const finalData = await finalResponse.json();
      if (!finalResponse.ok) {
        throw new Error(finalData.error || 'The article drafts could not be created.');
      }

      setResult(finalData.articles || []);
      setStage(`${finalData.articles?.length || 0} article drafts created.`);
      router.refresh();
    } catch (err) {
      setError(err.message || 'The newspaper import failed. You can safely retry it.');
      setStage('Import paused.');
    } finally {
      setBusy(false);
    }
  }

  function reset() {
    previewUrlsRef.current.forEach((url) => URL.revokeObjectURL(url));
    previewUrlsRef.current = [];
    setFile(null);
    setPages([]);
    setJobId('');
    setResult(null);
    setError('');
    setStage('Choose a newspaper to begin.');
    if (inputRef.current) inputRef.current.value = '';
  }

  return (
    <div className="newspaper-importer">
      <div className="newspaper-dropzone">
        <div className="newspaper-drop-icon" aria-hidden="true">N</div>
        <div>
          <h2>Upload a newspaper</h2>
          <p>
            PDF, JPG, or PNG · up to {MAX_PAGES} pages · imported as unpublished drafts
          </p>
        </div>
        <label className="primary newspaper-file-button">
          Choose file
          <input
            ref={inputRef}
            type="file"
            accept=".pdf,image/jpeg,image/png"
            onChange={selectFile}
            disabled={busy}
          />
        </label>
      </div>

      {file && pages.length > 0 && (
        <div className="newspaper-ready-card">
          <div className="newspaper-preview">
            <img src={pages[0].preview} alt="First newspaper page preview" />
            {pages.length > 1 && <span>+{pages.length - 1} pages</span>}
          </div>
          <div className="newspaper-ready-copy">
            <span className="newspaper-kicker">Ready for editorial import</span>
            <h3>{file.name}</h3>
            <p>
              Groq will transcribe the pages, join continued stories, classify each
              article, and crop matching photographs from the original newspaper.
            </p>
          </div>
        </div>
      )}

      <div className="newspaper-progress" aria-live="polite">
        <span className={busy ? 'newspaper-spinner active' : 'newspaper-spinner'} />
        <span>{stage}</span>
      </div>

      {error && <p className="form-error">{error}</p>}

      {result && (
        <div className="newspaper-result">
          <strong>Drafts are ready for review</strong>
          <p>Nothing has been published. Open any draft from the dashboard to verify it.</p>
          <div className="newspaper-result-links">
            {result.slice(0, 8).map((article) => (
              <a key={article.id} href={`/admin/articles/${article.id}/edit`}>
                {article.title}
              </a>
            ))}
          </div>
        </div>
      )}

      <div className="form-actions newspaper-actions">
        <button
          type="button"
          className="primary"
          disabled={!file || pages.length === 0 || busy || Boolean(result)}
          onClick={importNewspaper}
        >
          {busy ? 'Processing…' : 'Convert to article drafts'}
        </button>
        {(file || result) && (
          <button type="button" className="secondary" disabled={busy} onClick={reset}>
            Import another
          </button>
        )}
      </div>
    </div>
  );
}
