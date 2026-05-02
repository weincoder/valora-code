import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/providers/balance_provider.dart';
import '../../../config/providers/expense_provider.dart';
import '../../../config/providers/product_item_provider.dart';
import '../../../config/providers/sale_record_provider.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/models/balance/balance_report.dart';
import '../../widgets/owl_mascot.dart';
import '../../widgets/product_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productItemProvider.notifier).load();
      ref.read(saleRecordProvider.notifier).load();
      ref.read(expenseProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productItemProvider);
    final balance = ref.watch(balanceProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _TopBar(onBackupTap: () => context.push(AppRouter.backup)),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const _GreetingText(),
                  const SizedBox(height: 20),
                  _BalanceCard(balance: balance),
                  const SizedBox(height: 20),
                  _QuickActions(
                    onNewSale: () => context.push(AppRouter.register),
                    onNewExpense: () {
                      context.push(AppRouter.register);
                    },
                    onQuotation: () => context.push(AppRouter.quotation),
                  ),
                  const SizedBox(height: 24),
                  _ActivitySection(balance: balance),
                  const SizedBox(height: 24),
                  _ProductsSection(
                    state: productsState,
                    onProductTap: (id) => context.push('/product/$id'),
                    onAdd: () => context.push(AppRouter.productNew),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBackupTap;

  const _TopBar({required this.onBackupTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 8, 10),
        child: Row(
          children: [
            const Icon(Icons.menu_rounded, color: Colors.white70, size: 22),
            const SizedBox(width: 12),
            const Text(
              'ValoraCode',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            _VersionBadge(),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.cloud_upload_outlined,
                color: Colors.white60,
                size: 22,
              ),
              onPressed: onBackupTap,
              tooltip: 'Backup',
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white60,
                size: 22,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.45),
          width: 0.8,
        ),
      ),
      child: Text(
        'v1.0',
        style: TextStyle(
          color: AppTheme.accentColor.withValues(alpha: 0.90),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── Greeting ─────────────────────────────────────────────────────────────────

class _GreetingText extends StatelessWidget {
  const _GreetingText();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? '¡Buenos días!'
        : hour < 18
        ? '¡Buenas tardes!'
        : '¡Buenas noches!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 5),
        const Text(
          '¡Estás construyendo algo\nincreíble! 🚀',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

// ─── Balance hero card ────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final BalanceReport balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final isPositive = balance.totalProfit >= 0;
    final trendColor = isPositive
        ? AppTheme.successColor
        : AppTheme.dangerColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1CA8), Color(0xFF1A0047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4A38CC).withValues(alpha: 0.50),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4233CE).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Utilidad del período',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${balance.totalProfit.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: trendColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${balance.avgMargin.toStringAsFixed(1)}% margen · '
                      '${balance.totalSales} ventas',
                      style: TextStyle(color: trendColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const OwlMascot(scenario: OwlScenario.greeting, size: 82),
        ],
      ),
    );
  }
}

// ─── Quick actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final VoidCallback onNewSale;
  final VoidCallback onNewExpense;
  final VoidCallback onQuotation;

  const _QuickActions({
    required this.onNewSale,
    required this.onNewExpense,
    required this.onQuotation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionChip(
          icon: Icons.point_of_sale_rounded,
          label: 'Nueva\nventa',
          onTap: onNewSale,
        ),
        const SizedBox(width: 10),
        _ActionChip(
          icon: Icons.receipt_long_rounded,
          label: 'Nuevo\ngasto',
          onTap: onNewExpense,
        ),
        const SizedBox(width: 10),
        _ActionChip(
          icon: Icons.picture_as_pdf_rounded,
          label: 'Cotización\nPDF',
          onTap: onQuotation,
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.cardBorder.withValues(alpha: 0.55),
              width: 0.8,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF7B6FEA), size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Activity metrics ─────────────────────────────────────────────────────────

class _ActivitySection extends StatelessWidget {
  final BalanceReport balance;

  const _ActivitySection({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Tu Actividad',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go(AppRouter.balance),
              child: Text(
                'Ver todo  →',
                style: TextStyle(
                  color: AppTheme.accentColor.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Ingresos',
                value: '\$${balance.totalRevenue.toStringAsFixed(0)}',
                subLabel: '${balance.totalSales} ventas',
                icon: Icons.trending_up_rounded,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Gastos',
                value: '\$${balance.totalExpenses.toStringAsFixed(0)}',
                subLabel: 'período actual',
                icon: Icons.trending_down_rounded,
                color: AppTheme.dangerColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subLabel;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.cardBorder.withValues(alpha: 0.50),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subLabel,
                  style: TextStyle(color: color, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Products section ─────────────────────────────────────────────────────────

class _ProductsSection extends StatelessWidget {
  final ProductItemState state;
  final void Function(String id) onProductTap;
  final VoidCallback onAdd;

  const _ProductsSection({
    required this.state,
    required this.onProductTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Productos / Servicios',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onAdd,
              child: Text(
                '+ Agregar',
                style: TextStyle(
                  color: AppTheme.accentColor.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (state.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (state.error != null)
          Center(
            child: Text(
              state.error!,
              key: const Key('home-error-text'),
              style: const TextStyle(color: Colors.redAccent),
            ),
          )
        else if (state.items.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: OwlMascot(
                key: const Key('home-empty-text'),
                scenario: OwlScenario.empty,
                size: 150,
                label: 'Sin productos todavía.\nToca "+ Agregar" para empezar.',
              ),
            ),
          )
        else ...[
          ...state.items
              .take(4)
              .map(
                (product) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ProductCard(
                    product: product,
                    onTap: () => onProductTap(product.id),
                  ),
                ),
              ),
          if (state.items.length > 4)
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Ver todos (${state.items.length})  →',
                  style: TextStyle(
                    color: AppTheme.accentColor.withValues(alpha: 0.80),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
