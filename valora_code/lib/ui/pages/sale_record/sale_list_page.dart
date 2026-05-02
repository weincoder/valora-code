import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers/sale_record_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/models/sale_record/sale_record.dart';
import '../../widgets/owl_mascot.dart';

class SaleListPage extends ConsumerStatefulWidget {
  const SaleListPage({super.key});

  @override
  ConsumerState<SaleListPage> createState() => _SaleListPageState();
}

class _SaleListPageState extends ConsumerState<SaleListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(saleRecordProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saleRecordProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Ventas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Builder(
        builder: (_) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state.records.isEmpty) {
            return Center(
              key: const Key('sales-empty-text'),
              child: OwlMascot(
                scenario: OwlScenario.empty,
                size: 160,
                label: 'Sin ventas registradas.\nPresiona + para agregar una.',
              ),
            );
          }
          return ListView.builder(
            key: const Key('sales-list'),
            padding: const EdgeInsets.all(16),
            itemCount: state.records.length,
            itemBuilder: (context, index) {
              final record = state.records[index];
              return _SaleRecordCard(
                record: record,
                onDelete: () => _confirmDelete(context, record),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SaleRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar venta'),
        content: Text('¿Eliminar "${record.productTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(saleRecordProvider.notifier).delete(record.id);
    }
  }
}

class _SaleRecordCard extends StatelessWidget {
  final SaleRecord record;
  final VoidCallback onDelete;

  const _SaleRecordCard({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final d = record.date;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final unitStr = '\$${record.unitPrice.toStringAsFixed(0)}';
    final totalStr = '\$${record.totalAmount.toStringAsFixed(0)}';

    return Card(
      key: Key('sale-record-card-${record.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(record.productTitle),
        subtitle: Text('$dateStr · ${record.quantity} × $unitStr'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                totalStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: () => context.push('/sale/${record.id}'),
      ),
    );
  }
}
