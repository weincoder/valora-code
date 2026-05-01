import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/product/product.dart';
import '../../domain/models/product/product_exception.dart';
import '../../domain/usecase/calculate_profit_margin_use_case.dart';
import '../../infrastructure/driven_adapters/product/product_adapter.dart';

class ProductState {
  final double? profitMargin;
  final bool isLoading;
  final String? errorMessage;

  const ProductState({
    this.profitMargin,
    this.isLoading = false,
    this.errorMessage,
  });

  ProductState copyWith({
    double? profitMargin,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearMargin = false,
  }) {
    return ProductState(
      profitMargin: clearMargin ? null : profitMargin ?? this.profitMargin,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final CalculateProfitMarginUseCase useCase;

  ProductNotifier({required this.useCase}) : super(const ProductState());

  void calculate(double productionCost, double salePrice) {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearMargin: true,
    );
    try {
      final product = Product(
        productionCost: productionCost,
        salePrice: salePrice,
      );
      final margin = useCase.execute(product);
      state = ProductState(profitMargin: margin, isLoading: false);
    } on ProductException catch (e) {
      state = ProductState(errorMessage: e.message, isLoading: false);
    } catch (_) {
      state = const ProductState(
        errorMessage: 'Ocurrió un error inesperado',
        isLoading: false,
      );
    }
  }
}

final productNotifierProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
      final adapter = ProductAdapter();
      final useCase = CalculateProfitMarginUseCase(gateway: adapter);
      return ProductNotifier(useCase: useCase);
    });
