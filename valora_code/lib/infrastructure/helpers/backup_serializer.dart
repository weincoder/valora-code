import 'dart:convert';
import '../../../domain/models/additional_cost/additional_cost.dart';
import '../../../domain/models/backup/backup_data.dart';
import '../../../domain/models/expense/expense.dart';
import '../../../domain/models/product_item/product_item.dart';
import '../../../domain/models/sale_record/sale_record.dart';
import 'mappers/expense_mapper.dart';
import 'mappers/sale_record_mapper.dart';

class BackupSerializer {
  BackupSerializer._();

  static String serialize(BackupData data) {
    final map = {
      'version': data.version,
      'exportedAt': data.exportedAt.toIso8601String(),
      'products': data.products.map(_productToMap).toList(),
      'saleRecords': data.saleRecords.map(saleRecordToJson).toList(),
      'expenses': data.expenses.map(expenseToJson).toList(),
    };
    return jsonEncode(map);
  }

  static BackupData deserialize(String jsonContent) {
    final map = jsonDecode(jsonContent) as Map<String, dynamic>;
    return BackupData(
      version: map['version'] as String? ?? '1.0.0',
      exportedAt:
          DateTime.tryParse(map['exportedAt'] as String? ?? '') ??
          DateTime.now(),
      products: _deserializeProducts(map['products'] as List<dynamic>? ?? []),
      saleRecords: _deserializeSaleRecords(
        map['saleRecords'] as List<dynamic>? ?? [],
      ),
      expenses: _deserializeExpenses(map['expenses'] as List<dynamic>? ?? []),
    );
  }

  static Map<String, dynamic> _productToMap(ProductItem p) => {
    'id': p.id,
    'title': p.title,
    'description': p.description,
    'hourlyRate': p.hourlyRate,
    'estimatedHours': p.estimatedHours,
    'salePrice': p.salePrice,
    'profitMargin': p.profitMargin,
    'imageBase64': p.imageBase64,
    'createdAt': p.createdAt.toIso8601String(),
    'additionalCosts': p.additionalCosts.map(_costToMap).toList(),
  };

  static Map<String, dynamic> _costToMap(AdditionalCost c) => {
    'label': c.label,
    'amount': c.amount,
  };

  static List<ProductItem> _deserializeProducts(List<dynamic> list) {
    return list.map((e) => _productFromMap(e as Map<String, dynamic>)).toList();
  }

  static ProductItem _productFromMap(Map<String, dynamic> map) {
    final imageRaw = map['imageBase64'] as String?;
    final imageBase64 =
        (imageRaw != null && imageRaw.length < 500 && imageRaw.startsWith('/'))
        ? null
        : imageRaw;

    return ProductItem(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Sin título',
      description: map['description'] as String? ?? '',
      hourlyRate: (map['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      estimatedHours: (map['estimatedHours'] as num?)?.toDouble() ?? 0.0,
      salePrice: (map['salePrice'] as num?)?.toDouble() ?? 0.0,
      profitMargin: (map['profitMargin'] as num?)?.toDouble() ?? 0.0,
      imageBase64: imageBase64,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      additionalCosts: _deserializeCosts(
        map['additionalCosts'] as List<dynamic>? ?? [],
      ),
    );
  }

  static List<AdditionalCost> _deserializeCosts(List<dynamic> list) {
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return AdditionalCost(
        label: map['label'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  static List<SaleRecord> _deserializeSaleRecords(List<dynamic> list) {
    return list
        .map((e) => saleRecordFromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Expense> _deserializeExpenses(List<dynamic> list) {
    return list.map((e) => expenseFromJson(e as Map<String, dynamic>)).toList();
  }
}
