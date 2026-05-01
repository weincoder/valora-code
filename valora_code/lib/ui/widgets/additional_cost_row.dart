import 'package:flutter/material.dart';

class AdditionalCostRow extends StatelessWidget {
  final int index;
  final TextEditingController labelController;
  final TextEditingController amountController;
  final VoidCallback onRemove;

  const AdditionalCostRow({
    super.key,
    required this.index,
    required this.labelController,
    required this.amountController,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      key: Key('additional-cost-row-$index'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            key: Key('cost-label-$index'),
            controller: labelController,
            decoration: const InputDecoration(
              labelText: 'Concepto',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Ingresa un concepto' : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextFormField(
            key: Key('cost-amount-$index'),
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monto',
              prefixText: '\$ ',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Requerido';
              if (double.tryParse(v) == null) return 'Número inválido';
              return null;
            },
          ),
        ),
        IconButton(
          key: Key('remove-cost-$index'),
          onPressed: onRemove,
          icon: const Icon(
            Icons.remove_circle_outline,
            color: Colors.redAccent,
          ),
          tooltip: 'Eliminar costo',
        ),
      ],
    );
  }
}
