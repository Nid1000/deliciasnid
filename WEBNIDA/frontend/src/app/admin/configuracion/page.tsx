"use client";
import { useEffect, useState } from "react";
import axios from "axios";
import type { AxiosError } from "axios";
import { buttonClasses } from "@/design/admin";
import { toast } from "react-hot-toast";

export default function AdminConfiguracionPage() {
  const [moneda, setMoneda] = useState('PEN');
  const [prefijo, setPrefijo] = useState('S/.');
  const [branding, setBranding] = useState('Delicias');
  const [notifTitle, setNotifTitle] = useState('');
  const [notifMessage, setNotifMessage] = useState('');
  const [notifRoute, setNotifRoute] = useState('store');
  const [notifAudience, setNotifAudience] = useState('both');
  const [notifTargetId, setNotifTargetId] = useState('');
  const [notifUserId, setNotifUserId] = useState('');
  const [sending, setSending] = useState(false);

  type ApiErrorResponse = { message?: string };

  useEffect(() => {
    // Cargar configuración básica desde localStorage (placeholder hasta tener API específica)
    const raw = localStorage.getItem('admin:config');
    if (raw) {
      try {
        const cfg = JSON.parse(raw);
        setMoneda(cfg.moneda || 'PEN');
        setPrefijo(cfg.prefijo || 'S/.');
        setBranding(cfg.branding || 'Delicias');
      } catch {}
    }
  }, []);

  const guardar = () => {
    const cfg = { moneda, prefijo, branding };
    localStorage.setItem('admin:config', JSON.stringify(cfg));
    alert('Configuración guardada');
  };

  const enviarNotificacion = async () => {
    if (!notifTitle.trim() || !notifMessage.trim()) {
      toast.error('Completa titulo y mensaje');
      return;
    }

    setSending(true);
    try {
      await axios.post('/api/notificaciones/admin/enviar', {
        title: notifTitle.trim(),
        message: notifMessage.trim(),
        audience: notifAudience,
        route: notifRoute || null,
        targetId: notifTargetId.trim() || null,
        userId: notifUserId.trim() ? Number(notifUserId.trim()) : null,
      });
      toast.success(
        notifUserId.trim()
          ? 'Notificacion enviada al usuario'
          : 'Notificacion enviada a todos los usuarios',
      );
      setNotifTitle('');
      setNotifMessage('');
      setNotifTargetId('');
      setNotifUserId('');
    } catch (e: unknown) {
      const error = e as AxiosError<ApiErrorResponse>;
      toast.error(error.response?.data?.message || error.message || 'No se pudo enviar la notificacion');
    } finally {
      setSending(false);
    }
  };

  return (
    <div>
      <h2 className="text-base font-semibold text-slate-900">Configuración del sitio</h2>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-2">
        <div>
          <label className="block text-sm font-medium text-slate-700">Moneda</label>
          <select value={moneda} onChange={(e) => setMoneda(e.target.value)} className="mt-1 w-full rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus:border-slate-900 focus:ring-2 focus:ring-slate-300">
            <option value="PEN">PEN (Soles peruanos)</option>
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-700">Prefijo</label>
          <input value={prefijo} onChange={(e) => setPrefijo(e.target.value)} className="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 shadow-sm focus:border-slate-900 focus:ring-2 focus:ring-slate-300" />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-700">Marca (branding)</label>
          <input value={branding} onChange={(e) => setBranding(e.target.value)} className="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 shadow-sm focus:border-slate-900 focus:ring-2 focus:ring-slate-300" />
        </div>
      </div>

      <div className="mt-3">
        <button className={buttonClasses({ variant: 'primary', size: 'md' })} onClick={guardar}>Guardar</button>
      </div>

      <div className="mt-8">
        <h3 className="text-base font-semibold text-slate-900">Enviar notificacion</h3>
        <p className="mt-1 text-sm text-slate-600">
          Puedes enviarla a todos los usuarios o a un usuario puntual. Si no pones ID de usuario, se envia a todos.
          Estas notificaciones llegan a cuentas de cliente del sistema, no al administrador.
        </p>
        <p className="mt-1 text-sm text-slate-500">
          Si el mismo usuario cliente tiene sesion iniciada en la web y en la app Flutter, al elegir <strong>Web y movil</strong>
          la recibira en ambos canales.
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-3">
          <div>
            <label className="block text-sm font-medium text-slate-700">Titulo</label>
            <input
              value={notifTitle}
              onChange={(e) => setNotifTitle(e.target.value)}
              className="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 shadow-sm focus:border-slate-900 focus:ring-2 focus:ring-slate-300"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700">Destino</label>
            <select
              value={notifAudience}
              onChange={(e) => setNotifAudience(e.target.value)}
              className="mt-1 w-full rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus:border-slate-900 focus:ring-2 focus:ring-slate-300"
            >
              <option value="both">Web y movil</option>
              <option value="web">Solo web</option>
              <option value="mobile">Solo movil</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700">Ruta al abrir</label>
            <select
              value={notifRoute}
              onChange={(e) => setNotifRoute(e.target.value)}
              className="mt-1 w-full rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus:border-slate-900 focus:ring-2 focus:ring-slate-300"
            >
              <option value="store">Tienda</option>
              <option value="order">Pedido</option>
            </select>
          </div>
          <div className="md:col-span-2">
            <label className="block text-sm font-medium text-slate-700">Mensaje</label>
            <textarea
              value={notifMessage}
              onChange={(e) => setNotifMessage(e.target.value)}
              rows={4}
              className="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 shadow-sm focus:border-slate-900 focus:ring-2 focus:ring-slate-300"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700">ID de pedido o destino (opcional)</label>
            <input
              value={notifTargetId}
              onChange={(e) => setNotifTargetId(e.target.value)}
              placeholder={notifRoute === 'order' ? 'Ej: 25' : 'Opcional'}
              className="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 shadow-sm focus:border-slate-900 focus:ring-2 focus:ring-slate-300"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700">ID usuario (opcional)</label>
            <input
              value={notifUserId}
              onChange={(e) => setNotifUserId(e.target.value)}
              placeholder="Vacio = enviar a todos"
              className="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 shadow-sm focus:border-slate-900 focus:ring-2 focus:ring-slate-300"
            />
          </div>
        </div>

        <div className="mt-3">
          <button
            className={buttonClasses({ variant: 'primary', size: 'md' })}
            onClick={enviarNotificacion}
            disabled={sending}
          >
            {sending ? 'Enviando...' : 'Enviar notificacion'}
          </button>
        </div>
      </div>
    </div>
  );
}
