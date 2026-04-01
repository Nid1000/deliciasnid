"use client";
import React, { useEffect, useState } from "react";
import axios from "axios";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/AuthContext";

type Distrito = { id: number; nombre: string };

export default function RegisterPage() {
  const router = useRouter();
  const { register } = useAuth();

  const [nombre, setNombre] = useState("");
  const [apellido, setApellido] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [telefono, setTelefono] = useState("");
  const [direccion, setDireccion] = useState("");
  const [distrito, setDistrito] = useState("");
  const [numeroCasa, setNumeroCasa] = useState("");
  const [distritos, setDistritos] = useState<Distrito[]>([]);
  const [loading, setLoading] = useState(false);
  const [loadingDistritos, setLoadingDistritos] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadDistritos = async () => {
      try {
        const res = await axios.get("/api/usuarios/distritos-huancayo");
        setDistritos(Array.isArray(res.data?.distritos) ? res.data.distritos : []);
      } catch {
        setError("No se pudieron cargar los distritos de Huancayo");
      } finally {
        setLoadingDistritos(false);
      }
    };
    loadDistritos();
  }, []);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    const res = await register({
      nombre,
      apellido,
      email,
      password,
      telefono,
      direccion,
      distrito,
      numero_casa: numeroCasa,
    });
    setLoading(false);
    if (res.success) router.push("/");
    else setError(res.error || "Error al registrarse");
  };

  return (
    <div className="max-w-lg mx-auto w-full mt-10 p-6 border rounded-lg bg-white shadow-sm">
      <h1 className="text-2xl font-semibold mb-4">Registrarse</h1>
      {error && <div className="mb-4 p-3 rounded bg-red-100 text-red-700 text-sm">{error}</div>}

      <form onSubmit={onSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium mb-1">Nombre</label>
          <input type="text" value={nombre} onChange={(e) => setNombre(e.target.value)} required className="w-full border rounded px-3 py-2" />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Apellido</label>
          <input type="text" value={apellido} onChange={(e) => setApellido(e.target.value)} required className="w-full border rounded px-3 py-2" />
        </div>
        <div className="md:col-span-2">
          <label className="block text-sm font-medium mb-1">Email</label>
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required className="w-full border rounded px-3 py-2" />
        </div>
        <div className="md:col-span-2">
          <label className="block text-sm font-medium mb-1">Contraseña</label>
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required className="w-full border rounded px-3 py-2" />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Teléfono</label>
          <input type="tel" value={telefono} onChange={(e) => setTelefono(e.target.value.replace(/\D/g, "").slice(0, 9))} className="w-full border rounded px-3 py-2" placeholder="987654321" />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Número de casa</label>
          <input type="text" value={numeroCasa} onChange={(e) => setNumeroCasa(e.target.value)} className="w-full border rounded px-3 py-2" placeholder="Ej: 350" required />
        </div>
        <div className="md:col-span-2">
          <label className="block text-sm font-medium mb-1">Dirección</label>
          <input type="text" value={direccion} onChange={(e) => setDireccion(e.target.value)} className="w-full border rounded px-3 py-2" placeholder="Av. / Jr. / Calle" required />
        </div>
        <div className="md:col-span-2">
          <label className="block text-sm font-medium mb-1">Distrito</label>
          <select value={distrito} onChange={(e) => setDistrito(e.target.value)} className="w-full border rounded px-3 py-2 bg-white" required disabled={loadingDistritos}>
            <option value="">{loadingDistritos ? "Cargando distritos..." : "Selecciona un distrito"}</option>
            {distritos.map((item) => (
              <option key={item.id} value={item.nombre}>{item.nombre}</option>
            ))}
          </select>
        </div>
        <div className="md:col-span-2">
          <button type="submit" disabled={loading} className="w-full bg-gray-800 text-white rounded px-4 py-2 hover:bg-gray-900 disabled:opacity-60">
            {loading ? "Registrando..." : "Registrarse"}
          </button>
        </div>
      </form>

      <p className="text-sm text-gray-600 mt-4">¿Ya tienes cuenta? <a href="/login" className="text-blue-600 hover:underline">Inicia sesión</a></p>
    </div>
  );
}
