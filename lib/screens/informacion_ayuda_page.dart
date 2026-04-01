import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/delicias_appbar.dart';
import '../widgets/delicias_card.dart';
import '../models/informacion_ayuda.dart';

class InformacionAyudaPage extends StatefulWidget {
  const InformacionAyudaPage({super.key});

  @override
  _InformacionAyudaPageState createState() => _InformacionAyudaPageState();
}

class _InformacionAyudaPageState extends State<InformacionAyudaPage> {
  List<Map<String, String>> data = [];

  final List<InformacionAyuda> items = [
    InformacionAyuda(
      titulo: 'Cómo comprar en nuestra panadería',
      detalles: [
        {'Paso 1': 'Explora nuestros panes, postres y productos destacados.'},
        {'Paso 2': 'Agrega tus favoritos al carrito y revisa tu pedido.'},
        {'Paso 3': 'Confirma tu compra y elige tu metodo de pago.'},
      ],
    ),
    InformacionAyuda(
      titulo: 'Horario de atencion',
      detalles: [
        {'Lunes a viernes': '9:00 AM - 6:00 PM'},
        {'Sabado': '8:00 AM - 2:00 PM'},
        {'Domingo': 'Cerrado'},
      ],
    ),
    InformacionAyuda(
      titulo: 'Formas de pago',
      detalles: [
        {'Visa': 'Paga de forma segura con tu tarjeta Visa.'},
        {'Mastercard': 'Realiza tu compra con tarjeta Mastercard.'},
      ],
    ),
    InformacionAyuda(
      titulo: 'Cambios y devoluciones',
      detalles: [
        {'Producto en mal estado': 'Te ayudamos con el cambio o la devolucion.'},
        {'Consulta general': 'Escribenos para revisar tu caso lo antes posible.'},
      ],
    ),
    InformacionAyuda(
      titulo: 'Ubicacion y contacto',
      detalles: [
        {'Direccion': 'Jr. Parra del Riego'},
        {'Telefono': '+51 234 567 890'},
        {'Correo': 'delicias@empresa.com'},
      ],
    ),
  ];

  void _openDialog(String title) {
    final selectedItem = items.firstWhere((item) => item.titulo == title);

    setState(() {
      data = selectedItem.detalles;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Clave')),
              DataColumn(label: Text('Detalle')),
            ],
            rows: data.map((e) {
              return DataRow(
                cells: [
                  DataCell(Text(e.keys.first)),
                  DataCell(Text(e.values.first)),
                ],
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DeliciasAppBar(title: 'Información / Ayuda'),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(18),
          itemBuilder: (_, i) => _buildCard(items[i].titulo), 
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemCount: items.length,
        ),
      ),
    );
  }

  Widget _buildCard(String title) {
    return DeliciasCard(
      onTap: () => _openDialog(title), 
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text),
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.text),
        ],
      ),
    );
  }
}
