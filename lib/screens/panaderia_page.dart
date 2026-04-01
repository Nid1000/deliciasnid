import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/cart_service.dart';
import '../services/products_service.dart';

class PanaderiaPage extends StatefulWidget {
  const PanaderiaPage({super.key});

  @override
  State<PanaderiaPage> createState() => _PanaderiaPageState();
}

class _PanaderiaPageState extends State<PanaderiaPage> {
  final _svc = ProductsService();
  bool _loading = true;
  List<Map<String, dynamic>> _products = [];
  String _errorMessage =
      ''; // Para mostrar mensajes de error en caso de que falle la carga.

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await _svc.fetchProducts(limit: 50);
      setState(() {
        _products = p;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Error al cargar los productos: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Nuevos Productos',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              itemCount: _products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final p = _products[i];
                return _ProductCard(
                  name: p['name'].toString(),
                  desc: (p['desc'] ?? '').toString(),
                  price: (p['price'] as num).toDouble(),
                  imagePath: (p['image'] ?? '').toString(),
                  imageUrl: (p['imageUrl'] ?? '').toString(),
                  category: (p['category'] ?? '').toString(),
                  stock: (p['stock'] as num?)?.toInt() ?? 0,
                  featured: p['featured'] == true,
                  isNew: i < 6,
                  onAdd: () {
                    CartService().addProduct({
                      'id': (p['id'] ?? '').toString(),
                      'name': p['name'],
                      'price': p['price'],
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${p['name']} agregado ✅'),
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final String desc;
  final double price;
  final String imagePath;
  final String imageUrl;
  final String category;
  final int stock;
  final bool featured;
  final bool isNew;
  final VoidCallback onAdd;

  const _ProductCard({
    required this.name,
    required this.desc,
    required this.price,
    required this.imagePath,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.featured,
    required this.isNew,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
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
              width: 82,
              height: 82,
              color: Colors.white.withValues(alpha: 0.55),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _fallbackImage(),
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _fallbackImage(),
                          ),
                  ),
                  if (isNew)
                    const Positioned(
                      top: 6,
                      left: 6,
                      child: _Badge(label: 'Nuevo', color: Color(0xFF0B3D91)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'S/${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                if (category.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      if (featured)
                        const _Badge(
                          label: 'Destacado',
                          color: Color(0xFFC07B12),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  desc.isEmpty ? 'Producto recomendado del día' : desc,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stock > 0 ? 'Stock disponible: $stock' : 'Sin stock',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: stock > 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: stock > 0 ? onAdd : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent2,
                foregroundColor: AppColors.text,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                elevation: 0,
              ),
              child: const Text(
                'Agregar',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage() => const Center(
    child: Icon(Icons.bakery_dining, size: 36, color: AppColors.text),
  );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
