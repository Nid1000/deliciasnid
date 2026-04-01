import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/dni_service.dart';
import '../services/orders_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import 'pago_exitoso_page.dart';

class ProcesoPagoPage extends StatefulWidget {
  const ProcesoPagoPage({super.key});

  @override
  State<ProcesoPagoPage> createState() => _ProcesoPagoPageState();
}

class _ProcesoPagoPageState extends State<ProcesoPagoPage> {
  String _metodo = 'Contra entrega';
  String _comprobanteTipo = 'boleta';
  String _tipoDocumento = 'DNI';
  bool _loading = false;
  bool _initialized = false;
  bool _consultandoDni = false;
  String? _dniInfo;
  String? _dniError;

  final _nTarjeta = TextEditingController();
  final _titular = TextEditingController();
  final _cvv = TextEditingController();
  final _fechaEntrega = TextEditingController();
  final _direccion = TextEditingController();
  final _distrito = TextEditingController();
  final _numeroCasa = TextEditingController();
  final _telefono = TextEditingController();
  final _notas = TextEditingController();
  final _numeroDocumento = TextEditingController();
  final _dniService = DniService();

  Future<void> _seleccionarFechaEntrega() async {
    final now = DateTime.now();
    final initialDate = _parseFechaEntrega() ?? now.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: 'Selecciona la fecha de entrega',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked == null) return;
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    _fechaEntrega.text = '${picked.year}-$month-$day';
  }

  DateTime? _parseFechaEntrega() {
    final value = _fechaEntrega.text.trim();
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  void _msg(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _consultarDni() async {
    final dni = _numeroDocumento.text.trim();
    if (dni.length != 8) {
      setState(() {
        _dniError = 'El DNI debe tener 8 digitos';
        _dniInfo = null;
      });
      return;
    }

    setState(() {
      _consultandoDni = true;
      _dniError = null;
      _dniInfo = null;
    });

    final result = await _dniService.consultarDni(dni);
    if (!mounted) return;

    setState(() {
      _consultandoDni = false;
      if (result == null) {
        _dniError = 'No se pudo validar el DNI en este momento';
      } else {
        _dniInfo = result.nombreCompleto.isEmpty
            ? 'DNI validado correctamente'
            : result.nombreCompleto;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    SessionService().getUser().then((user) {
      if (!mounted || user == null) return;
      _direccion.text = user.direccion;
      _distrito.text = user.distrito;
      _telefono.text = user.telefono;
    });
  }

  @override
  void dispose() {
    _nTarjeta.dispose();
    _titular.dispose();
    _cvv.dispose();
    _fechaEntrega.dispose();
    _direccion.dispose();
    _distrito.dispose();
    _numeroCasa.dispose();
    _telefono.dispose();
    _notas.dispose();
    _numeroDocumento.dispose();
    super.dispose();
  }

  Future<void> _pagar() async {
    final cart = CartService();
    if (cart.items.isEmpty) {
      _msg('Tu carrito esta vacio');
      return;
    }

    if (_direccion.text.trim().isEmpty ||
        _distrito.text.trim().isEmpty ||
        _telefono.text.trim().isEmpty) {
      _msg('Completa direccion, distrito y telefono');
      return;
    }

    if (_tipoDocumento == 'DNI' && _numeroDocumento.text.trim().length != 8) {
      _msg('El DNI debe tener 8 digitos');
      return;
    }

    if (_tipoDocumento == 'RUC' && _numeroDocumento.text.trim().length != 11) {
      _msg('El RUC debe tener 11 digitos');
      return;
    }

    if (_metodo == 'Tarjeta') {
      if (_nTarjeta.text.trim().length < 12 || _cvv.text.trim().length < 3) {
        _msg('Completa bien los datos de tarjeta');
        return;
      }
    }

    setState(() => _loading = true);
    final orders = OrdersService();

    final orderId = await orders.createOrder(
      items: cart.items,
      total: cart.total,
      metodoPago: _metodo,
      fechaEntrega: _fechaEntrega.text.trim().isEmpty ? null : _fechaEntrega.text.trim(),
      direccionEntrega: _direccion.text.trim(),
      distritoEntrega: _distrito.text.trim(),
      numeroCasaEntrega: _numeroCasa.text.trim(),
      telefonoContacto: _telefono.text.trim(),
      notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
    );

    if (orderId == null || orderId.trim().isEmpty) {
      _msg('No pudimos registrar tu pedido en este momento');
      setState(() => _loading = false);
      return;
    }

    final paid = await orders.payOrder(orderId, metodoPago: _metodo);
    if (!paid) {
      _msg('No pudimos procesar el pago en este momento');
      setState(() => _loading = false);
      return;
    }

    await orders.issueReceipt(
      orderId: orderId,
      comprobanteTipo: _comprobanteTipo,
      tipoDocumento: _tipoDocumento,
      numeroDocumento: _numeroDocumento.text.trim(),
    );

    cart.clear();

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PagoExitosoPage(orderId: orderId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Proceso de pago',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Image.asset('assets/logos/delicias.png', height: 56),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Checkout Delicias',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Crea tu pedido y emite tu comprobante con la información de la panadería.',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _box(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total a pagar',
                      style: textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    'S/${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entrega',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Estos datos se envían a la panadería para registrar tu pedido.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _fechaEntrega,
                    readOnly: true,
                    onTap: _seleccionarFechaEntrega,
                    decoration: InputDecoration(
                      labelText: 'Fecha de entrega',
                      hintText: 'Selecciona una fecha',
                      suffixIcon: IconButton(
                        onPressed: _seleccionarFechaEntrega,
                        icon: const Icon(Icons.calendar_month_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _direccion,
                    decoration: const InputDecoration(labelText: 'Direccion'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _distrito,
                    decoration: const InputDecoration(labelText: 'Distrito'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _numeroCasa,
                    decoration: const InputDecoration(labelText: 'Numero de casa'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _telefono,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Telefono de contacto'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notas,
                    decoration: const InputDecoration(labelText: 'Notas'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metodo de pago',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Elige como quieres registrar el pago de tu pedido.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _radio('Contra entrega'),
                  _radio('Yape'),
                  _radio('Tarjeta'),
                  if (_metodo == 'Tarjeta') ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nTarjeta,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Numero de tarjeta'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _titular,
                      decoration: const InputDecoration(labelText: 'Titular'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _cvv,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'CVV'),
                      obscureText: true,
                    ),
                  ],
                  if (_metodo == 'Yape') ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Yape: 999 888 777  (Delicias del Centro)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comprobante',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Se emitirá con los datos registrados en la panadería.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'La validación de DNI funciona solo para usuarios autenticados en la panadería.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _comprobanteTipo,
                    items: const [
                      DropdownMenuItem(value: 'boleta', child: Text('Boleta')),
                      DropdownMenuItem(value: 'factura', child: Text('Factura')),
                    ],
                    onChanged: (v) => setState(() => _comprobanteTipo = v!),
                    decoration: const InputDecoration(labelText: 'Tipo de comprobante'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _tipoDocumento,
                    items: const [
                      DropdownMenuItem(value: 'DNI', child: Text('DNI')),
                      DropdownMenuItem(value: 'RUC', child: Text('RUC')),
                    ],
                    onChanged: (v) => setState(() {
                      _tipoDocumento = v!;
                      _dniInfo = null;
                      _dniError = null;
                    }),
                    decoration: const InputDecoration(labelText: 'Tipo de documento'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _numeroDocumento,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Numero de documento',
                      suffixIcon: _tipoDocumento == 'DNI'
                          ? TextButton(
                              onPressed: _consultandoDni ? null : _consultarDni,
                              child: _consultandoDni
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Validar'),
                            )
                          : null,
                    ),
                  ),
                  if (_tipoDocumento == 'DNI' && _dniInfo != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'RENIEC: $_dniInfo',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  if (_tipoDocumento == 'DNI' && _dniError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _dniError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumen del pedido', style: textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ...cart.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item['name']} x${item['qty']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          Text(
                            'S/${(((item['price'] as double) * (item['qty'] as int))).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _pagar,
                      child: const Text(
                        'Confirmar pedido',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radio(String label) {
    return RadioListTile<String>(
      value: label,
      groupValue: _metodo,
      onChanged: (v) => setState(() => _metodo = v!),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
      ),
      activeColor: AppColors.accent,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _box({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
