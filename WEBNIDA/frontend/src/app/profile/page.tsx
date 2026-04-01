"use client";
import React, { useEffect, useState } from "react";
import axios from "axios";
import Link from "next/link";
import { useAuth } from "@/context/AuthContext";

type Perfil = {
  id: number;
  nombre: string | null;
  apellido: string | null;
  email: string;
  telefono: string | null;
  direccion: string | null;
  distrito: string | null;
  numero_casa: string | null;
  created_at?: string;
};

type Distrito = { id: number; nombre: string };

export default function ProfilePage() {
  const { isAuthenticated, user, updateUser } = useAuth();
  const [perfil, setPerfil] = useState<Perfil | null>(null);
  const [distritos, setDistritos] = useState<Distrito[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [pwdSaving, setPwdSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [stats, setStats] = useState<{ total_pedidos: number; total_gastado: number } | null>(null);
  const [nombre, setNombre] = useState("");
  const [apellido, setApellido] = useState("");
  const [telefono, setTelefono] = useState("");
  const [direccion, setDireccion] = useState("");
  const [distrito, setDistrito] = useState("");
  const [numeroCasa, setNumeroCasa] = useState("");
  const [passwordActual, setPasswordActual] = useState("");
  const [passwordNueva, setPasswordNueva] = useState("");
  const [confirmarPassword, setConfirmarPassword] = useState("");

  useEffect(() => {
    const fetchData = async () => {
      if (!isAuthenticated()) {
        setLoading(false);
        return;
      }
      try {
        const [perfilRes, distritosRes, statsRes] = await Promise.all([
          axios.get("/api/usuarios/perfil"),
          axios.get("/api/usuarios/distritos-huancayo"),
          axios.get("/api/usuarios/estadisticas").catch(() => ({ data: {} })),
        ]);
        const p: Perfil = perfilRes.data.usuario;
        setPerfil(p);
        setNombre(p.nombre || "");
        setApellido(p.apellido || "");
        setTelefono(p.telefono || "");
        setDireccion(p.direccion || "");
        setDistrito(p.distrito || "");
        setNumeroCasa(p.numero_casa || "");
        setDistritos(Array.isArray(distritosRes.data?.distritos) ? distritosRes.data.distritos : []);
        const s = statsRes.data?.estadisticas;
        if (s) setStats({ total_pedidos: s.total_pedidos ?? 0, total_gastado: s.total_gastado ?? 0 });
      } catch (err: unknown) {
        const msg = axios.isAxiosError(err)
          ? ((err.response?.data as { message?: string; error?: string } | undefined)?.message || err.message)
          : "Error al cargar el perfil";
        setError(msg);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [isAuthenticated]);

  const handleGuardarPerfil = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setError(null);
    setSuccess(null);
    try {
      const body = {
        nombre,
        apellido,
        telefono,
        direccion,
        distrito,
        numero_casa: numeroCasa,
      };
      const res = await axios.put("/api/usuarios/perfil", body);
      const updated = res.data.usuario as Perfil;
      setPerfil(updated);
      setSuccess("Perfil actualizado correctamente");
      updateUser({ ...user, ...updated });
    } catch (err: unknown) {
      const msg = axios.isAxiosError(err)
        ? (((err.response?.data as { message?: string; error?: string } | undefined)?.message) || err.message)
        : "Error al guardar el perfil";
      setError(msg);
    } finally {
      setSaving(false);
    }
  };

  const handleCambiarPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setPwdSaving(true);
    setError(null);
    setSuccess(null);
    try {
      await axios.put("/api/usuarios/cambiar-password", { passwordActual, passwordNueva, confirmarPassword });
      setSuccess("Contraseña actualizada correctamente");
      setPasswordActual("");
      setPasswordNueva("");
      setConfirmarPassword("");
    } catch (err: unknown) {
      const msg = axios.isAxiosError(err)
        ? (((err.response?.data as { message?: string; error?: string } | undefined)?.message) || err.message)
        : "Error al cambiar la contraseña";
      setError(msg);
    } finally {
      setPwdSaving(false);
    }
  };

  if (!isAuthenticated()) {
    return <div className="max-w-4xl mx-auto p-6">Debes iniciar sesión. <Link href="/login" className="text-blue-600 underline">Ir al login</Link></div>;
  }
  if (loading) return <div className="max-w-4xl mx-auto p-6">Cargando perfil...</div>;

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">Mi perfil</h1>
        {stats && <p className="text-sm text-gray-600 mt-1">Pedidos: {stats.total_pedidos} · Total gastado: S/ {Number(stats.total_gastado || 0).toFixed(2)}</p>}
      </div>
      {error && <div className="rounded-md bg-red-100 text-red-700 px-4 py-2">{error}</div>}
      {success && <div className="rounded-md bg-green-100 text-green-700 px-4 py-2">{success}</div>}

      <form onSubmit={handleGuardarPerfil} className="bg-white border rounded-xl p-6 grid grid-cols-1 md:grid-cols-2 gap-4">
        <div><label className="block text-sm mb-1">Nombre</label><input value={nombre} onChange={(e) => setNombre(e.target.value)} className="w-full border rounded px-3 py-2" /></div>
        <div><label className="block text-sm mb-1">Apellido</label><input value={apellido} onChange={(e) => setApellido(e.target.value)} className="w-full border rounded px-3 py-2" /></div>
        <div><label className="block text-sm mb-1">Email</label><input value={perfil?.email || ""} disabled className="w-full border rounded px-3 py-2 bg-gray-100" /></div>
        <div><label className="block text-sm mb-1">Teléfono</label><input value={telefono} onChange={(e) => setTelefono(e.target.value.replace(/\D/g, "").slice(0, 9))} className="w-full border rounded px-3 py-2" /></div>
        <div className="md:col-span-2"><label className="block text-sm mb-1">Dirección</label><input value={direccion} onChange={(e) => setDireccion(e.target.value)} className="w-full border rounded px-3 py-2" /></div>
        <div><label className="block text-sm mb-1">Distrito</label><select value={distrito} onChange={(e) => setDistrito(e.target.value)} className="w-full border rounded px-3 py-2 bg-white"><option value="">Selecciona un distrito</option>{distritos.map((d) => <option key={d.id} value={d.nombre}>{d.nombre}</option>)}</select></div>
        <div><label className="block text-sm mb-1">Número de casa</label><input value={numeroCasa} onChange={(e) => setNumeroCasa(e.target.value)} className="w-full border rounded px-3 py-2" /></div>
        <div className="md:col-span-2"><button type="submit" disabled={saving} className="bg-black text-white px-4 py-2 rounded">{saving ? "Guardando..." : "Guardar perfil"}</button></div>
      </form>

      <form onSubmit={handleCambiarPassword} className="bg-white border rounded-xl p-6 grid grid-cols-1 md:grid-cols-3 gap-4">
        <div><label className="block text-sm mb-1">Contraseña actual</label><input type="password" value={passwordActual} onChange={(e) => setPasswordActual(e.target.value)} className="w-full border rounded px-3 py-2" /></div>
        <div><label className="block text-sm mb-1">Nueva contraseña</label><input type="password" value={passwordNueva} onChange={(e) => setPasswordNueva(e.target.value)} className="w-full border rounded px-3 py-2" /></div>
        <div><label className="block text-sm mb-1">Confirmar contraseña</label><input type="password" value={confirmarPassword} onChange={(e) => setConfirmarPassword(e.target.value)} className="w-full border rounded px-3 py-2" /></div>
        <div className="md:col-span-3"><button type="submit" disabled={pwdSaving} className="bg-gray-800 text-white px-4 py-2 rounded">{pwdSaving ? "Actualizando..." : "Cambiar contraseña"}</button></div>
      </form>
    </div>
  );
}
