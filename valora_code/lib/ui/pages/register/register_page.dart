import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/providers/expense_provider.dart';
import '../../../config/providers/product_item_provider.dart';
import '../../../config/providers/sale_record_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/models/expense/expense_category.dart';
import '../../../domain/models/product_item/product_item.dart';
import '../../widgets/app_background.dart';
import '../../widgets/owl_mascot.dart';

enum _EntryType { sale, expense }

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  _EntryType _type = _EntryType.sale;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productItemProvider.notifier).load();
      ref.read(expenseProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Nuevo registro',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const OwlMascot(scenario: OwlScenario.greeting, size: 110),
                const SizedBox(height: 16),
                _TypeToggle(
                  selected: _type,
                  onChanged: (t) => setState(() => _type = t),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _type == _EntryType.sale
                      ? const _SaleForm(key: ValueKey('sale'))
                      : const _ExpenseForm(key: ValueKey('expense')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Toggle ───────────────────────────────────────────────────────────────────

class _TypeToggle extends StatelessWidget {
  final _EntryType selected;
  final void Function(_EntryType) onChanged;

  const _TypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.cardBorder.withValues(alpha: 0.50),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          _ToggleBtn(
            icon: Icons.trending_up_rounded,
            label: 'Ingreso / Venta',
            selected: selected == _EntryType.sale,
            color: AppTheme.successColor,
            onTap: () => onChanged(_EntryType.sale),
          ),
          _ToggleBtn(
            icon: Icons.trending_down_rounded,
            label: 'Gasto',
            selected: selected == _EntryType.expense,
            color: AppTheme.dangerColor,
            onTap: () => onChanged(_EntryType.expense),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: color.withValues(alpha: 0.45), width: 0.8)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? color : Colors.white38, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : Colors.white38,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sale form ────────────────────────────────────────────────────────────────

class _SaleForm extends ConsumerStatefulWidget {
  const _SaleForm({super.key});

  @override
  ConsumerState<_SaleForm> createState() => _SaleFormState();
}

class _SaleFormState extends ConsumerState<_SaleForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  ProductItem? _selectedProduct;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productItemProvider).items;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<ProductItem>(
            key: const Key('sale-product-dropdown'),
            // ignore: deprecated_member_use
            value: _selectedProduct,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Producto / servicio'),
            items: products.map((p) {
              return DropdownMenuItem(value: p, child: Text(p.title));
            }).toList(),
            onChanged: (p) {
              setState(() {
                _selectedProduct = p;
                if (p != null) _priceCtrl.text = p.salePrice.toString();
              });
            },
            validator: (v) => v == null ? 'Selecciona un producto' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('sale-quantity'),
                  controller: _quantityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1) return 'Inválido';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: const Key('sale-unit-price'),
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Precio unitario',
                    prefixText: '\$ ',
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Inválido';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DatePicker(date: _date, onPick: (d) => setState(() => _date = d)),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('sale-notes'),
            controller: _notesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Notas (opcional)'),
          ),
          const SizedBox(height: 28),
          _SaveButton(
            label: 'Registrar venta',
            color: AppTheme.successColor,
            onTap: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(saleRecordProvider.notifier)
        .save(
          productItemId: _selectedProduct!.id,
          productTitle: _selectedProduct!.title,
          quantity: int.parse(_quantityCtrl.text),
          unitPrice: double.parse(_priceCtrl.text),
          date: _date,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
    if (mounted) context.pop();
  }
}

// ─── Expense form ─────────────────────────────────────────────────────────────

class _ExpenseForm extends ConsumerStatefulWidget {
  const _ExpenseForm({super.key});

  @override
  ConsumerState<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<_ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.other;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            key: const Key('expense-description'),
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Descripción'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ingresa descripción' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('expense-amount'),
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monto',
              prefixText: '\$ ',
            ),
            validator: (v) {
              final n = double.tryParse(v ?? '');
              if (n == null || n <= 0) return 'Monto inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ExpenseCategory>(
            key: const Key('expense-category'),
            // ignore: deprecated_member_use
            value: _category,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Categoría'),
            items: ExpenseCategory.values.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat.label));
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _category = v);
            },
          ),
          const SizedBox(height: 16),
          _DatePicker(date: _date, onPick: (d) => setState(() => _date = d)),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('expense-notes'),
            controller: _notesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Notas (opcional)'),
          ),
          const SizedBox(height: 28),
          _SaveButton(
            label: 'Registrar gasto',
            color: AppTheme.dangerColor,
            onTap: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(expenseProvider.notifier)
        .save(
          description: _descCtrl.text.trim(),
          amount: double.parse(_amountCtrl.text),
          category: _category,
          date: _date,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
    if (mounted) context.pop();
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _DatePicker extends StatelessWidget {
  final DateTime date;
  final void Function(DateTime) onPick;

  const _DatePicker({required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.cardBorder.withValues(alpha: 0.80),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'Fecha: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white30,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SaveButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}
