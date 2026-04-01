import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

// Rutas que requieren autenticación de usuario
const USER_PROTECTED = [
  "/profile",
  "/orders",
  "/checkout",
];

// Rutas que requieren rol admin
const ADMIN_PROTECTED_PREFIX = "/admin";
const ADMIN_LOGIN_PATH = "/admin/login";

export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  const token = req.cookies.get("token")?.value;
  const role = req.cookies.get("role")?.value; // ✅ NUEVO (si lo guardas)

  // Protege rutas de usuario
  if (USER_PROTECTED.includes(pathname)) {
    if (!token) {
      const url = req.nextUrl.clone();
      url.pathname = "/login";
      return NextResponse.redirect(url);
    }
  }

  // Protege rutas admin
  // Evitar bucle: permitir /admin/login
  if (pathname.startsWith(ADMIN_PROTECTED_PREFIX) && pathname !== ADMIN_LOGIN_PATH) {
    if (!token) {
      const url = req.nextUrl.clone();
      url.pathname = "/admin/login";
      return NextResponse.redirect(url);
    }

    // ✅ Si ya tienes role guardado, valida admin
    if (role && role !== "admin") {
      const url = req.nextUrl.clone();
      url.pathname = "/admin/login";
      return NextResponse.redirect(url);
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/profile",
    "/orders",
    "/checkout",
    "/admin/:path*",
  ],
};