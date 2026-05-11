import 'package:flutter/material.dart';
import 'currency_format_helper.dart';

class InvoiceSummaryCard extends StatelessWidget {
  final double total;

  const InvoiceSummaryCard({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: Theme.of(context).textTheme.titleMedium),
            Text(
              formatCop(total),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
