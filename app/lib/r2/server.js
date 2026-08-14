import 'server-only';
import { DeleteObjectCommand, GetObjectCommand, PutObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

function requiredEnv(name) {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is not configured.`);
  return value;
}

export function r2Client() {
  return new S3Client({
    region: 'auto',
    endpoint: `https://${requiredEnv('CLOUDFLARE_ACCOUNT_ID')}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId: requiredEnv('R2_ACCESS_KEY_ID'),
      secretAccessKey: requiredEnv('R2_SECRET_ACCESS_KEY'),
    },
  });
}

export function r2Bucket() {
  return process.env.R2_BUCKET_NAME || 'ysot-media';
}

export function publicR2Url(key) {
  const base = requiredEnv('R2_PUBLIC_BASE_URL').replace(/\/$/, '');
  return `${base}/${key.split('/').map(encodeURIComponent).join('/')}`;
}

export function sanitizeFilename(name) {
  const clean = String(name || 'file')
    .toLowerCase()
    .replace(/[^a-z0-9.]+/g, '-')
    .replace(/(^-|-$)/g, '');
  return clean || 'file';
}

export async function uploadBufferToR2({ key, body, contentType }) {
  await r2Client().send(new PutObjectCommand({
    Bucket: r2Bucket(),
    Key: key,
    Body: body,
    ContentType: contentType || 'application/octet-stream',
    CacheControl: key.startsWith('newspapers/imports/')
      ? 'private, max-age=0'
      : 'public, max-age=31536000, immutable',
  }));
  return publicR2Url(key);
}

export async function getR2ObjectBuffer(key) {
  const result = await r2Client().send(new GetObjectCommand({
    Bucket: r2Bucket(),
    Key: key,
  }));
  return Buffer.from(await result.Body.transformToByteArray());
}

export async function deleteR2Object(key) {
  await r2Client().send(new DeleteObjectCommand({
    Bucket: r2Bucket(),
    Key: key,
  }));
}

export async function createR2SignedGetUrl(key, expiresIn = 600) {
  return getSignedUrl(
    r2Client(),
    new GetObjectCommand({ Bucket: r2Bucket(), Key: key }),
    { expiresIn }
  );
}
