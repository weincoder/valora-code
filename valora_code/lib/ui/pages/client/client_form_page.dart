import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/providers/client_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/models/client/client.dart';
import '../../widgets/retro_background.dart';

class ClientFormPage extends ConsumerStatefulWidget {
  final String? clientId;

  const ClientFormPage({super.key, this.clientId});

  @override
  ConsumerState<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends ConsumerState<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _documentIdCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  String? _imageBase64;
  bool _initialized = false;

  bool get _isEditing => widget.clientId != null;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController();
    _documentIdCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && _isEditing) {
      _initialized = true;
      final client = ref
          .read(clientProvider)
          .clients
          .where((c) => c.id == widget.clientId)
          .firstOrNull;
      if (client != null) {
        _fullNameCtrl.text = client.fullName;
        _documentIdCtrl.text = client.documentId;
        _emailCtrl.text = client.email;
        _phoneCtrl.text = client.phone;
        _imageBase64 = client.imageBase64;
      }
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _documentIdCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _imageBase64 = base64Encode(bytes));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(clientProvider.notifier);
    final client = Client(
      id: widget.clientId ?? notifier.generateId(),
      fullName: _fullNameCtrl.text.trim(),
      documentId: _documentIdCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      imageBase64: _imageBase64,
    );
    await notifier.save(client);
    final error = ref.read(clientProvider).error;
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Cliente' : 'Nuevo Cliente'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RetroBackground(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionTitle(label: 'Datos del cliente'),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('client-full-name-field'),
                        controller: _fullNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('client-document-id-field'),
                        controller: _documentIdCtrl,
                        decoration: const InputDecoration(
                          labelText: 'NIT / Número de documento',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('client-email-field'),
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requerido';
                          final regex = RegExp(
                            r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                          );
                          return regex.hasMatch(v.trim())
                              ? null
                              : 'Email inválido';
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('client-phone-field'),
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      const _SectionTitle(label: 'Foto / Logo (opcional)'),
                      const SizedBox(height: 12),
                      _ClientImagePicker(
                        imageBase64: _imageBase64,
                        onPick: _pickImage,
                        onClear: _imageBase64 != null
                            ? () => setState(() => _imageBase64 = null)
                            : null,
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        key: const Key('save-client-button'),
                        onPressed: _save,
                        child: Text(
                          _isEditing ? 'Guardar cambios' : 'Crear cliente',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }
}

class _ClientImagePicker extends StatelessWidget {
  final String? imageBase64;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const _ClientImagePicker({
    this.imageBase64,
    required this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          key: const Key('client-image-picker-area'),
          onTap: onPick,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.4),
              ),
            ),
            child: imageBase64 != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(imageBase64!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 36,
                        color: AppTheme.accentColor,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Toca para agregar foto / logo',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
          ),
        ),
        if (onClear != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
