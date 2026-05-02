import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers/expense_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/models/expense/expense.dart';
import '../../../domain/models/expense/expense_category.dart';
import '../../widgets/owl_mascot.dart';

class ExpenseListPage extends ConsumerStatefulWidget {
  const ExpenseListPage({super.key});

  @override
  ConsumerState<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends ConsumerState<ExpenseListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(expenseProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Gastos',
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
          if (state.expenses.isEmpty) {
            return Center(
              key: const Key('expenses-empty-text'),
              child: OwlMascot(
                scenario: OwlScenario.empty,
                size: 160,
                label: 'Sin gastos registrados.\nPresiona + para agregar uno.',
              ),
            );
          }
          return ListView.builder(
            key: const Key('expenses-list'),
            padding: const EdgeInsets.all(16),
            itemCount: state.expenses.length,
            itemBuilder: (context, index) {
              final expense = state.expenses[index];
              return _ExpenseCard(
                expense: expense,
                onDelete: () => _confirmDelete(context, expense),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: Text('¿Eliminar "${expense.description}"?'),
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
      ref.read(expenseProvider.notifier).delete(expense.id);
    }
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const _ExpenseCard({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final d = expense.date;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final amountStr = '\$${expense.amount.toStringAsFixed(0)}';

    return Card(
      key: Key('expense-card-${expense.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(expense.description),
        subtitle: Text('$dateStr · ${expense.category.label}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.dangerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                amountStr,
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
        onTap: () => context.push('/expense/${expense.id}'),
      ),
    );
  }
}
