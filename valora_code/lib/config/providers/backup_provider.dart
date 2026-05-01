import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/usecase/backup/backup_use_case.dart';
import '../../infrastructure/driven_adapters/backup/backup_local_adapter.dart';
import '../../infrastructure/driven_adapters/expense/expense_hive_adapter.dart';
import '../../infrastructure/driven_adapters/product_item/product_item_hive_adapter.dart';
import '../../infrastructure/driven_adapters/sale_record/sale_record_hive_adapter.dart';
import 'expense_provider.dart';
import 'product_item_provider.dart';
import 'sale_record_provider.dart';

class BackupState {
  final bool isExporting;
  final bool isImporting;
  final String? error;
  final DateTime? lastBackup;

  const BackupState({
    this.isExporting = false,
    this.isImporting = false,
    this.error,
    this.lastBackup,
  });

  BackupState copyWith({
    bool? isExporting,
    bool? isImporting,
    String? error,
    bool clearError = false,
    DateTime? lastBackup,
  }) {
    return BackupState(
      isExporting: isExporting ?? this.isExporting,
      isImporting: isImporting ?? this.isImporting,
      error: clearError ? null : error ?? this.error,
      lastBackup: lastBackup ?? this.lastBackup,
    );
  }
}

class BackupNotifier extends StateNotifier<BackupState> {
  final BackupUseCase _useCase;
  final Ref _ref;

  BackupNotifier({required BackupUseCase useCase, required Ref ref})
    : _useCase = useCase,
      _ref = ref,
      super(const BackupState());

  Future<void> export({Rect? sharePositionOrigin}) async {
    state = state.copyWith(isExporting: true, clearError: true);
    try {
      final json = await _useCase.export();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/valora_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'ValoraCode — Backup',
        sharePositionOrigin: sharePositionOrigin,
      );
      state = state.copyWith(isExporting: false, lastBackup: DateTime.now());
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: 'Error al exportar el backup',
      );
    }
  }

  Future<void> import() async {
    state = state.copyWith(isImporting: true, clearError: true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) {
        state = state.copyWith(isImporting: false);
        return;
      }
      final content = await File(result.files.single.path!).readAsString();
      await _useCase.import(content);
      // UI RELOAD: refresh all relevant providers after successful import
      await _ref.read(productItemProvider.notifier).load();
      await _ref.read(saleRecordProvider.notifier).load();
      await _ref.read(expenseProvider.notifier).load();
      state = state.copyWith(isImporting: false, lastBackup: DateTime.now());
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        error: 'Error al importar el backup',
      );
    }
  }
}

final backupProvider = StateNotifierProvider<BackupNotifier, BackupState>((
  ref,
) {
  final productHive = ProductItemHiveAdapter();
  final saleHive = SaleRecordHiveAdapter();
  final expenseHive = ExpenseHiveAdapter();
  final backupAdapter = BackupLocalAdapter(
    productItemGateway: productHive,
    saleRecordGateway: saleHive,
    expenseGateway: expenseHive,
  );
  final useCase = BackupUseCase(gateway: backupAdapter);
  return BackupNotifier(useCase: useCase, ref: ref);
});
