import '../additional_cost/additional_cost.dart';

class ProductItem {
  final String id;
  final String title;
  final String description;
  final double hourlyRate;
  final double estimatedHours;
  final List<AdditionalCost> additionalCosts;
  final double salePrice;
  final double profitMargin;
  final String? imageBase64;
  final DateTime createdAt;

  const ProductItem({
    required this.id,
    required this.title,
    required this.description,
    required this.hourlyRate,
    required this.estimatedHours,
    required this.additionalCosts,
    required this.salePrice,
    required this.profitMargin,
    this.imageBase64,
    required this.createdAt,
  });

  ProductItem copyWith({
    String? id,
    String? title,
    String? description,
    double? hourlyRate,
    double? estimatedHours,
    List<AdditionalCost>? additionalCosts,
    double? salePrice,
    double? profitMargin,
    String? imageBase64,
    bool clearImage = false,
    DateTime? createdAt,
  }) {
    return ProductItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      additionalCosts: additionalCosts ?? this.additionalCosts,
      salePrice: salePrice ?? this.salePrice,
      profitMargin: profitMargin ?? this.profitMargin,
      imageBase64: clearImage ? null : imageBase64 ?? this.imageBase64,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
