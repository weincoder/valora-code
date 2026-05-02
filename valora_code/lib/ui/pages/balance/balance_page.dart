import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/providers/balance_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/models/balance/balance_report.dart';
import '../../widgets/owl_mascot.dart';

class BalancePage extends ConsumerWidget {
  const BalancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(balanceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Balance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OwlBalanceHeader(report: report),
            const SizedBox(height: 16),
            _SummaryGrid(report: report),
            const SizedBox(height: 28),
            const Text(
              'Ingresos mensuales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _MonthlyBarChart(
              key: const Key('monthly-revenue-chart'),
              monthlyData: report.monthlyRevenue,
              barColor: AppTheme.successColor,
              emptyLabel: 'Sin ingresos mensuales',
            ),
            const SizedBox(height: 28),
            const Text(
              'Gastos mensuales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _MonthlyBarChart(
              key: const Key('monthly-expenses-chart'),
              monthlyData: report.monthlyExpenses,
              barColor: AppTheme.dangerColor,
              emptyLabel: 'Sin gastos mensuales',
            ),
          ],
        ),
      ),
    );
  }
}

class _OwlBalanceHeader extends StatelessWidget {
  final BalanceReport report;
  const _OwlBalanceHeader({required this.report});

  @override
  Widget build(BuildContext context) {
    final isPositive = report.totalProfit >= 0;
    final scenario = isPositive ? OwlScenario.success : OwlScenario.working;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.cardBorder.withValues(alpha: 0.50),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          OwlMascot(scenario: scenario, size: 90),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPositive ? '¡Buen trabajo!' : 'Revisemos los números',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPositive
                      ? 'Tu negocio está generando utilidades 🎉'
                      : 'Hay oportunidades de mejora 📊',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final BalanceReport report;
  const _SummaryGrid({required this.report});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _SummaryCard(
          key: const Key('balance-revenue'),
          label: 'Ingresos totales',
          value: '\$${report.totalRevenue.toStringAsFixed(2)}',
          icon: Icons.trending_up,
          color: AppTheme.successColor,
        ),
        _SummaryCard(
          key: const Key('balance-expenses'),
          label: 'Gastos totales',
          value: '\$${report.totalExpenses.toStringAsFixed(2)}',
          icon: Icons.trending_down,
          color: AppTheme.dangerColor,
        ),
        _SummaryCard(
          key: const Key('balance-profit'),
          label: 'Ganancia neta',
          value: '\$${report.totalProfit.toStringAsFixed(2)}',
          icon: Icons.account_balance_wallet,
          color: const Color(0xFF9B8FF5),
        ),
        _SummaryCard(
          key: const Key('balance-margin'),
          label: 'Margen promedio',
          value: '${report.avgMargin.toStringAsFixed(1)}%',
          icon: Icons.pie_chart,
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final Map<int, double> monthlyData;
  final Color barColor;
  final String emptyLabel;

  const _MonthlyBarChart({
    super.key,
    required this.monthlyData,
    required this.barColor,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return Center(
        child: Text(emptyLabel, style: const TextStyle(color: Colors.white54)),
      );
    }

    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: _BarChartPainter(monthlyData: monthlyData, barColor: barColor),
        size: Size.infinite,
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final Map<int, double> monthlyData;
  final Color barColor;

  const _BarChartPainter({required this.monthlyData, required this.barColor});

  static const _monthNames = [
    '',
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  @override
  @override
  void paint(Canvas canvas, Size size) {
    if (monthlyData.isEmpty) return;

    final maxVal = monthlyData.values.reduce(max);
    if (maxVal == 0) return;

    final barPaint = Paint()..color = barColor;
    final textStyle = const TextStyle(fontSize: 9, color: Colors.grey);

    final entries = monthlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final barWidth = size.width / entries.length * 0.6;
    final spacing = size.width / entries.length;

    for (var i = 0; i < entries.length; i++) {
      final barHeight = (entries[i].value / maxVal) * (size.height - 24);
      final x = spacing * i + spacing * 0.2;
      final y = size.height - 20 - barHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        barPaint,
      );

      final label = entries[i].key >= 1 && entries[i].key <= 12
          ? _monthNames[entries[i].key]
          : entries[i].key.toString();
      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) =>
      oldDelegate.monthlyData != monthlyData;
}
