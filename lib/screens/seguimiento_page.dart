import 'package:flutter/material.dart';
import '../models/order_status_update.dart';
import '../models/order_tracking.dart';
import '../services/order_tracking_service.dart';
import '../services/pusher_tracking_service.dart';
import '../theme/app_colors.dart';

class SeguimientoPage extends StatefulWidget {
  final String orderId;
  const SeguimientoPage({super.key, required this.orderId});

  @override
  State<SeguimientoPage> createState() => _SeguimientoPageState();
}

class _SeguimientoPageState extends State<SeguimientoPage> {
  final OrderTrackingService _service = OrderTrackingService();
  final PusherTrackingService _pusher = PusherTrackingService();
  OrderTracking? _order;
  bool _loading = true;
  String? _socketInfo;
  String? _socketDebug;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final order = await _service.getOrderById(widget.orderId);
      if (!mounted) return;
      setState(() => _order = order);
      await _pusher.connectToOrder(
        orderId: order.id.isNotEmpty ? order.id : widget.orderId,
        onUpdate: _handleSocketUpdate,
        onInfo: (message) {
          if (!mounted) return;
          setState(() => _socketDebug = message);
        },
        onError: (message) {
          if (!mounted) return;
          setState(() {
            _socketInfo = message;
            _socketDebug = 'Error Pusher: $message';
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos cargar el seguimiento en este momento.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSocketUpdate(OrderStatusUpdate update) async {
    if (update.orderId.isNotEmpty &&
        update.orderId != widget.orderId &&
        update.orderId != (_order?.id ?? '')) {
      return;
    }

    final currentOrder = _order;
    if (currentOrder != null) {
      setState(() {
        _order = _applySocketUpdate(currentOrder, update);
        _socketInfo = update.mensaje ?? 'Estado actualizado en tiempo real';
      });
    } else {
      setState(() {
        _socketInfo = update.mensaje ?? 'Estado actualizado en tiempo real';
      });
    }

    try {
      final refreshed = await _service.getOrderById(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = refreshed;
      });
    } catch (_) {
      // Conservamos el cambio visual recibido por Pusher si el backend todavía no refleja el estado.
    }
  }

  @override
  void dispose() {
    _pusher.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Seguimiento del pedido'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('No se encontró el pedido.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _summaryCard(_order!),
                      const SizedBox(height: 12),
                      _pusherDebugCard(),
                      if (_socketInfo != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(_socketInfo!, style: const TextStyle(color: AppColors.text)),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Text('Estado del pedido',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      ..._order!.timeline.map(_timelineItem),
                    ],
                  ),
                ),
    );
  }

  Widget _summaryCard(OrderTracking order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pedido #${order.codigo.isEmpty ? order.id : order.codigo}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text('Estado actual: ${order.estadoDetalle}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Cliente: ${order.cliente.isEmpty ? 'No especificado' : order.cliente}'),
          Text('Dirección: ${order.direccion.isEmpty ? 'No especificada' : order.direccion}'),
          Text('Distrito: ${order.distrito.isEmpty ? 'No especificado' : order.distrito}'),
          Text('Pago: ${order.metodoPago.isEmpty ? 'No especificado' : order.metodoPago}'),
          Text('Total: S/${order.total.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _pusherDebugCard() {
    final orderId = _order?.id.isNotEmpty == true ? _order!.id : widget.orderId;
    final channelName = _pusher.subscribedChannel.isNotEmpty
        ? _pusher.subscribedChannel
        : 'pedido.$orderId';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Debug Pusher',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text),
          ),
          const SizedBox(height: 8),
          Text('Canal esperado: $channelName'),
          Text('Evento esperado: ${_pusher.expectedEvent}'),
          const SizedBox(height: 6),
          Text(
            _socketDebug ?? 'Esperando conexión a Pusher...',
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  OrderTracking _applySocketUpdate(OrderTracking order, OrderStatusUpdate update) {
    final nextEstado = update.estado.trim().isEmpty ? order.estado : update.estado.trim();
    final nextDetalle = update.mensaje?.trim().isNotEmpty == true
        ? update.mensaje!.trim()
        : _formatEstado(nextEstado);

    return OrderTracking(
      id: order.id,
      codigo: order.codigo,
      estado: nextEstado,
      estadoDetalle: nextDetalle,
      cliente: order.cliente,
      direccion: order.direccion,
      distrito: order.distrito,
      metodoPago: order.metodoPago,
      total: order.total,
      creadoEn: order.creadoEn,
      actualizadoEn: DateTime.now(),
      timeline: _buildTimelineFromStatus(nextEstado),
    );
  }

  List<OrderTrackingTimelineItem> _buildTimelineFromStatus(String estado) {
    final normalized = estado.toLowerCase();
    final preparado = normalized.contains('prepar');
    final enCamino = normalized.contains('camino') ||
        normalized.contains('ruta') ||
        normalized.contains('delivery');
    final entregado = normalized.contains('entreg');

    return [
      const OrderTrackingTimelineItem(
        label: 'Pedido recibido',
        estado: 'completado',
        fecha: null,
      ),
      OrderTrackingTimelineItem(
        label: 'En preparación',
        estado: preparado || enCamino || entregado ? 'completado' : 'pendiente',
        fecha: preparado || enCamino || entregado ? DateTime.now() : null,
      ),
      OrderTrackingTimelineItem(
        label: 'En camino',
        estado: enCamino || entregado ? 'completado' : 'pendiente',
        fecha: enCamino || entregado ? DateTime.now() : null,
      ),
      OrderTrackingTimelineItem(
        label: 'Entregado',
        estado: entregado ? 'completado' : 'pendiente',
        fecha: entregado ? DateTime.now() : null,
      ),
    ];
  }

  String _formatEstado(String estado) {
    if (estado.trim().isEmpty) return 'Estado actualizado en tiempo real';
    final clean = estado.replaceAll('_', ' ').trim();
    return clean[0].toUpperCase() + clean.substring(1);
  }

  Widget _timelineItem(OrderTrackingTimelineItem item) {
    final normalized = item.estado.toLowerCase();
    final done = normalized.contains('complet') ||
        normalized.contains('entreg') ||
        normalized.contains('camino');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? Colors.green : AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: const TextStyle(fontWeight: FontWeight.w900)),
                if (item.fecha != null)
                  Text(item.fecha.toString(),
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
