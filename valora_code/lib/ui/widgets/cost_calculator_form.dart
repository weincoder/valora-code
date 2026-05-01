import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers/product_provider.dart';

class CostCalculatorForm extends ConsumerStatefulWidget {
  const CostCalculatorForm({super.key});

  @override
  ConsumerState<CostCalculatorForm> createState() => _CostCalculatorFormState();
}

class _CostCalculatorFormState extends ConsumerState<CostCalculatorForm> {
  final _formKey = GlobalKey<FormState>();
  final _productionCostController = TextEditingController();
  final _salePriceController = TextEditingController();

  @override
  void dispose() {
    _productionCostController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final productionCost = double.parse(_productionCostController.text);
    final salePrice = double.parse(_salePriceController.text);
    ref
        .read(productNotifierProvider.notifier)
        .calculate(productionCost, salePrice);
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) return 'Este campo es obligatorio';
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Ingresa un número válido';
    if (parsed < 0) return 'El valor no puede ser negativo';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(productNotifierProvider).isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            key: const Key('production-cost-field'),
            controller: _productionCostController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Costo de producción',
              prefixText: '\$ ',
            ),
            validator: _validateNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('sale-price-field'),
            controller: _salePriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Precio de venta',
              prefixText: '\$ ',
            ),
            validator: _validateNumber,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('calculate-button'),
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Calcular margen'),
          ),
        ],
      ),
    );
  }
}
