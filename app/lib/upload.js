export async function uploadImage(file, prefix, ownerId = 'pending') {
  if (!file) return '';

  const formData = new FormData();
  formData.append('file', file);
  formData.append('prefix', prefix);
  formData.append('ownerId', ownerId);

  const response = await fetch('/api/admin/uploads', {
    method: 'POST',
    body: formData,
  });
  const data = await response.json();
  if (!response.ok) throw new Error(data.error || 'Upload failed.');
  return data.url;
}

export async function uploadFile(file, prefix, ownerId = 'pending') {
  if (!file) return null;

  const formData = new FormData();
  formData.append('file', file);
  formData.append('prefix', prefix);
  formData.append('ownerId', ownerId);

  const response = await fetch('/api/admin/uploads', {
    method: 'POST',
    body: formData,
  });
  const data = await response.json();
  if (!response.ok) throw new Error(data.error || 'Upload failed.');
  return data;
}
