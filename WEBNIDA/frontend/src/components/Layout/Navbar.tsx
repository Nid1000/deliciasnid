"use client";
import Link from "next/link";
import Image from "next/image";
import { useAuth } from "@/context/AuthContext";
import { useCart } from "@/context/CartContext";
import { useEffect, useRef, useState } from "react";
import { usePathname, useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { ShoppingCart, Menu, X, Phone, Truck, Search, Wheat, Bell } from "lucide-react";
import SearchSuggest from "@/components/Product/SearchSuggest";
import axios from "axios";
import { toast } from "react-hot-toast";
import ThemeToggle from "./ThemeToggle";

type CategoriaNavbar = { id: number; nombre: string };
type NotificationItem = { id: number; title: string; body: string; route: string; targetId: string };
type NotificationApiItem = Partial<{
  id: number | string;
  title: string;
  titulo: string;
  body: string;
  mensaje: string;
  route: string;
  targetId: string | number;
}>;

const normalizeCategorias = (payload: unknown): CategoriaNavbar[] => {
  if (Array.isArray(payload)) return payload as CategoriaNavbar[];
  if (payload && typeof payload === "object") {
    const record = payload as { categorias?: unknown; data?: unknown };
    if (Array.isArray(record.categorias)) return record.categorias as CategoriaNavbar[];
    if (Array.isArray(record.data)) return record.data as CategoriaNavbar[];
    if (record.data && typeof record.data === "object") {
      const nested = record.data as { categorias?: unknown };
      if (Array.isArray(nested.categorias)) return nested.categorias as CategoriaNavbar[];
    }
  }
  return [];
};

const deriveCategoriasFromProductos = (payload: unknown): CategoriaNavbar[] => {
  const data =
    payload && typeof payload === "object" && Array.isArray((payload as { productos?: unknown }).productos)
      ? ((payload as { productos: Array<{ categoria_id?: number; categoria_nombre?: string | null }> }).productos ?? [])
      : [];

  const map = new Map<number, CategoriaNavbar>();
  for (const item of data) {
    const id = Number(item.categoria_id);
    const nombre = String(item.categoria_nombre ?? "").trim();
    if (Number.isFinite(id) && id > 0 && nombre) {
      map.set(id, { id, nombre });
    }
  }

  return Array.from(map.values()).sort((a, b) => a.nombre.localeCompare(b.nombre));
};

export default function Navbar() {
  const { isAuthenticated, isAdmin, logout, user } = useAuth();
  const { getCartItemsCount, openCart } = useCart();
  const pathname = usePathname();
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const [search, setSearch] = useState("");
  const [categorias, setCategorias] = useState<CategoriaNavbar[]>([]);
  const [notificationsOpen, setNotificationsOpen] = useState(false);
  const [notifications, setNotifications] = useState<NotificationItem[]>([]);
  const shownToastIdsRef = useRef<Set<number>>(new Set());

  // Cierra el menú al cambiar de ruta
  useEffect(() => {
    setOpen(false);
  }, [pathname]);

  useEffect(() => {
    const onScroll = () => setIsScrolled(window.scrollY > 8);
    onScroll();
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  // Cargar categorías para la barra secundaria
  useEffect(() => {
    const loadCategorias = async () => {
      try {
        const res = await axios.get("/api/categorias");
        const categoriasNormalizadas = normalizeCategorias(res.data);
        if (categoriasNormalizadas.length > 0) {
          setCategorias(categoriasNormalizadas);
          return;
        }

        const productosRes = await axios.get("/api/productos?limite=100");
        setCategorias(deriveCategoriasFromProductos(productosRes.data));
      } catch {
        // Silenciar error en navbar; la tienda sigue funcionando aunque no cargue la barra de categorías
        console.debug("Navbar: no se pudieron cargar categorías");
      }
    };
    loadCategorias();
  }, []);

  useEffect(() => {
    if (!isAuthenticated()) {
      setNotifications([]);
      shownToastIdsRef.current.clear();
      return;
    }

    const loadNotifications = async () => {
      try {
        const res = await axios.get("/api/notificaciones/pendientes", {
          params: { canal: "web" },
        });
        const items: NotificationApiItem[] = Array.isArray(res.data?.notificaciones)
          ? (res.data.notificaciones as NotificationApiItem[])
          : [];
        const normalized: NotificationItem[] = items.map((item) => ({
          id: Number(item.id || 0),
          title: String(item.title || item.titulo || "Mensaje"),
          body: String(item.body || item.mensaje || ""),
          route: String(item.route || ""),
          targetId: String(item.targetId ?? ""),
        }));

        setNotifications(normalized);

        for (const item of normalized) {
          if (item.id <= 0 || shownToastIdsRef.current.has(item.id)) continue;
          shownToastIdsRef.current.add(item.id);
          toast.success(`${item.title}: ${item.body}`, {
            duration: 6000,
            id: `web-notification-${item.id}`,
          });
        }
      } catch {}
    };

    loadNotifications();
    const timer = window.setInterval(loadNotifications, 20000);
    return () => window.clearInterval(timer);
  }, [isAuthenticated]);

  const cartCount = getCartItemsCount();

  const onSearchSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const q = search.trim();
    const url = q ? `/products?buscar=${encodeURIComponent(q)}` : "/products";
    router.push(url);
    setOpen(false);
  };

  const openNotification = async (item: { id: number; route: string; targetId: string }) => {
    try {
      await axios.post("/api/notificaciones/marcar-mostradas", {
        ids: [item.id],
        canal: "web",
      });
    } catch {}

    setNotifications((current) => current.filter((entry) => entry.id !== item.id));
    setNotificationsOpen(false);

    if (item.route === "store") {
      router.push("/products");
      return;
    }

    if (item.route === "order") {
      router.push("/orders");
    }
  };

  // Alturas del header fijo (px)
  const TOPBAR_H = 36; // h-9
  const NAV_H = 64;    // h-16
  const CATEGORIES_H = categorias.length > 0 ? 48 : 0; // h-12 si hay categorías
  const headerOffset = TOPBAR_H + NAV_H + CATEGORIES_H;

  return (
    <>
    <header role="navigation" aria-label="Barra principal" className="navbar">
      {/* Top bar informativa */}
      <div className="bg-white/90 border-b border-black/10">
        <div className="container h-9 flex items-center justify-between text-xs">
          <div className="flex items-center gap-3 text-black/70">
            <span className="inline-flex items-center gap-1"><Truck size={14} /> Envío gratis en compras desde S/ 80</span>
            <span className="hidden sm:inline-block">|</span>
            <a href="tel:993560096" className="inline-flex items-center gap-1 hover:text-black"><Phone size={14} /> 993560096</a>
          </div>
          <div className="flex items-center gap-3 text-black/70">
            <Link href="/#contacto" className="hover:text-black">Contáctanos</Link>
            <Link href="/checkout" className="hover:text-black">Ordenar ahora</Link>
          </div>
        </div>
      </div>
      <motion.nav
        initial={{ y: -20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.5, ease: "easeOut" }}
        className={`navbar-inner ${isScrolled ? "navbar-blur" : ""}`}
      >
        {/* Logo */}
        <div className="flex items-center gap-3">
          <Link href="/" className="flex items-center gap-2">
            <Image src="/images/logos/logo 1.png" alt="Delicias" width={40} height={40} />
            <span className="font-semibold text-[var(--color-secondary)]">Delicias</span>
          </Link>
        </div>

        {/* Desktop nav */}
        <div className="hidden md:flex items-center gap-6">
          <nav aria-label="Navegación principal" className="flex items-center gap-6">
            <Link href="/" className="text-sm hover:text-[var(--color-secondary)]">Inicio</Link>
            <Link href="/products" className="text-sm hover:text-[var(--color-secondary)]">Menú</Link>
            <Link href="/historial" className="text-sm hover:text-[var(--color-secondary)]">Historial</Link>
            <Link href="/#nosotros" className="text-sm hover:text-[var(--color-secondary)]">Nosotros</Link>
            <Link href="/#contacto" className="text-sm hover:text-[var(--color-secondary)]">Contáctanos</Link>
            {isAdmin() && (
              <Link href="/admin" className="text-sm text-black/70 hover:text-black">Admin</Link>
            )}
          </nav>
          {/* Buscador */}
          <form onSubmit={onSearchSubmit} className="relative w-64">
            <label htmlFor="navbar-search" className="sr-only">Buscar en la tienda</label>
            <SearchSuggest
              value={search}
              onChange={(v) => setSearch(v)}
              onSelect={(s) => {
                const q = s?.nombre?.trim() || "";
                const url = q ? `/products?buscar=${encodeURIComponent(q)}` : "/products";
                router.push(url);
                setOpen(false);
              }}
              placeholder="Buscar productos..."
            />
            <button type="submit" aria-label="Buscar" className="absolute right-1 top-1.5 rounded-lg p-1.5 text-black/70 hover:text-black">
              <Search size={16} />
            </button>
          </form>
          <Link href="/checkout" className="btn btn-primary">Ordenar Ahora</Link>
        </div>

        {/* Acciones */}
        <div className="flex items-center gap-3">
          <button type="button" onClick={openCart} aria-label="Abrir carrito" className="relative inline-flex items-center justify-center rounded-xl p-2 hover:bg-black/5">
            <ShoppingCart size={20} />
            {cartCount > 0 && (
              <span className="absolute -top-1 -right-1 rounded-full bg-[var(--color-primary)] text-white text-[10px] px-1.5 py-0.5">
                {cartCount}
              </span>
            )}
          </button>

          {isAuthenticated() && (
            <div className="relative">
              <button
                type="button"
                onClick={() => setNotificationsOpen((value) => !value)}
                aria-label="Abrir mensajes"
                className="relative inline-flex items-center justify-center rounded-xl p-2 hover:bg-black/5"
              >
                <Bell size={20} />
                {notifications.length > 0 && (
                  <span className="absolute -top-1 -right-1 rounded-full bg-[var(--color-primary)] text-white text-[10px] px-1.5 py-0.5">
                    {notifications.length}
                  </span>
                )}
              </button>
              {notificationsOpen && (
                <div className="absolute right-0 top-12 z-50 w-80 rounded-2xl border border-black/10 bg-white p-3 shadow-xl">
                  <div className="mb-2 text-sm font-semibold text-slate-900">Mensajes</div>
                  {notifications.length === 0 ? (
                    <div className="text-sm text-slate-500">No tienes mensajes nuevos.</div>
                  ) : (
                    <div className="space-y-2">
                      {notifications.map((item) => (
                        <button
                          key={item.id}
                          type="button"
                          onClick={() => openNotification(item)}
                          className="w-full rounded-xl border border-slate-200 p-3 text-left hover:bg-slate-50"
                        >
                          <div className="text-sm font-semibold text-slate-900">{item.title}</div>
                          <div className="mt-1 text-sm text-slate-600">{item.body}</div>
                        </button>
                      ))}
                    </div>
                  )}
                </div>
              )}
            </div>
          )}

          {/* Theme toggle */}
          <ThemeToggle />

          {/* Auth */}
          {isAuthenticated() ? (
            <div className="hidden sm:flex items-center gap-2">
              <Link href="/profile" className="inline-flex items-center gap-2">
                {user?.avatar ? (
                  <Image src={user.avatar} alt="Perfil" width={28} height={28} className="rounded-full border border-black/10" />
                ) : (
                  <span className="inline-flex items-center justify-center w-7 h-7 rounded-full bg-black/5 text-xs font-medium">
                    {(user?.nombre || user?.email || "?")[0]?.toUpperCase()}
                  </span>
                )}
                <span className="text-sm hover:text-[var(--color-secondary)]">{user?.nombre || user?.email || "Perfil"}</span>
              </Link>
              <button onClick={logout} className="text-sm text-black/70 hover:text-black">Salir</button>
            </div>
          ) : (
            <div className="hidden sm:flex items-center gap-2">
              <Link href="/login" className="text-sm hover:text-[var(--color-secondary)]">Entrar</Link>
              <Link href="/register" className="text-sm hover:text-[var(--color-secondary)]">Registro</Link>
            </div>
          )}

          {/* Mobile toggle */}
          <button aria-label="Abrir menú" aria-expanded={open} onClick={() => setOpen(v => !v)} className="md:hidden rounded-xl p-2 hover:bg-black/5">
            {open ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>
      </motion.nav>

      {/* Barra secundaria de categorías */}
      {categorias.length > 0 && (
        <div className="bg-white/90 border-b border-black/10">
          <div className="container h-12 flex items-center gap-4 overflow-x-auto">
            {categorias.map((c) => (
              <Link key={c.id} href={`/products?categoria=${c.id}`} className="inline-flex items-center gap-2 px-3 py-1.5 rounded-xl border border-gray-200 bg-white text-sm text-black/80 hover:border-gray-400 whitespace-nowrap">
                <Wheat size={16} /> {c.nombre}
              </Link>
            ))}
          </div>
        </div>
      )}

      {/* Mobile menu */}
      {open && (
        <motion.div
          initial={{ height: 0, opacity: 0 }}
          animate={{ height: "auto", opacity: 1 }}
          exit={{ height: 0, opacity: 0 }}
          className="md:hidden bg-white/80 backdrop-blur-md shadow-sm"
        >
          <div className="container py-3 grid grid-cols-2 gap-3">
            {/* Buscador móvil */}

            <form onSubmit={onSearchSubmit} className="col-span-2 relative">
              <label htmlFor="navbar-search-mobile" className="sr-only">Buscar en la tienda</label>
              <SearchSuggest
                value={search}
                onChange={(v) => setSearch(v)}
                onSelect={(s) => {
                  const q = s?.nombre?.trim() || "";
                  const url = q ? `/products?buscar=${encodeURIComponent(q)}` : "/products";
                  router.push(url);
                  setOpen(false);
                }}
                placeholder="Buscar productos..."
              />
              <button type="submit" aria-label="Buscar" className="absolute right-1 top-1.5 rounded-lg p-1.5 text-black/70 hover:text-black">
                <Search size={16} />
              </button>
            </form>
            <Link href="/" className="text-sm">Inicio</Link>
            <Link href="/products" className="text-sm">Menú</Link>
            <Link href="/historial" className="text-sm">Historial</Link>
            <Link href="/#nosotros" className="text-sm">Nosotros</Link>
            <Link href="/#contacto" className="text-sm">Contáctanos</Link>
            {isAdmin() && <Link href="/admin" className="text-sm">Admin</Link>}
            <Link href="/checkout" className="btn btn-primary col-span-2">Ordenar Ahora</Link>
            <button type="button" onClick={openCart} className="btn btn-outline-secondary col-span-2" aria-label="Abrir carrito">
              Abrir Carrito ({cartCount})
            </button>
            <div className="col-span-2">
              <ThemeToggle />
            </div>
            <div className="col-span-2 flex items-center gap-3">
              {isAuthenticated() ? (
                <>
                  <Link href="/profile" className="text-sm">{user?.nombre || user?.email || "Perfil"}</Link>
                  <button onClick={logout} className="text-sm">Cerrar sesión</button>
                </>
              ) : (
                <>
                  <Link href="/login" className="text-sm">Iniciar sesión</Link>
                  <Link href="/register" className="text-sm">Registrarse</Link>
                </>
              )}
            </div>
            {/* Categorías móviles */}
            {categorias.length > 0 && (
              <div className="col-span-2 flex items-center gap-2 overflow-x-auto">
                {categorias.map((c) => (
                  <Link key={c.id} href={`/products?categoria=${c.id}`} className="inline-flex items-center gap-2 px-2.5 py-1.5 rounded-xl border border-gray-200 bg-white text-sm text-black/80 whitespace-nowrap">
                    <Wheat size={16} /> {c.nombre}
                  </Link>
                ))}
              </div>
            )}
          </div>
        </motion.div>
      )}
    </header>
    {/* Spacer para que el contenido no quede debajo del header fijo */}
    <div aria-hidden className="pointer-events-none" style={{ height: headerOffset }} />
    </>
  );
}
