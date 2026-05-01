import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers/product_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../widgets/cost_calculator_form.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de Costos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CostCalculatorForm(),
            const SizedBox(height: 32),
            if (state.errorMessage != null)
              _ErrorCard(message: state.errorMessage!),
            if (state.profitMargin != null)
              _ResultCard(profitMargin: state.profitMargin!),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final double profitMargin;

  const _ResultCard({required this.profitMargin});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('result-card'),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Margen de ganancia neto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              '${profitMargin.toStringAsFixed(2)}%',
              key: const Key('profit-margin-text'),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('error-card'),
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                key: const Key('error-message-text'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
