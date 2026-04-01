import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/app_config.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../widgets/backend_config_dialog.dart';
import 'login_page.dart';

class PerfilPage extends StatefulWidget {
  final bool isGuest;

  const PerfilPage({super.key, this.isGuest = false});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _auth = AuthService();
  final _session = SessionService();
  late Future<AppUser?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<AppUser?> _loadProfile() async {
    final cachedUser = await _session.getUser();
    if (cachedUser == null) return null;

    try {
      return await _auth.fetchProfile();
    } catch (_) {
      return cachedUser;
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _refreshProfile() async {
    final future = _loadProfile();
    setState(() => _profileFuture = future);
    await future;
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  Future<void> _openBackendDialog() async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => const BackendConfigDialog(),
    );

    if (updated != true) return;
    _show('Dirección de conexión actualizada.');
    await _refreshProfile();
  }

  Future<void> _openEditDialog(AppUser user) async {
    final updated = await showDialog<AppUser>(
      context: context,
      builder: (_) => _EditProfileDialog(auth: _auth, user: user),
    );

    if (updated == null) return;
    _show('Perfil actualizado. Los cambios ya se reflejan en la app de la panadería.');
    setState(() => _profileFuture = Future.value(updated));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.isGuest) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white.withOpacity(0.55),
                      child: const Icon(
                        Icons.person_outline,
                        size: 30,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Modo invitado',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Puedes explorar la tienda y configurar la conexión antes de iniciar sesión.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                                (_) => false,
                              );
                            },
                            icon: const Icon(Icons.login),
                            label: const Text('Iniciar sesión'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conexión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppConfig.apiBaseUrl,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _openBackendDialog,
                      icon: const Icon(Icons.settings_ethernet),
                      label: const Text('Cambiar IP de conexión'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const Center(child: Text('Sin datos de sesión.'));
        }

        return RefreshIndicator(
          onRefresh: _refreshProfile,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white.withOpacity(0.55),
                      child: Text(
                        user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openEditDialog(user),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Editar perfil'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _infoCard(
                title: 'Datos personales',
                items: [
                  _ProfileItem('Nombre', user.nombre),
                  _ProfileItem('Apellido', user.apellido),
                  _ProfileItem('Correo', user.email),
                  _ProfileItem('Teléfono', user.telefono),
                ],
              ),
              const SizedBox(height: 14),
              _infoCard(
                title: 'Dirección',
                items: [
                  _ProfileItem('Dirección', user.direccion),
                  _ProfileItem('Distrito', user.distrito),
                  _ProfileItem('N.° casa', user.numeroCasa),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conexión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppConfig.apiBaseUrl,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _openBackendDialog,
                      icon: const Icon(Icons.settings_ethernet),
                      label: const Text('Cambiar IP de conexión'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCard({
    required String title,
    required List<_ProfileItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in items) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                item.label,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                item.value.trim().isEmpty ? 'No registrado' : item.value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (item != items.last) const Divider(height: 6),
          ],
        ],
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final AuthService auth;
  final AppUser user;

  const _EditProfileDialog({required this.auth, required this.user});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _apellido;
  late final TextEditingController _telefono;
  late final TextEditingController _direccion;
  late final TextEditingController _distrito;
  late final TextEditingController _numeroCasa;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.user.nombre);
    _apellido = TextEditingController(text: widget.user.apellido);
    _telefono = TextEditingController(text: widget.user.telefono);
    _direccion = TextEditingController(text: widget.user.direccion);
    _distrito = TextEditingController(text: widget.user.distrito);
    _numeroCasa = TextEditingController(text: widget.user.numeroCasa);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _telefono.dispose();
    _direccion.dispose();
    _distrito.dispose();
    _numeroCasa.dispose();
    super.dispose();
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final updated = await widget.auth.updateProfile(
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        telefono: _telefono.text.trim(),
        direccion: _direccion.text.trim(),
        distrito: _distrito.text.trim(),
        numeroCasa: _numeroCasa.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      _show(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar perfil'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(_nombre, 'Nombre', minLength: 2),
              _field(_apellido, 'Apellido', minLength: 2),
              _field(
                _telefono,
                'Teléfono',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (!RegExp(r'^9\d{8}$').hasMatch(text)) {
                    return 'Ingresa un teléfono válido de 9 dígitos';
                  }
                  return null;
                },
              ),
              _field(_direccion, 'Dirección', minLength: 5),
              _field(_distrito, 'Distrito', minLength: 2),
              _field(_numeroCasa, 'N.° casa', minLength: 1),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
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

  Widget _field(
    TextEditingController controller,
    String label, {
    int minLength = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator ??
            (value) {
              final text = value?.trim() ?? '';
              if (text.length < minLength) {
                return 'Completa $label';
              }
              return null;
            },
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _ProfileItem {
  final String label;
  final String value;

  const _ProfileItem(this.label, this.value);
}
