import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/providers/expense_provider.dart';
import '../../../config/providers/sale_record_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/models/expense/expense.dart';
import '../../../domain/models/expense/expense_category.dart';
import '../../../domain/models/sale_record/sale_record.dart';
import '../../widgets/owl_mascot.dart';

enum _MovementType { income, expense }

class MovementsPage extends ConsumerStatefulWidget {
  const MovementsPage({super.key});

  @override
  ConsumerState<MovementsPage> createState() => _MovementsPageState();
}

class _MovementsPageState extends ConsumerState<MovementsPage> {
  _MovementType _type = _MovementType.income;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(saleRecordProvider.notifier).load();
      ref.read(expenseProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final saleState = ref.watch(saleRecordProvider);
    final expenseState = ref.watch(expenseProvider);

    final isLoading = _type == _MovementType.income
        ? saleState.isLoading
        : expenseState.isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Movimientos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _TypeToggle(
            selected: _type,
            onChanged: (t) => setState(() => _type = t),
          ),
        ),
      ),
      body: Column(
        children: [
          _OwlHeader(type: _type),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isLoading
                  ? const Center(
                      key: ValueKey('loading'),
                      child: CircularProgressIndicator(),
                    )
                  : _type == _MovementType.income
                  ? _SalesList(
                      key: const ValueKey('sales'),
                      records: saleState.records,
                      error: saleState.error,
                      onDelete: _confirmDeleteSale,
                    )
                  : _ExpensesList(
                      key: const ValueKey('expenses'),
                      expenses: expenseState.expenses,
                      error: expenseState.error,
                      onDelete: _confirmDeleteExpense,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteSale(SaleRecord record) async {
    final confirmed = await _confirmDialog(
      title: 'Eliminar venta',
      content: '¿Eliminar "${record.productTitle}"?',
    );
    if (confirmed) ref.read(saleRecordProvider.notifier).delete(record.id);
  }

  Future<void> _confirmDeleteExpense(Expense expense) async {
    final confirmed = await _confirmDialog(
      title: 'Eliminar gasto',
      content: '¿Eliminar "${expense.description}"?',
    );
    if (confirmed) ref.read(expenseProvider.notifier).delete(expense.id);
  }

  Future<bool> _confirmDialog({
    required String title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
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
    return result ?? false;
  }
}

// ── Owl header ─────────────────────────────────────────────────────────────────

class _OwlHeader extends StatelessWidget {
  final _MovementType type;

  const _OwlHeader({required this.type});

  @override
  Widget build(BuildContext context) {
    final isIncome = type == _MovementType.income;
    final label = isIncome
        ? 'Revisando tus ingresos...'
        : 'Calculando tus gastos...';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          OwlMascot(scenario: OwlScenario.working, size: 80),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isIncome
                        ? AppTheme.successColor
                        : AppTheme.dangerColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Aquí tienes el resumen completo\nde tus movimientos.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toggle ─────────────────────────────────────────────────────────────────────

class _TypeToggle extends StatelessWidget {
  final _MovementType selected;
  final void Function(_MovementType) onChanged;

  const _TypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.cardBorder.withValues(alpha: 0.50),
          ),
        ),
        child: Row(
          children: [
            _ToggleBtn(
              label: 'Ingresos',
              icon: Icons.trending_up_rounded,
              active: selected == _MovementType.income,
              activeColor: AppTheme.successColor,
              onTap: () => onChanged(_MovementType.income),
            ),
            _ToggleBtn(
              label: 'Gastos',
              icon: Icons.trending_down_rounded,
              active: selected == _MovementType.expense,
              activeColor: AppTheme.dangerColor,
              onTap: () => onChanged(_MovementType.expense),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: active
                ? activeColor.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: active
                ? Border.all(color: activeColor.withValues(alpha: 0.50))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? activeColor : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? activeColor : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sales list ─────────────────────────────────────────────────────────────────

class _SalesList extends StatelessWidget {
  final List<SaleRecord> records;
  final String? error;
  final void Function(SaleRecord) onDelete;

  const _SalesList({
    super.key,
    required this.records,
    required this.error,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (records.isEmpty) {
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
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                  onPressed: () => onDelete(record),
                ),
              ],
            ),
            onTap: () => context.push('/sale/${record.id}'),
          ),
        );
      },
    );
  }
}

// ── Expenses list ──────────────────────────────────────────────────────────────

class _ExpensesList extends StatelessWidget {
  final List<Expense> expenses;
  final String? error;
  final void Function(Expense) onDelete;

  const _ExpensesList({
    super.key,
    required this.expenses,
    required this.error,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (expenses.isEmpty) {
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
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                  onPressed: () => onDelete(expense),
                ),
              ],
            ),
            onTap: () => context.push('/expense/${expense.id}'),
          ),
        );
      },
    );
  }
}
