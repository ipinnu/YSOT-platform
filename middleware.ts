import { NextResponse, type NextRequest } from 'next/server';

const SESSION_COOKIE = '__session';

export function middleware(request: NextRequest) {
  const path = request.nextUrl.pathname;
  const isAdminRoute = path.startsWith('/admin') && path !== '/admin-login';
  const hasSession = Boolean(request.cookies.get(SESSION_COOKIE)?.value);

  if (isAdminRoute && !hasSession) {
    return NextResponse.redirect(new URL('/admin-login', request.url));
  }

  if (path === '/admin-login' && hasSession) {
    return NextResponse.redirect(new URL('/admin', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/admin/:path*', '/admin-login'],
};
