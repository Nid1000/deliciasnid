"use client";
import React from "react";
import { usePathname } from "next/navigation";
import Footer from "@/components/Layout/Footer";
import CartSidebar from "@/components/Cart/CartSidebar";
import Navbar from "@/components/Layout/Navbar";
import { AnimatePresence, motion } from "framer-motion";

export default function ClientShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  // ✅ Evita hydration mismatch: no cambiar estructura antes de montar
  const [mounted, setMounted] = React.useState(false);
  React.useEffect(() => setMounted(true), []);

  // Mientras no monta, renderizamos algo estable (solo children)
  if (!mounted) return <>{children}</>;

  const isAdminRoute = pathname?.startsWith("/admin");

  // En rutas admin, ocultamos Footer y Cart.
  if (isAdminRoute) {
    return <div>{children}</div>;
  }

  return (
    <div>
      <Navbar />
      <CartSidebar />
      <main>
        <AnimatePresence mode="wait">
          <motion.div
            key={pathname}
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            transition={{ duration: 0.25, ease: "easeOut" }}
          >
            {children}
          </motion.div>
        </AnimatePresence>
      </main>
      <Footer />
    </div>
  );
}
