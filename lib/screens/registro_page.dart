import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const List<String> _distritosHuancayo = [
    'Huancayo',
    'Carhuacallanga',
    'Chacapampa',
    'Chicche',
    'Chilca',
    'Chongos Alto',
    'Chupuro',
    'Colca',
    'Cullhuas',
    'El Tambo',
    'Huacrapuquio',
    'Hualhuas',
    'Huancan',
    'Huasicancha',
    'Huayucachi',
    'Ingenio',
    'Pariahuanca',
    'Pilcomayo',
    'Pucara',
    'Quichuay',
    'Quilcas',
    'San Agustin',
    'San Jeronimo de Tunan',
    'Santo Domingo de Acobamba',
    'Sapallanga',
    'Sicaya',
    'Viques',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _telefono = TextEditingController();
  final _direccion = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _distritoSeleccionado;

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.register(
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        telefono: _telefono.text.trim(),
        direccion: _direccion.text.trim(),
        distrito: _distritoSeleccionado!.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      if (!mounted) return;
      _show('Cuenta creada correctamente.');
      Navigator.pop(context);
    } catch (e) {
      _show(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _telefono.dispose();
    _direccion.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Registro')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_nombre, 'Nombre'),
                _field(_apellido, 'Apellido'),
                _field(_telefono, 'Teléfono'),
                _field(_direccion, 'Dirección'),
                _districtField(),
                _field(_email, 'Correo'),
                _field(_password, 'Contraseña', obscure: true),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading ? const CircularProgressIndicator() : const Text('Registrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _districtField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _distritoSeleccionado,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Distrito de Huancayo',
          border: OutlineInputBorder(),
        ),
        hint: const Text('Selecciona un distrito'),
        items: _distritosHuancayo
            .map(
              (distrito) => DropdownMenuItem<String>(
                value: distrito,
                child: Text(
                  distrito,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() => _distritoSeleccionado = value);
        },
        validator: (value) => (value == null || value.trim().isEmpty) ? 'Selecciona un distrito' : null,
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: (value) => (value == null || value.trim().isEmpty) ? 'Completa $label' : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
