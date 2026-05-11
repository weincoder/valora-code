import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/providers/friend_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/models/friend/friend.dart';
import '../../widgets/retro_background.dart';

class FriendFormPage extends ConsumerStatefulWidget {
  final String? friendId;

  const FriendFormPage({super.key, this.friendId});

  @override
  ConsumerState<FriendFormPage> createState() => _FriendFormPageState();
}

class _FriendFormPageState extends ConsumerState<FriendFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _hourlyRateCtrl;
  late final TextEditingController _knowledgeAreasCtrl;
  String _currency = 'COP';
  String? _imageBase64;
  bool _initialized = false;

  bool get _isEditing => widget.friendId != null;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController();
    _hourlyRateCtrl = TextEditingController();
    _knowledgeAreasCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && _isEditing) {
      _initialized = true;
      final friend = ref
          .read(friendProvider)
          .friends
          .where((f) => f.id == widget.friendId)
          .firstOrNull;
      if (friend != null) {
        _fullNameCtrl.text = friend.fullName;
        _hourlyRateCtrl.text = friend.hourlyRate.toString();
        _knowledgeAreasCtrl.text = friend.knowledgeAreas.join(', ');
        _currency = friend.currency;
        _imageBase64 = friend.imageBase64;
      }
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _hourlyRateCtrl.dispose();
    _knowledgeAreasCtrl.dispose();
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

  List<String> _parseAreas() {
    return _knowledgeAreasCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(friendProvider.notifier);
    final friend = Friend(
      id: widget.friendId ?? notifier.generateId(),
      fullName: _fullNameCtrl.text.trim(),
      knowledgeAreas: _parseAreas(),
      hourlyRate: double.tryParse(_hourlyRateCtrl.text.trim()) ?? 0,
      currency: _currency,
      imageBase64: _imageBase64,
    );
    await notifier.save(friend);
    final error = ref.read(friendProvider).error;
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      context.pop();
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar amigo'),
        content: Text('¿Seguro que quieres eliminar a ${_fullNameCtrl.text}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(friendProvider.notifier).delete(widget.friendId!);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Amigo' : 'Nuevo Amigo'),
        actions: [
          if (_isEditing)
            IconButton(
              key: const Key('delete-friend-button'),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Eliminar',
              onPressed: _delete,
            ),
        ],
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
                      const _SectionTitle(label: 'Datos del amigo'),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('friend-full-name-field'),
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
                        key: const Key('friend-knowledge-areas-field'),
                        controller: _knowledgeAreasCtrl,
                        decoration: const InputDecoration(
                          labelText:
                              'Áreas de conocimiento (separadas por coma)',
                          hintText: 'Flutter, Dart, Firebase',
                          prefixIcon: Icon(Icons.psychology_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('friend-hourly-rate-field'),
                        controller: _hourlyRateCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Valor por hora',
                          prefixIcon: Icon(Icons.attach_money_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Requerido';
                          }
                          final rate = double.tryParse(v.trim());
                          if (rate == null) return 'Ingresa un número válido';
                          if (rate < 0) return 'Debe ser mayor o igual a 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _CurrencySelector(
                        selected: _currency,
                        onChanged: (v) => setState(() => _currency = v),
                      ),
                      const SizedBox(height: 20),
                      const _SectionTitle(label: 'Foto (opcional)'),
                      const SizedBox(height: 12),
                      _FriendImagePicker(
                        imageBase64: _imageBase64,
                        onPick: _pickImage,
                        onClear: _imageBase64 != null
                            ? () => setState(() => _imageBase64 = null)
                            : null,
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        key: const Key('save-friend-button'),
                        onPressed: _save,
                        child: Text(
                          _isEditing ? 'Guardar cambios' : 'Crear amigo',
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

// ── Selector de moneda ─────────────────────────────────────────────────────────

class _CurrencySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _CurrencySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Moneda:',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(width: 12),
        _CurrencyOption(
          label: 'COP',
          selected: selected == 'COP',
          onTap: () => onChanged('COP'),
        ),
        const SizedBox(width: 8),
        _CurrencyOption(
          label: 'USD',
          selected: selected == 'USD',
          onTap: () => onChanged('USD'),
        ),
      ],
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CurrencyOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accentColor
              : AppTheme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accentColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : AppTheme.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── Image picker ───────────────────────────────────────────────────────────────

class _FriendImagePicker extends StatelessWidget {
  final String? imageBase64;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const _FriendImagePicker({
    required this.imageBase64,
    required this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (imageBase64 != null) {
      final Uint8List bytes = base64Decode(imageBase64!);
      return Stack(
        alignment: Alignment.topRight,
        children: [
          GestureDetector(
            onTap: onPick,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                bytes,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
        ],
      );
    }

    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.accentColor.withValues(alpha: 0.4),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: AppTheme.accentColor),
            SizedBox(height: 6),
            Text(
              'Agregar foto',
              style: TextStyle(color: AppTheme.accentColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sección título ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
