import { requireAdmin } from '../lib/auth/admin';

export const dynamic = 'force-dynamic';

export default async function AdminLayout({ children }) {
  await requireAdmin();
  return <>{children}</>;
}
