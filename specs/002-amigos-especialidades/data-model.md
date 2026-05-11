# Data Model: Gestión de Amigos y Especialidades

**Feature**: `002-amigos-especialidades`  
**Date**: 2026-05-10  
**Layer**: Domain (pure Dart) + Infrastructure (Hive serialization)

---

## Entidad: `Friend`

Representa un colega o contacto del directorio de talento personal.

```dart
// lib/domain/models/friend/friend.dart
class Friend {
  final String id;               // UUID v4, generado en el provider
  final String fullName;         // Obligatorio, trim != ''
  final List<String> knowledgeAreas; // Etiquetas libres, puede ser vacía
  final double hourlyRate;       // >= 0.0, en la moneda indicada por currency
  final String currency;         // 'COP' | 'USD'
  final String? imageBase64;     // Foto opcional (base64, compresión 70%)

  const Friend({
    required this.id,
    required this.fullName,
    required this.knowledgeAreas,
    required this.hourlyRate,
    required this.currency,
    this.imageBase64,
  });

  Friend copyWith({
    String? id,
    String? fullName,
    List<String>? knowledgeAreas,
    double? hourlyRate,
    String? currency,
    String? imageBase64,
    bool clearImage = false,
  }) => Friend(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    knowledgeAreas: knowledgeAreas ?? this.knowledgeAreas,
    hourlyRate: hourlyRate ?? this.hourlyRate,
    currency: currency ?? this.currency,
    imageBase64: clearImage ? null : imageBase64 ?? this.imageBase64,
  );
}
```

### Reglas de negocio (validadas en `SaveFriendUseCase`)

| Campo | Regla |
|---|---|
| `fullName` | `trim().isNotEmpty` — obligatorio |
| `hourlyRate` | `>= 0.0` — no negativo |
| `currency` | `'COP'` o `'USD'` — enum de string |
| `knowledgeAreas` | Sin validación — puede ser lista vacía |
| `imageBase64` | Sin validación — nullable |
| Duplicados de nombre | Permitidos — no hay restricción de unicidad |

---

## Excepción: `FriendException`

```dart
// lib/domain/models/friend/friend_exception.dart
class FriendException implements Exception {
  final String message;
  const FriendException(this.message);

  @override
  String toString() => 'FriendException: $message';
}
```

Lanzada por `SaveFriendUseCase` cuando las reglas de negocio no se cumplen.

---

## Gateway (contrato de persistencia): `FriendGateway`

```dart
// lib/domain/models/friend/gateway/friend_gateway.dart
abstract class FriendGateway {
  Future<List<Friend>> getAll();
  Future<Friend?> getById(String id);
  Future<void> save(Friend friend);
  Future<void> delete(String id);
}
```

---

## Casos de uso

### `GetAllFriendsUseCase`
```dart
// lib/domain/usecase/friend/get_all_friends_use_case.dart
class GetAllFriendsUseCase {
  final FriendGateway _gateway;
  GetAllFriendsUseCase(this._gateway);
  Future<List<Friend>> execute() => _gateway.getAll();
}
```

### `GetFriendByIdUseCase`
```dart
// lib/domain/usecase/friend/get_friend_by_id_use_case.dart
class GetFriendByIdUseCase {
  final FriendGateway _gateway;
  GetFriendByIdUseCase(this._gateway);
  Future<Friend?> execute(String id) => _gateway.getById(id);
}
```

### `SaveFriendUseCase`
```dart
// lib/domain/usecase/friend/save_friend_use_case.dart
class SaveFriendUseCase {
  final FriendGateway _gateway;
  SaveFriendUseCase(this._gateway);

  static const _validCurrencies = {'COP', 'USD'};

  Future<void> execute(Friend friend) async {
    if (friend.fullName.trim().isEmpty) {
      throw const FriendException('El nombre es requerido');
    }
    if (friend.hourlyRate < 0) {
      throw const FriendException('El valor por hora no puede ser negativo');
    }
    if (!_validCurrencies.contains(friend.currency)) {
      throw const FriendException('La moneda debe ser COP o USD');
    }
    await _gateway.save(friend);
  }
}
```

### `DeleteFriendUseCase`
```dart
// lib/domain/usecase/friend/delete_friend_use_case.dart
class DeleteFriendUseCase {
  final FriendGateway _gateway;
  DeleteFriendUseCase(this._gateway);
  Future<void> execute(String id) => _gateway.delete(id);
}
```

---

## Serialización Hive: `friend_mapper.dart`

```dart
// lib/infrastructure/helpers/mappers/friend_mapper.dart
import '../../../domain/models/friend/friend.dart';

Map<String, dynamic> friendToJson(Friend f) => {
  'id': f.id,
  'fullName': f.fullName,
  'knowledgeAreas': f.knowledgeAreas,
  'hourlyRate': f.hourlyRate,
  'currency': f.currency,
  'imageBase64': f.imageBase64,
};

Friend friendFromJson(Map<dynamic, dynamic> json) => Friend(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  knowledgeAreas: (json['knowledgeAreas'] as List? ?? [])
      .map((e) => e as String)
      .toList(),
  hourlyRate: (json['hourlyRate'] as num).toDouble(),
  currency: (json['currency'] as String?) ?? 'COP', // backward compat
  imageBase64: json['imageBase64'] as String?,
);
```

