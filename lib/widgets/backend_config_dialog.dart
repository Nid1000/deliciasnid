import 'package:flutter/material.dart';
import '../services/app_config.dart';
import '../theme/app_colors.dart';

class BackendConfigDialog extends StatefulWidget {
  const BackendConfigDialog({super.key});

  @override
  State<BackendConfigDialog> createState() => _BackendConfigDialogState();
}

class _BackendConfigDialogState extends State<BackendConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: AppConfig.hasCustomApiBaseUrl ? AppConfig.apiBaseUrl : '',
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final value = _urlController.text.trim();
      if (value.isEmpty) {
        await AppConfig.resetCustomApiBaseUrl();
      } else {
        await AppConfig.setCustomApiBaseUrl(value);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Conexión de la app'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Predeterminado: ${AppConfig.defaultApiBaseUrl}',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'IP o dirección de conexión',
                hintText: '192.168.18.117:5001',
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return null;
                if (!text.contains('.') && !text.contains('localhost')) {
                  return 'Ingresa una IP o URL válida';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Puedes escribir solo la IP y puerto. La app agregará /api automáticamente.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _saving
              ? null
              : () async {
                  setState(() => _saving = true);
                  await AppConfig.resetCustomApiBaseUrl();
                  if (!mounted) return;
                  Navigator.pop(context, true);
                },
          child: const Text('Usar predeterminado'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
