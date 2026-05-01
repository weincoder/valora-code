import '../../models/balance/balance_report.dart';
import '../../models/expense/expense.dart';
import '../../models/sale_record/sale_record.dart';

class GetBalanceUseCase {
  BalanceReport execute(List<SaleRecord> sales, List<Expense> expenses) {
    if (sales.isEmpty && expenses.isEmpty) {
      return const BalanceReport(
        totalRevenue: 0,
        totalExpenses: 0,
        totalProfit: 0,
        avgMargin: 0,
        totalSales: 0,
        monthlyRevenue: {},
        monthlyExpenses: {},
      );
    }

    double totalRevenue = 0;
    final Map<int, double> monthlyRevenue = {};

    for (final s in sales) {
      totalRevenue += s.totalAmount;
      final month = s.date.month;
      monthlyRevenue[month] = (monthlyRevenue[month] ?? 0) + s.totalAmount;
    }

    double totalExpenses = 0;
    final Map<int, double> monthlyExpenses = {};

    for (final e in expenses) {
      totalExpenses += e.amount;
      final month = e.date.month;
      monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + e.amount;
    }

    final totalProfit = totalRevenue - totalExpenses;
    final avgMargin = totalRevenue > 0
        ? (totalProfit / totalRevenue) * 100
        : 0.0;

    return BalanceReport(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      totalProfit: totalProfit,
      avgMargin: avgMargin,
      totalSales: sales.length,
      monthlyRevenue: monthlyRevenue,
      monthlyExpenses: monthlyExpenses,
    );
  }
}
