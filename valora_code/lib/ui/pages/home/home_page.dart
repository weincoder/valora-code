import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers/product_item_provider.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/theme/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/retro_background.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(productItemProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productItemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ValoraCode'),
        actions: [
          IconButton(
            key: const Key('nav-sales'),
            icon: const Icon(Icons.point_of_sale),
            tooltip: 'Ventas',
            onPressed: () => context.push(AppRouter.saleList),
          ),
          IconButton(
            key: const Key('nav-expenses'),
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Gastos',
            onPressed: () => context.push(AppRouter.expenseList),
          ),
          IconButton(
            key: const Key('nav-balance'),
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Balance',
            onPressed: () => context.push(AppRouter.balance),
          ),
          IconButton(
            key: const Key('nav-quotation'),
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Cotización PDF',
            onPressed: () => context.push(AppRouter.quotation),
          ),
          IconButton(
            key: const Key('nav-backup'),
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Backup',
            onPressed: () => context.push(AppRouter.backup),
          ),
        ],
      ),
      body: RetroBackground(child: _buildBody(state)),
      floatingActionButton: FloatingActionButton(
        key: const Key('fab-new-product'),
        backgroundColor: AppTheme.accentColor,
        onPressed: () => context.push(AppRouter.productNew),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(ProductItemState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          key: const Key('home-error-text'),
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (state.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay productos aún.\nPresiona + para agregar uno.',
              key: Key('home-empty-text'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      key: const Key('products-list'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final product = state.items[index];
        return ProductCard(
          product: product,
          onTap: () => context.push('/product/${product.id}'),
        );
      },
    );
  }
}
