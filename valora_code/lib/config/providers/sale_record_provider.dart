import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/sale_record/sale_record.dart';
import '../../domain/usecase/sale_record/delete_sale_record_use_case.dart';
import '../../domain/usecase/sale_record/get_all_sale_records_use_case.dart';
import '../../domain/usecase/sale_record/save_sale_record_use_case.dart';
import '../../infrastructure/driven_adapters/sale_record/sale_record_hive_adapter.dart';

class SaleRecordState {
  final List<SaleRecord> records;
  final bool isLoading;
  final String? error;

  const SaleRecordState({
    this.records = const [],
    this.isLoading = false,
    this.error,
  });

  SaleRecordState copyWith({
    List<SaleRecord>? records,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SaleRecordState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class SaleRecordNotifier extends StateNotifier<SaleRecordState> {
  final GetAllSaleRecordsUseCase _getAll;
  final SaveSaleRecordUseCase _save;
  final DeleteSaleRecordUseCase _delete;

  SaleRecordNotifier({
    required GetAllSaleRecordsUseCase getAll,
    required SaveSaleRecordUseCase save,
    required DeleteSaleRecordUseCase delete,
  }) : _getAll = getAll,
       _save = save,
       _delete = delete,
       super(const SaleRecordState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final records = await _getAll.execute();
      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar las ventas',
      );
    }
  }

  Future<void> save({
    String? existingId,
    required String productItemId,
    required String productTitle,
    required int quantity,
    required double unitPrice,
    DateTime? date,
    String? notes,
  }) async {
    try {
      final record = SaleRecord(
        id: existingId ?? const Uuid().v4(),
        productItemId: productItemId,
        productTitle: productTitle,
        quantity: quantity,
        unitPrice: unitPrice,
        totalAmount: quantity * unitPrice,
        date: date ?? DateTime.now(),
        notes: notes,
      );
      await _save.execute(record);
      await load();
    } catch (e) {
      state = state.copyWith(error: 'Error al guardar la venta');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _delete.execute(id);
      await load();
    } catch (e) {
      state = state.copyWith(error: 'Error al eliminar la venta');
    }
  }
}

final saleRecordProvider =
    StateNotifierProvider<SaleRecordNotifier, SaleRecordState>((ref) {
      final gateway = SaleRecordHiveAdapter();
      return SaleRecordNotifier(
        getAll: GetAllSaleRecordsUseCase(gateway: gateway),
        save: SaveSaleRecordUseCase(gateway: gateway),
        delete: DeleteSaleRecordUseCase(gateway: gateway),
      );
    });
