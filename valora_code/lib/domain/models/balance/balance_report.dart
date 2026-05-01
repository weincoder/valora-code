class BalanceReport {
  final double totalRevenue;
  final double totalExpenses;
  final double totalProfit;
  final double avgMargin;
  final int totalSales;
  final Map<int, double> monthlyRevenue;
  final Map<int, double> monthlyExpenses;

  const BalanceReport({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalProfit,
    required this.avgMargin,
    required this.totalSales,
    required this.monthlyRevenue,
    required this.monthlyExpenses,
  });
}
