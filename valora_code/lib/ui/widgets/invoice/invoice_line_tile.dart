import 'package:flutter/material.dart';
import '../../../domain/models/invoice/invoice_line.dart';
import 'currency_format_helper.dart';

class InvoiceLineTile extends StatelessWidget {
  final InvoiceLine line;

  const InvoiceLineTile({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.itemName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${line.quantity} × ${formatCop(line.unitPrice)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            formatCop(line.subtotal),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
