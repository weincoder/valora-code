import '../expense/expense.dart';
import '../product_item/product_item.dart';
import '../sale_record/sale_record.dart';

class BackupData {
  final List<ProductItem> products;
  final List<SaleRecord> saleRecords;
  final List<Expense> expenses;
  final String version;
  final DateTime exportedAt;

  const BackupData({
    required this.products,
    required this.saleRecords,
    required this.expenses,
    required this.version,
    required this.exportedAt,
  });
}