---

## Adaptador: `FriendHiveAdapter`

```dart
// lib/infrastructure/driven_adapters/friend/friend_hive_adapter.dart
class FriendHiveAdapter implements FriendGateway {
  static const String _boxName = 'friends';
  Box<Map> get _box => Hive.box<Map>(_boxName);

  @override Future<List<Friend>> getAll() async =>
      _box.values.map(friendFromJson).toList();

  @override Future<Friend?> getById(String id) async {
    final raw = _box.get(id);
    return raw == null ? null : friendFromJson(raw);
  }

  @override Future<void> save(Friend friend) async =>
      _box.put(friend.id, friendToJson(friend));

  @override Future<void> delete(String id) async =>
      _box.delete(id);
}
```

---

## Estado y Provider: `FriendNotifier` / `friendProvider`

```dart
// lib/config/providers/friend_provider.dart

class FriendState {
  final List<Friend> friends;
  final bool isLoading;
  final String? error;

  const FriendState({this.friends = const [], this.isLoading = false, this.error});
  FriendState copyWith({List<Friend>? friends, bool? isLoading, String? error}) => ...;
}

class FriendNotifier extends StateNotifier<FriendState> {
  final GetAllFriendsUseCase _getAll;
  final GetFriendByIdUseCase _getById;
  final SaveFriendUseCase _save;
  final DeleteFriendUseCase _delete;

  FriendNotifier(this._getAll, this._getById, this._save, this._delete)
    : super(const FriendState()) { load(); }

  Future<void> load() async { ... }
  Future<void> save(Friend friend) async { ... }
  Future<void> delete(String id) async { ... }
  Future<Friend?> getById(String id) => _getById.execute(id);
  String generateId() => const Uuid().v4();
}

final friendProvider = StateNotifierProvider<FriendNotifier, FriendState>((ref) {
  final adapter = FriendHiveAdapter();
  return FriendNotifier(
    GetAllFriendsUseCase(adapter),
    GetFriendByIdUseCase(adapter),
    SaveFriendUseCase(adapter),
    DeleteFriendUseCase(adapter),
  );
});
```

---

## Helper de formato de moneda (modificación)

```dart
// Añadir en lib/ui/widgets/invoice/currency_format_helper.dart
String formatCurrency(double amount, String currency) {
  if (currency == 'USD') {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: 'USD \$',
      decimalDigits: 2,
    ).format(amount);
  }
  // Default: COP
  return NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  ).format(amount);
}
```

---

## Rutas nuevas

| Constante | Path | Widget |
|---|---|---|
| `AppRouter.friends` | `/friends` | `FriendListPage` |
| `AppRouter.friendNew` | `/friends/new` | `FriendFormPage` |
| `AppRouter.friendEdit` | `/friends/:friendId` | `FriendFormPage(friendId: ...)` |

---

## Cambios de navegación shell (AppShell + AppRouter)

- `StatefulShellRoute` pasa de 4 a **5 ramas**
- Nueva rama índice 4: ruta `/friends` → `FriendListPage`
- `AppShell._tabs` añade: `_TabItem(icon: Icons.people_outline, label: 'Amigos')`
- `_AppBottomBar` Row: `[Inicio(0), Movimientos(1), FAB, Balance(2), Más(3), Amigos(4)]`

---

## Caja Hive nueva en `main.dart`

```dart
await Future.wait([
  Hive.openBox<Map>('clients'),
  Hive.openBox<Map>('issuer_config'),
  Hive.openBox<Map>('invoices'),
  Hive.openBox<Map>('friends'),   // ← NUEVA
]);
```

---

## Diagrama de relaciones de capas

```
┌─────────────────────────────────────────────────────────────┐
│ DOMAIN (pure Dart)                                          │
│  Friend · FriendException · FriendGateway (abstract)        │
│  GetAllFriendsUseCase · GetFriendByIdUseCase                │
│  SaveFriendUseCase · DeleteFriendUseCase                    │
└────────────────────────┬────────────────────────────────────┘
                         │ implements / uses
┌────────────────────────▼────────────────────────────────────┐
│ INFRASTRUCTURE                                              │
│  FriendHiveAdapter (implements FriendGateway)               │
│  friend_mapper.dart (friendToJson / friendFromJson)         │
└────────────────────────┬────────────────────────────────────┘
                         │ injected via constructor
┌────────────────────────▼────────────────────────────────────┐
│ CONFIG / PROVIDERS                                          │
│  FriendState · FriendNotifier · friendProvider              │
└────────────────────────┬────────────────────────────────────┘
                         │ ref.watch / ref.read
┌────────────────────────▼────────────────────────────────────┐
│ UI                                                          │
│  FriendListPage · FriendFormPage                            │
│  AppShell (5 tabs) · ToolsPage (nueva tarjeta)              │
└─────────────────────────────────────────────────────────────┘
```
