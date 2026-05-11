import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/client/client.dart';
import '../../domain/usecase/client/get_all_clients_use_case.dart';
import '../../domain/usecase/client/save_client_use_case.dart';
import '../../domain/usecase/client/get_client_by_id_use_case.dart';
import '../../infrastructure/driven_adapters/client/client_hive_adapter.dart';

class ClientState {
  final List<Client> clients;
  final bool isLoading;
  final String? error;

  const ClientState({
    this.clients = const [],
    this.isLoading = false,
    this.error,
  });

  ClientState copyWith({
    List<Client>? clients,
    bool? isLoading,
    String? error,
  }) {
    return ClientState(
      clients: clients ?? this.clients,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ClientNotifier extends StateNotifier<ClientState> {
  final GetAllClientsUseCase _getAll;
  final GetClientByIdUseCase _getById;
  final SaveClientUseCase _save;

  ClientNotifier(this._getAll, this._getById, this._save)
    : super(const ClientState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final clients = await _getAll.execute();
      state = state.copyWith(clients: clients, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> save(Client client) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _save.execute(client);
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Client?> getById(String id) => _getById.execute(id);

  String generateId() => const Uuid().v4();
}

final clientProvider = StateNotifierProvider<ClientNotifier, ClientState>((
  ref,
) {
  final adapter = ClientHiveAdapter();
  return ClientNotifier(
    GetAllClientsUseCase(adapter),
    GetClientByIdUseCase(adapter),
    SaveClientUseCase(adapter),
  );
});
