import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/friend/friend.dart';
import '../../domain/usecase/friend/delete_friend_use_case.dart';
import '../../domain/usecase/friend/get_all_friends_use_case.dart';
import '../../domain/usecase/friend/get_friend_by_id_use_case.dart';
import '../../domain/usecase/friend/save_friend_use_case.dart';
import '../../infrastructure/driven_adapters/friend/friend_hive_adapter.dart';

class FriendState {
  final List<Friend> friends;
  final bool isLoading;
  final String? error;

  const FriendState({
    this.friends = const [],
    this.isLoading = false,
    this.error,
  });

  FriendState copyWith({
    List<Friend>? friends,
    bool? isLoading,
    String? error,
  }) {
    return FriendState(
      friends: friends ?? this.friends,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FriendNotifier extends StateNotifier<FriendState> {
  final GetAllFriendsUseCase _getAll;
  final GetFriendByIdUseCase _getById;
  final SaveFriendUseCase _save;
  final DeleteFriendUseCase _delete;

  FriendNotifier(this._getAll, this._getById, this._save, this._delete)
    : super(const FriendState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final friends = await _getAll.execute();
      state = state.copyWith(friends: friends, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> save(Friend friend) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _save.execute(friend);
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> delete(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _delete.execute(id);
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Friend?> getById(String id) => _getById.execute(id);

  String generateId() => const Uuid().v4();
}

final friendProvider = StateNotifierProvider<FriendNotifier, FriendState>((
  ref,
) {
  final adapter = FriendHiveAdapter();
  return FriendNotifier(
    GetAllFriendsUseCase(adapter),
    GetFriendByIdUseCase(adapter),
    SaveFriendUseCase(adapter),
    DeleteFriendUseCase(adapter),
  );
});
