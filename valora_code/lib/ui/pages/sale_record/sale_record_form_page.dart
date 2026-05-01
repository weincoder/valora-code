import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers/product_item_provider.dart';
import '../../../config/providers/sale_record_provider.dart';
import '../../../domain/models/product_item/product_item.dart';
import '../../widgets/retro_background.dart';

class SaleRecordFormPage extends ConsumerStatefulWidget {
  final String? saleRecordId;

  const SaleRecordFormPage({super.key, this.saleRecordId});

  @override
  ConsumerState<SaleRecordFormPage> createState() => _SaleRecordFormPageState();
}

class _SaleRecordFormPageState extends ConsumerState<SaleRecordFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _unitPriceController = TextEditingController();
  final _notesController = TextEditingController();

  ProductItem? _selectedProduct;
  DateTime _selectedDate = DateTime.now();
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productItemProvider.notifier).load();
      _loadExistingRecord();
    });
  }

  void _loadExistingRecord() {
    if (widget.saleRecordId == null) return;
    final records = ref.read(saleRecordProvider).records;
    final existing = records
        .where((r) => r.id == widget.saleRecordId)
        .firstOrNull;
    if (existing == null) return;

    setState(() {
      _isEdit = true;
      _quantityController.text = existing.quantity.toString();
      _unitPriceController.text = existing.unitPrice.toString();
      _notesController.text = existing.notes ?? '';
      _selectedDate = existing.date;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productItemProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar venta' : 'Registrar venta')),
      body: RetroBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product dropdown
                DropdownButtonFormField<ProductItem>(
                  key: const Key('sale-product-dropdown'),
                  // ignore: deprecated_member_use
                  value: _selectedProduct,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Producto / servicio',
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                  items: productsState.items.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p.title));
                  }).toList(),
                  onChanged: (product) {
                    setState(() {
                      _selectedProduct = product;
                      if (product != null) {
                        _unitPriceController.text = product.salePrice
                            .toString();
                      }
                    });
                  },
                  validator: (v) => v == null ? 'Selecciona un producto' : null,
                ),
                const SizedBox(height: 16),
                // Quantity
                TextFormField(
                  key: const Key('sale-quantity'),
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1) {
                      return 'Ingresa una cantidad válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Unit price
                TextFormField(
                  key: const Key('sale-unit-price'),
                  controller: _unitPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Precio unitario',
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Ingresa un precio válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Date picker
                ListTile(
                  key: const Key('sale-date'),
                  tileColor: Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Fecha: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                // Notes
                TextFormField(
                  key: const Key('sale-notes'),
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  key: const Key('sale-save-btn'),
                  onPressed: _save,
                  child: Text(_isEdit ? 'Actualizar venta' : 'Registrar venta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.parse(_quantityController.text);
    final unitPrice = double.parse(_unitPriceController.text);

    await ref
        .read(saleRecordProvider.notifier)
        .save(
          existingId: widget.saleRecordId,
          productItemId: _selectedProduct?.id ?? '',
          productTitle: _selectedProduct?.title ?? '',
          quantity: quantity,
          unitPrice: unitPrice,
          date: _selectedDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    if (mounted) context.pop();
  }
}
