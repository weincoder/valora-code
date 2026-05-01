import '../../../domain/models/backup/backup_data.dart';
import '../../../domain/models/backup/gateway/backup_gateway.dart';
import '../../../domain/models/expense/gateway/expense_gateway.dart';
import '../../../domain/models/product_item/gateway/product_item_gateway.dart';
import '../../../domain/models/sale_record/gateway/sale_record_gateway.dart';
import '../../helpers/backup_serializer.dart';
import '../expense/expense_hive_adapter.dart';
import '../product_item/product_item_hive_adapter.dart';
import '../sale_record/sale_record_hive_adapter.dart';

class BackupLocalAdapter implements BackupGateway {
  final ProductItemGateway productItemGateway;
  final SaleRecordGateway saleRecordGateway;
  final ExpenseGateway expenseGateway;

  BackupLocalAdapter({
    required this.productItemGateway,
    required this.saleRecordGateway,
    required this.expenseGateway,
  });

  @override
  Future<String> exportToJson() async {
    final products = await productItemGateway.getAll();
    final saleRecords = await saleRecordGateway.getAll();
    final expenses = await expenseGateway.getAll();
    final data = BackupData(
      products: products,
      saleRecords: saleRecords,
      expenses: expenses,
      version: '2.0.0',
      exportedAt: DateTime.now(),
    );
    return BackupSerializer.serialize(data);
  }

  @override
  Future<void> importFromJson(String jsonContent) async {
    final data = BackupSerializer.deserialize(jsonContent);

    await _clearAllData();

    for (final product in data.products) {
      await productItemGateway.save(product);
    }
    for (final record in data.saleRecords) {
      await saleRecordGateway.save(record);
    }
    for (final expense in data.expenses) {
      await expenseGateway.save(expense);
    }
  }

  Future<void> _clearAllData() async {
    if (productItemGateway is ProductItemHiveAdapter) {
      await (productItemGateway as ProductItemHiveAdapter).clear();
    } else {
      final existing = await productItemGateway.getAll();
      for (final item in existing) {
        await productItemGateway.delete(item.id);
      }
    }

    if (saleRecordGateway is SaleRecordHiveAdapter) {
      await (saleRecordGateway as SaleRecordHiveAdapter).clear();
    } else {
      final existing = await saleRecordGateway.getAll();
      for (final item in existing) {
        await saleRecordGateway.delete(item.id);
      }
    }

    if (expenseGateway is ExpenseHiveAdapter) {
      await (expenseGateway as ExpenseHiveAdapter).clear();
    } else {
      final existing = await expenseGateway.getAll();
      for (final item in existing) {
        await expenseGateway.delete(item.id);
      }
    }
  }
}
