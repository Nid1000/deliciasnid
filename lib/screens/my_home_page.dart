import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/delicias_card.dart';
import 'promociones_page.dart';
import 'panaderia_page.dart';
import 'chat_bot_page.dart';
import 'informacion_ayuda_page.dart';

class MyHomePage extends StatefulWidget {
  final String userName;
  final bool isGuest;
  final bool embedded;
  final VoidCallback? onOpenTracking;
  final VoidCallback? onOpenLatestOrder;

  const MyHomePage({
    super.key,
    required this.userName,
    this.isGuest = false,
    this.embedded = false,
    this.onOpenTracking,
    this.onOpenLatestOrder,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE8D8A8), Color(0xFFD9C38C)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, ${widget.userName}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.isGuest
                                  ? 'Explora la app y consulta pedidos sin iniciar sesión.'
                                  : 'Sigue tus pedidos y descubre lo nuevo de la panadería.',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickStat(
                          icon: Icons.sync,
                          label: 'Panadería',
                          value: '..',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickStat(
                          icon: Icons.notifications_active_outlined,
                          label: 'Alertas',
                          value: '..',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onOpenLatestOrder ?? widget.onOpenTracking,
                icon: const Icon(Icons.radar),
                label: Text(widget.isGuest ? 'Buscar pedido' : 'Ver mi ultimo pedido'),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Accesos rapidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.03,
              children: [
                _Tile(
                  label: 'Promociones',
                  subtitle: 'Ofertas y destacados',
                  icon: Icons.local_offer_outlined,
                  color: const Color(0xFFE3C25A),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PromocionesPage()),
                  ),
                ),
                _Tile(
                  label: 'Seguimiento',
                  subtitle: 'Consulta tu pedido',
                  icon: Icons.local_shipping_outlined,
                  color: const Color(0xFFC79A63),
                  onTap: widget.onOpenTracking ?? () {},
                ),
                _Tile(
                  label: 'Nuevos\nProductos',
                  subtitle: 'Explora el catalogo',
                  icon: Icons.bakery_dining_outlined,
                  color: const Color(0xFFF0C070),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PanaderiaPage()),
                  ),
                ),
                _Tile(
                  label: 'Chatbot',
                  subtitle: 'Ayuda inmediata',
                  icon: Icons.smart_toy_outlined,
                  color: const Color(0xFFBFD9EA),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatBotPage()),
                  ),
                ),
                _Tile(
                  label: 'Mi pedido',
                  subtitle: 'Abre el mas reciente',
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFFE9B46A),
                  onTap:
                      widget.onOpenLatestOrder ??
                      widget.onOpenTracking ??
                      () {},
                ),
                _Tile(
                  label: 'Informacion',
                  subtitle: 'Soporte y ayuda',
                  icon: Icons.info_outline,
                  color: const Color(0xFF0B3D91),
                  textColor: Colors.white,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InformacionAyudaPage(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            DeliciasCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isGuest
                              ? 'Modo invitado activo'
                              : 'Conectado con Delicias',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.isGuest
                              ? 'Puedes revisar productos, configurar la IP y buscar pedidos manualmente antes de iniciar sesión.'
                              : 'Tus pedidos, tu perfil y la tienda se mantienen sincronizados con la atención de la panadería.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Row(
            children: [
              Image.asset('assets/logos/delicias.png', height: 22),
              const SizedBox(width: 6),
              const Text(
                'Delicias',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        title: const Text(
          'Inicio',
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.text),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Menú (demo)')));
            },
          ),
        ],
      ),
      body: content,
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _Tile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.textColor = AppColors.text,
  });

  @override
  Widget build(BuildContext context) {
    return DeliciasCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 34, color: textColor),
            const SizedBox(height: 18),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: textColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.78),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.text, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
