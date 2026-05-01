import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/providers/product_item_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/models/additional_cost/additional_cost.dart';
import '../../../domain/models/product_item/product_item.dart';
import '../../../domain/usecase/product_item/calculate_product_price_use_case.dart';
import '../../widgets/additional_cost_row.dart';
import '../../widgets/retro_background.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final String? productId;

  const ProductFormPage({super.key, this.productId});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _hourlyRateCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _salePriceCtrl = TextEditingController();

  final List<TextEditingController> _costLabelCtrls = [];
  final List<TextEditingController> _costAmountCtrls = [];

  String? _imageBase64;
  double _calculatedCost = 0;
  bool _initialized = false;

  final _calcPrice = CalculateProductPriceUseCase();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _hourlyRateCtrl.dispose();
    _hoursCtrl.dispose();
    _salePriceCtrl.dispose();
    for (final c in _costLabelCtrls) {
      c.dispose();
    }
    for (final c in _costAmountCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _loadExistingProduct() {
    if (_initialized || widget.productId == null) {
      _initialized = true;
      return;
    }
    _initialized = true;
    final items = ref.read(productItemProvider).items;
    final product = items.cast<ProductItem?>().firstWhere(
      (p) => p?.id == widget.productId,
      orElse: () => null,
    );
    if (product == null) return;

    _titleCtrl.text = product.title;
    _descCtrl.text = product.description;
    _hourlyRateCtrl.text = product.hourlyRate.toString();
    _hoursCtrl.text = product.estimatedHours.toString();
    _salePriceCtrl.text = product.salePrice.toString();
    _imageBase64 = product.imageBase64;

    for (final cost in product.additionalCosts) {
      _costLabelCtrls.add(TextEditingController(text: cost.label));
      _costAmountCtrls.add(TextEditingController(text: cost.amount.toString()));
    }
    _recalculate();
  }

  void _recalculate() {
    final hourlyRate = double.tryParse(_hourlyRateCtrl.text) ?? 0;
    final hours = double.tryParse(_hoursCtrl.text) ?? 0;
    final costs = _buildAdditionalCosts();
    setState(() {
      _calculatedCost = _calcPrice.execute(
        hourlyRate: hourlyRate,
        estimatedHours: hours,
        additionalCosts: costs,
      );
    });
  }

  List<AdditionalCost> _buildAdditionalCosts() {
    final List<AdditionalCost> costs = [];
    for (var i = 0; i < _costLabelCtrls.length; i++) {
      final label = _costLabelCtrls[i].text;
      final amount = double.tryParse(_costAmountCtrls[i].text) ?? 0;
      if (label.isNotEmpty) {
        costs.add(AdditionalCost(label: label, amount: amount));
      }
    }
    return costs;
  }

  void _addCostRow() {
    setState(() {
      _costLabelCtrls.add(TextEditingController());
      _costAmountCtrls.add(TextEditingController());
    });
  }

  void _removeCostRow(int index) {
    setState(() {
      _costLabelCtrls[index].dispose();
      _costAmountCtrls[index].dispose();
      _costLabelCtrls.removeAt(index);
      _costAmountCtrls.removeAt(index);
    });
    _recalculate();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(productItemProvider.notifier)
        .save(
          existingId: widget.productId,
          title: _titleCtrl.text,
          description: _descCtrl.text,
          hourlyRate: double.parse(_hourlyRateCtrl.text),
          estimatedHours: double.parse(_hoursCtrl.text),
          additionalCosts: _buildAdditionalCosts(),
          salePrice: double.parse(_salePriceCtrl.text),
          imageBase64: _imageBase64,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    _loadExistingProduct();
    final isEditing = widget.productId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Crear Producto'),
      ),
      body: RetroBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            onChanged: _recalculate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionTitle(label: 'Información general'),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('product-title-field'),
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título del producto',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('product-desc-field'),
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 20),
                _SectionTitle(label: 'Cálculo de costos'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const Key('hourly-rate-field'),
                        controller: _hourlyRateCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Valor/hora',
                          prefixText: '\$ ',
                        ),
                        validator: (v) => double.tryParse(v ?? '') == null
                            ? 'Número inválido'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        key: const Key('estimated-hours-field'),
                        controller: _hoursCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Horas estimadas',
                        ),
                        validator: (v) => double.tryParse(v ?? '') == null
                            ? 'Número inválido'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Costos adicionales',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextButton.icon(
                      key: const Key('add-cost-button'),
                      onPressed: _addCostRow,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Agregar'),
                    ),
                  ],
                ),
                ...List.generate(
                  _costLabelCtrls.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AdditionalCostRow(
                      index: i,
                      labelController: _costLabelCtrls[i],
                      amountController: _costAmountCtrls[i],
                      onRemove: () => _removeCostRow(i),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _CostSummaryCard(calculatedCost: _calculatedCost),
                const SizedBox(height: 20),
                _SectionTitle(label: 'Precio de venta'),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('sale-price-form-field'),
                  controller: _salePriceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Precio de venta',
                    prefixText: '\$ ',
                  ),
                  validator: (v) {
                    if (double.tryParse(v ?? '') == null) {
                      return 'Número inválido';
                    }
                    if ((double.tryParse(v ?? '') ?? 0) <= 0) {
                      return 'Debe ser mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _SectionTitle(label: 'Imagen del producto (opcional)'),
                const SizedBox(height: 12),
                _ImagePicker(imageBase64: _imageBase64, onPick: _pickImage),
                const SizedBox(height: 28),
                ElevatedButton(
                  key: const Key('save-product-button'),
                  onPressed: _submit,
                  child: Text(isEditing ? 'Guardar cambios' : 'Crear producto'),
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

class _CostSummaryCard extends StatelessWidget {
  final double calculatedCost;
  const _CostSummaryCard({required this.calculatedCost});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('cost-summary-card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Costo total calculado:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            '\$${calculatedCost.toStringAsFixed(2)}',
            key: const Key('calculated-cost-text'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  final String? imageBase64;
  final VoidCallback onPick;

  const _ImagePicker({this.imageBase64, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('image-picker-area'),
      onTap: onPick,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.accentColor.withValues(alpha: 0.4),
            style: BorderStyle.solid,
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
                    'Toca para agregar imagen',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }
}
