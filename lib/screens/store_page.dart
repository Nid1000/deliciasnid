import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/products_service.dart';
import '../theme/app_colors.dart';
import 'proceso_pago_page.dart';
import 'promociones_page.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final _products = ProductsService();
  final _cart = CartService();
  bool _loading = true;
  List<Map<String, dynamic>> _featured = [];
  List<Map<String, dynamic>> _latest = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final featured = await _products.fetchProducts(
        featuredOnly: true,
        limit: 8,
      );
      final latest = await _products.fetchProducts(limit: 8);
      if (!mounted) return;
      setState(() {
        _featured = featured;
        _latest = latest.take(4).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8D8A8), Color(0xFFF0C070)],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tienda Delicias',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Productos, promociones y carrito de la panadería en un solo lugar.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MiniMetric(
                        label: 'Productos',
                        value: '${_latest.length}',
                        icon: Icons.bakery_dining_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniMetric(
                        label: 'Carrito',
                        value: '${_cart.count}',
                        icon: Icons.shopping_bag_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PromocionesPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_offer_outlined),
                  label: const Text('Promociones'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _cart.items.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProcesoPagoPage(),
                            ),
                          ).then((_) => setState(() {}));
                        },
                  icon: const Icon(Icons.payment),
                  label: Text(
                    _cart.items.isEmpty ? 'Sin carrito' : 'Pagar ahora',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Destacados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_featured.isEmpty)
            _emptyCard('No hay productos destacados disponibles por ahora.')
          else
            SizedBox(
              height: 176,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _featured.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _FeaturedCard(
                  product: _featured[index],
                  onAdd: () {
                    _cart.addProduct({
                      'id': _featured[index]['id'],
                      'name': _featured[index]['name'],
                      'price': _featured[index]['price'],
                    });
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${_featured[index]['name']} agregado al carrito',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Novedades de la panadería',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          if (_loading)
            const SizedBox.shrink()
          else if (_latest.isEmpty)
            _emptyCard('No hay productos recientes para mostrar.')
          else
            ..._latest.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RecentRow(
                  product: product,
                  onAdd: () {
                    _cart.addProduct({
                      'id': product['id'],
                      'name': product['name'],
                      'price': product['price'],
                    });
                    setState(() {});
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.muted)),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.text),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAdd;

  const _FeaturedCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (product['imageUrl'] ?? '').toString();
    final price = ((product['price'] as num?) ?? 0).toDouble();

    return Container(
      width: 188,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                color: Colors.white.withValues(alpha: 0.6),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.bakery_dining,
                          size: 40,
                          color: AppColors.text,
                        ),
                      )
                    : const Icon(
                        Icons.bakery_dining,
                        size: 40,
                        color: AppColors.text,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            (product['name'] ?? 'Producto').toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'S/${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAdd,
              child: const Text('Agregar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAdd;

  const _RecentRow({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (product['imageUrl'] ?? '').toString();
    final price = ((product['price'] as num?) ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 64,
              height: 64,
              color: Colors.white.withValues(alpha: 0.55),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.bakery_dining,
                        color: AppColors.text,
                      ),
                    )
                  : const Icon(Icons.bakery_dining, color: AppColors.text),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (product['name'] ?? 'Producto').toString(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  (product['category'] ?? '').toString(),
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          ElevatedButton(onPressed: onAdd, child: const Text('Agregar')),
        ],
      ),
    );
  }
}
