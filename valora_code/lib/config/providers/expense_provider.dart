import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/expense/expense.dart';
import '../../domain/usecase/expense/delete_expense_use_case.dart';
import '../../domain/usecase/expense/get_all_expenses_use_case.dart';
import '../../domain/usecase/expense/save_expense_use_case.dart';
import '../../infrastructure/driven_adapters/expense/expense_hive_adapter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/expense/expense_category.dart';

class ExpenseState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;

  const ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
  });

  ExpenseState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final GetAllExpensesUseCase _getAll;
  final SaveExpenseUseCase _save;
  final DeleteExpenseUseCase _delete;

  ExpenseNotifier({
    required GetAllExpensesUseCase getAll,
    required SaveExpenseUseCase save,
    required DeleteExpenseUseCase delete,
  }) : _getAll = getAll,
       _save = save,
       _delete = delete,
       super(const ExpenseState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final expenses = await _getAll.execute();
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar los gastos',
      );
    }
  }

  Future<void> save({
    String? existingId,
    required String description,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    String? notes,
  }) async {
    try {
      final expense = Expense(
        id: existingId ?? const Uuid().v4(),
        description: description,
        amount: amount,
        category: category,
        date: date,
        notes: notes,
      );
      await _save.execute(expense);
      await load();
    } catch (e) {
      state = state.copyWith(error: 'Error al guardar el gasto');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _delete.execute(id);
      await load();
    } catch (e) {
      state = state.copyWith(error: 'Error al eliminar el gasto');
    }
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((
  ref,
) {
  final gateway = ExpenseHiveAdapter();
  return ExpenseNotifier(
    getAll: GetAllExpensesUseCase(gateway: gateway),
    save: SaveExpenseUseCase(gateway: gateway),
    delete: DeleteExpenseUseCase(gateway: gateway),
  );
});
