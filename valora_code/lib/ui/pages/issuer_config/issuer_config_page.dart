import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers/issuer_config_provider.dart';
import '../../../domain/models/issuer_config/issuer_config.dart';

class IssuerConfigPage extends ConsumerStatefulWidget {
  const IssuerConfigPage({super.key});

  @override
  ConsumerState<IssuerConfigPage> createState() => _IssuerConfigPageState();
}

class _IssuerConfigPageState extends ConsumerState<IssuerConfigPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessNameCtrl;
  late final TextEditingController _nitCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _prefixCtrl;

  @override
  void initState() {
    super.initState();
    _businessNameCtrl = TextEditingController();
    _nitCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _prefixCtrl = TextEditingController(text: 'CC');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final config = ref.read(issuerConfigProvider).config;
    if (config != null) {
      _businessNameCtrl.text = config.businessName;
      _nitCtrl.text = config.nit;
      _addressCtrl.text = config.address;
      _prefixCtrl.text = config.invoicePrefix;
    }
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _nitCtrl.dispose();
    _addressCtrl.dispose();
    _prefixCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final current = ref.read(issuerConfigProvider).config;
    final config = IssuerConfig(
      businessName: _businessNameCtrl.text.trim(),
      nit: _nitCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      invoicePrefix: _prefixCtrl.text.trim(),
      nextConsecutive: current?.nextConsecutive ?? 1,
    );
    await ref.read(issuerConfigProvider.notifier).save(config);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Configuración guardada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(issuerConfigProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración del Emisor')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _businessNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre / Razón Social',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nitCtrl,
                      decoration: const InputDecoration(labelText: 'NIT'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _prefixCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Prefijo de cuenta de cobro',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 24),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          state.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
