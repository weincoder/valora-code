import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/additional_cost/additional_cost.dart';
import '../../domain/models/product_item/product_item.dart';
import '../../domain/usecase/product_item/calculate_product_price_use_case.dart';
import '../../domain/usecase/product_item/delete_product_item_use_case.dart';
import '../../domain/usecase/product_item/get_all_product_items_use_case.dart';
import '../../domain/usecase/product_item/save_product_item_use_case.dart';
import '../../infrastructure/driven_adapters/product_item/product_item_hive_adapter.dart';
import '../../domain/models/product/product.dart';
import '../../domain/usecase/calculate_profit_margin_use_case.dart';
import '../../infrastructure/driven_adapters/product/product_adapter.dart';

class ProductItemState {
  final List<ProductItem> items;
  final bool isLoading;
  final String? error;

  const ProductItemState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  ProductItemState copyWith({
    List<ProductItem>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProductItemState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ProductItemNotifier extends StateNotifier<ProductItemState> {
  final GetAllProductItemsUseCase _getAll;
  final SaveProductItemUseCase _save;
  final DeleteProductItemUseCase _delete;
  final CalculateProductPriceUseCase _calcPrice;
  final CalculateProfitMarginUseCase _calcMargin;
  final _uuid = const Uuid();

  ProductItemNotifier({
    required GetAllProductItemsUseCase getAll,
    required SaveProductItemUseCase save,
    required DeleteProductItemUseCase delete,
    required CalculateProductPriceUseCase calcPrice,
    required CalculateProfitMarginUseCase calcMargin,
  }) : _getAll = getAll,
       _save = save,
       _delete = delete,
       _calcPrice = calcPrice,
       _calcMargin = calcMargin,
       super(const ProductItemState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _getAll.execute();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar productos',
      );
    }
  }

  Future<void> save({
    String? existingId,
    required String title,
    required String description,
    required double hourlyRate,
    required double estimatedHours,
    required List<AdditionalCost> additionalCosts,
    required double salePrice,
    String? imageBase64,
  }) async {
    final totalCost = _calcPrice.execute(
      hourlyRate: hourlyRate,
      estimatedHours: estimatedHours,
      additionalCosts: additionalCosts,
    );
    final product = Product(productionCost: totalCost, salePrice: salePrice);
    double margin = 0;
    try {
      margin = _calcMargin.execute(product);
    } catch (_) {
      margin = 0;
    }

    final item = ProductItem(
      id: existingId ?? _uuid.v4(),
      title: title,
      description: description,
      hourlyRate: hourlyRate,
      estimatedHours: estimatedHours,
      additionalCosts: additionalCosts,
      salePrice: salePrice,
      profitMargin: margin,
      imageBase64: imageBase64,
      createdAt: DateTime.now(),
    );

    try {
      await _save.execute(item);
      await load();
    } catch (e) {
      state = state.copyWith(error: 'Error al guardar el producto');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _delete.execute(id);
      await load();
    } catch (e) {
      state = state.copyWith(error: 'Error al eliminar el producto');
    }
  }
}

final productItemProvider =
    StateNotifierProvider<ProductItemNotifier, ProductItemState>((ref) {
      final hiveAdapter = ProductItemHiveAdapter();
      final marginAdapter = ProductAdapter();
      return ProductItemNotifier(
        getAll: GetAllProductItemsUseCase(gateway: hiveAdapter),
        save: SaveProductItemUseCase(gateway: hiveAdapter),
        delete: DeleteProductItemUseCase(gateway: hiveAdapter),
        calcPrice: CalculateProductPriceUseCase(),
        calcMargin: CalculateProfitMarginUseCase(gateway: marginAdapter),
      );
    });
