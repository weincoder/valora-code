import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/issuer_config/issuer_config.dart';
import '../../domain/usecase/issuer_config/get_issuer_config_use_case.dart';
import '../../domain/usecase/issuer_config/save_issuer_config_use_case.dart';
import '../../infrastructure/driven_adapters/issuer_config/issuer_config_hive_adapter.dart';

class IssuerConfigState {
  final IssuerConfig? config;
  final bool isLoading;
  final String? error;

  const IssuerConfigState({this.config, this.isLoading = false, this.error});

  IssuerConfigState copyWith({
    IssuerConfig? config,
    bool? isLoading,
    String? error,
  }) {
    return IssuerConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class IssuerConfigNotifier extends StateNotifier<IssuerConfigState> {
  final GetIssuerConfigUseCase _getUseCase;
  final SaveIssuerConfigUseCase _saveUseCase;

  IssuerConfigNotifier(this._getUseCase, this._saveUseCase)
    : super(const IssuerConfigState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final config = await _getUseCase.execute();
      state = state.copyWith(config: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> save(IssuerConfig config) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _saveUseCase.execute(config);
      state = state.copyWith(config: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final issuerConfigProvider =
    StateNotifierProvider<IssuerConfigNotifier, IssuerConfigState>((ref) {
      final adapter = IssuerConfigHiveAdapter();
      return IssuerConfigNotifier(
        GetIssuerConfigUseCase(adapter),
        SaveIssuerConfigUseCase(adapter),
      );
    });
