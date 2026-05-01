import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers/expense_provider.dart';
import '../../../domain/models/expense/expense_category.dart';
import '../../widgets/retro_background.dart';

class ExpenseFormPage extends ConsumerStatefulWidget {
  final String? expenseId;

  const ExpenseFormPage({super.key, this.expenseId});

  @override
  ConsumerState<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends ConsumerState<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  DateTime _selectedDate = DateTime.now();
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(expenseProvider.notifier).load();
      _loadExisting();
    });
  }

  void _loadExisting() {
    if (widget.expenseId == null) return;
    final expenses = ref.read(expenseProvider).expenses;
    final existing = expenses
        .where((e) => e.id == widget.expenseId)
        .firstOrNull;
    if (existing == null) return;

    setState(() {
      _isEdit = true;
      _descriptionController.text = existing.description;
      _amountController.text = existing.amount.toString();
      _notesController.text = existing.notes ?? '';
      _selectedCategory = existing.category;
      _selectedDate = existing.date;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar gasto' : 'Registrar gasto')),
      body: RetroBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Description
                TextFormField(
                  key: const Key('expense-description'),
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa una descripción'
                      : null,
                ),
                const SizedBox(height: 16),
                // Amount
                TextFormField(
                  key: const Key('expense-amount'),
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Ingresa un monto válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Category
                DropdownButtonFormField<ExpenseCategory>(
                  key: const Key('expense-category'),
                  // ignore: deprecated_member_use
                  value: _selectedCategory,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    filled: true,
                    fillColor: Colors.white10,
                  ),
                  items: ExpenseCategory.values.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat.label));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedCategory = v);
                  },
                ),
                const SizedBox(height: 16),
                // Date picker
                ListTile(
                  key: const Key('expense-date'),
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
                  key: const Key('expense-notes'),
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
                  key: const Key('expense-save-btn'),
                  onPressed: _save,
                  child: Text(_isEdit ? 'Actualizar gasto' : 'Registrar gasto'),
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

    await ref
        .read(expenseProvider.notifier)
        .save(
          existingId: widget.expenseId,
          description: _descriptionController.text.trim(),
          amount: double.parse(_amountController.text),
          category: _selectedCategory,
          date: _selectedDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

    if (mounted) context.pop();
  }
}
