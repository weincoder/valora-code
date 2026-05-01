import 'package:flutter_test/flutter_test.dart';
import 'package:valora_code/domain/models/expense/expense.dart';
import 'package:valora_code/domain/models/expense/expense_category.dart';
import 'package:valora_code/domain/models/sale_record/sale_record.dart';
import 'package:valora_code/domain/usecase/balance/get_balance_use_case.dart';

SaleRecord _makeSale({
  String id = '1',
  double totalAmount = 500.0,
  DateTime? date,
}) {
  return SaleRecord(
    id: id,
    productItemId: 'prod-$id',
    productTitle: 'Producto $id',
    quantity: 1,
    unitPrice: totalAmount,
    totalAmount: totalAmount,
    date: date ?? DateTime(2025, 1, 15),
  );
}

Expense _makeExpense({String id = '1', double amount = 100.0, DateTime? date}) {
  return Expense(
    id: id,
    description: 'Gasto $id',
    amount: amount,
    category: ExpenseCategory.other,
    date: date ?? DateTime(2025, 1, 20),
  );
}

void main() {
  late GetBalanceUseCase useCase;

  setUp(() {
    useCase = GetBalanceUseCase();
  });

  group('execute', () {
    test('should return empty BalanceReport when both lists are empty', () {
      // Arrange
      const sales = <SaleRecord>[];
      const expenses = <Expense>[];

      // Act
      final result = useCase.execute(sales, expenses);

      // Assert
      expect(result.totalRevenue, equals(0));
      expect(result.totalExpenses, equals(0));
      expect(result.totalProfit, equals(0));
      expect(result.avgMargin, equals(0));
      expect(result.totalSales, equals(0));
      expect(result.monthlyRevenue, isEmpty);
      expect(result.monthlyExpenses, isEmpty);
    });

    test('should calculate totals correctly for sales and expenses', () {
      // Arrange
      final sales = [
        _makeSale(id: '1', totalAmount: 400.0, date: DateTime(2025, 1, 15)),
        _makeSale(id: '2', totalAmount: 600.0, date: DateTime(2025, 1, 20)),
      ];
      final expenses = [
        _makeExpense(id: '1', amount: 200.0, date: DateTime(2025, 1, 10)),
        _makeExpense(id: '2', amount: 150.0, date: DateTime(2025, 2, 5)),
      ];

      // Act
      final result = useCase.execute(sales, expenses);

      // Assert
      expect(result.totalRevenue, equals(1000.0));
      expect(result.totalExpenses, equals(350.0));
      expect(result.totalProfit, equals(650.0));
      expect(result.totalSales, equals(2));
      expect(result.avgMargin, closeTo(65.0, 0.01));
    });

    test('should group monthly revenue and expenses by month', () {
      // Arrange
      final sales = [
        _makeSale(id: '1', totalAmount: 100.0, date: DateTime(2025, 1, 1)),
        _makeSale(id: '2', totalAmount: 200.0, date: DateTime(2025, 3, 1)),
        _makeSale(id: '3', totalAmount: 150.0, date: DateTime(2025, 1, 15)),
      ];
      final expenses = [
        _makeExpense(id: '1', amount: 50.0, date: DateTime(2025, 1, 5)),
        _makeExpense(id: '2', amount: 80.0, date: DateTime(2025, 3, 10)),
      ];

      // Act
      final result = useCase.execute(sales, expenses);

      // Assert
      expect(result.monthlyRevenue[1], equals(250.0));
      expect(result.monthlyRevenue[3], equals(200.0));
      expect(result.monthlyRevenue.containsKey(2), isFalse);
      expect(result.monthlyExpenses[1], equals(50.0));
      expect(result.monthlyExpenses[3], equals(80.0));
    });
  });
}
