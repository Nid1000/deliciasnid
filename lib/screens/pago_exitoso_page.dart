import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'seguimiento_page.dart';

class PagoExitosoPage extends StatelessWidget {
  final String orderId;
  const PagoExitosoPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Image.asset('assets/logos/delicias.png'),
              ),
              const SizedBox(height: 14),
              const Icon(Icons.check_circle, size: 70, color: Colors.green),
              const SizedBox(height: 10),
              const Text('Pago realizado con éxito',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                    letterSpacing: -0.2,
                  )),
              const SizedBox(height: 8),
              const Text(
                'Tu pedido ya quedó registrado correctamente en la panadería.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text('Pedido #$orderId',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.muted,
                  )),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SeguimientoPage(orderId: orderId)),
                    );
                  },
                  child: const Text('Ver seguimiento', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
