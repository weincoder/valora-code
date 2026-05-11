import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/client/client.dart';
import '../../domain/models/invoice/invoice.dart';
import '../../domain/models/invoice/invoice_line.dart';
import '../../domain/usecase/invoice/create_invoice_use_case.dart';
import '../../domain/usecase/invoice/get_all_invoices_use_case.dart';
import '../../domain/usecase/invoice/get_invoice_by_id_use_case.dart';
import '../../infrastructure/driven_adapters/invoice/invoice_hive_adapter.dart';
import '../../infrastructure/driven_adapters/issuer_config/issuer_config_hive_adapter.dart';

class InvoiceState {
  final List<Invoice> invoices;
  final List<InvoiceLine> draftLines;
  final String? selectedClientId;
  final bool isLoading;
  final String? error;

  const InvoiceState({
    this.invoices = const [],
    this.draftLines = const [],
    this.selectedClientId,
    this.isLoading = false,
    this.error,
  });

  InvoiceState copyWith({
    List<Invoice>? invoices,
    List<InvoiceLine>? draftLines,
    String? selectedClientId,
    bool clearSelectedClient = false,
    bool? isLoading,
    String? error,
  }) {
    return InvoiceState(
      invoices: invoices ?? this.invoices,
      draftLines: draftLines ?? this.draftLines,
      selectedClientId: clearSelectedClient
          ? null
          : selectedClientId ?? this.selectedClientId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class InvoiceNotifier extends StateNotifier<InvoiceState> {
  final CreateInvoiceUseCase _create;
  final GetAllInvoicesUseCase _getAll;
  final GetInvoiceByIdUseCase _getById;

  InvoiceNotifier(this._create, this._getAll, this._getById)
    : super(const InvoiceState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final invoices = await _getAll.execute();
      state = state.copyWith(invoices: invoices, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectClient(String clientId) {
    state = state.copyWith(selectedClientId: clientId);
  }

  void addLine(InvoiceLine line) {
    state = state.copyWith(draftLines: [...state.draftLines, line]);
  }

  void removeLine(int index) {
    final updated = List<InvoiceLine>.from(state.draftLines)..removeAt(index);
    state = state.copyWith(draftLines: updated);
  }

  void clearDraft() {
    state = state.copyWith(draftLines: const [], clearSelectedClient: true);
  }

  Future<void> createInvoice(Client client) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _create.execute(client: client, lines: state.draftLines);
      clearDraft();
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Invoice?> getById(String id) => _getById.execute(id);
}

final invoiceProvider = StateNotifierProvider<InvoiceNotifier, InvoiceState>((
  ref,
) {
  final invoiceAdapter = InvoiceHiveAdapter();
  final issuerAdapter = IssuerConfigHiveAdapter();
  return InvoiceNotifier(
    CreateInvoiceUseCase(invoiceAdapter, issuerAdapter),
    GetAllInvoicesUseCase(invoiceAdapter),
    GetInvoiceByIdUseCase(invoiceAdapter),
  );
});
