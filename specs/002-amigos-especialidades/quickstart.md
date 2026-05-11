# Quickstart: Gestión de Amigos y Especialidades

**Feature**: `002-amigos-especialidades`  
**Branch**: `002-amigos-especialidades`  
**Orden de implementación**: Domain → Infrastructure → Config → UI

---

## Secuencia de implementación

### FASE 1 — Domain (pure Dart, zero deps)

1. `lib/domain/models/friend/friend.dart` — entidad con `copyWith`
2. `lib/domain/models/friend/friend_exception.dart` — excepción tipada
3. `lib/domain/models/friend/gateway/friend_gateway.dart` — contrato abstracto (`getAll`, `getById`, `save`, `delete`)
4. `lib/domain/usecase/friend/get_all_friends_use_case.dart`
5. `lib/domain/usecase/friend/get_friend_by_id_use_case.dart`
6. `lib/domain/usecase/friend/save_friend_use_case.dart` — validaciones de negocio
7. `lib/domain/usecase/friend/delete_friend_use_case.dart`

**Tests (junto con implementación)**:
- `test/domain/usecase/friend/save_friend_use_case_test.dart`
  - `should save valid friend`
  - `should throw when fullName is blank`
  - `should throw when hourlyRate is negative`
  - `should throw when currency is invalid`

---

### FASE 2 — Infrastructure

8. `lib/infrastructure/helpers/mappers/friend_mapper.dart` — `friendToJson` / `friendFromJson` (manejar `currency` con fallback `'COP'`)
9. `lib/infrastructure/driven_adapters/friend/friend_hive_adapter.dart` — implementa `FriendGateway`
10. `lib/ui/widgets/invoice/currency_format_helper.dart` — añadir `formatCurrency(double, String)`
11. `lib/main.dart` — añadir `Hive.openBox<Map>('friends')` en el `Future.wait`

**Tests**:
- `test/infrastructure/driven_adapters/friend/friend_hive_adapter_test.dart` (fixture con `hive_test`)

---

### FASE 3 — Config / Providers

12. `lib/config/providers/friend_provider.dart`
    - `FriendState { friends, isLoading, error }` con `copyWith`
    - `FriendNotifier extends StateNotifier<FriendState>` con `load()`, `save()`, `delete()`, `getById()`, `generateId()`
    - `friendProvider = StateNotifierProvider<FriendNotifier, FriendState>` — instancia `FriendHiveAdapter` → use cases

**Tests**:
- `test/config/providers/friend_provider_test.dart` — mock de use cases con mocktail

---

### FASE 4 — Routing

13. `lib/config/routes/app_router.dart`
    - Añadir constantes: `friends`, `friendNew`, `friendEdit`
    - Añadir `GoRoute` para cada ruta (fuera del shell)
    - Añadir 5ª `StatefulShellBranch` para `/friends` → `FriendListPage`

---

### FASE 5 — UI: Lista de amigos

14. `lib/ui/pages/friend/friend_list_page.dart` — `ConsumerWidget`
    - `Scaffold(backgroundColor: Colors.transparent)` + `AppBar`
    - `RetroBackground` como body wrapper
    - Estado vacío: `OwlMascot(scenario: OwlScenario.empty, label: 'Sin amigos. Presiona + para agregar uno.')`
    - Con datos: encabezado `OwlMascot(scenario: OwlScenario.working, size: 56)` + contador
    - `ListView.builder` con `_FriendCard`
    - FAB con `Icons.person_add_outlined` → navega a `AppRouter.friendNew`

**`_FriendCard`** (widget privado en mismo archivo):
    - Card con borde izquierdo 4px `AppTheme.accentColor`
    - Avatar: `ClipOval(Image.memory(...))` si `imageBase64 != null`; sino `CircleAvatar` con inicial
    - `fullName` en negrita, chips de `knowledgeAreas` (max 3 + `+N` si hay más), `formatCurrency(hourlyRate, currency)` en `AppTheme.accentColor`
    - `Icons.chevron_right` en acento
    - `onTap` → navega a `AppRouter.friendEdit`

---

### FASE 6 — UI: Formulario de amigo

15. `lib/ui/pages/friend/friend_form_page.dart` — `ConsumerStatefulWidget`
    - Parámetro opcional `friendId`; si está presente → modo edición (carga con `getById`)
    - `RetroBackground` como fondo
    - Secciones con `_SectionTitle` (mismo widget que `ClientFormPage`)
    - **Sección Foto**: `_FriendImagePicker` (igual que `_ClientImagePicker`)
    - **Sección Info básica**: `TextFormField` nombre (prefixIcon `Icons.person`), validación `trim().isNotEmpty`
    - **Sección Valor hora**: `Row` con `TextFormField` numérico + `DropdownButtonFormField<String>(['COP','USD'])` con `initialValue: 'COP'`
    - **Sección Conocimientos**: `_KnowledgeTagInput` (ver research.md):
      - `TextFormField` + `IconButton(Icons.add_circle_outline)` 
      - `Wrap` de `InputChip` removibles
    - **Modo edición**: botón Eliminar con `showDialog` de confirmación
    - Botón guardar (`key: 'save-friend-button'`) → llama `ref.read(friendProvider.notifier).save()`

---

### FASE 7 — Integración de navegación

16. `lib/ui/widgets/app_shell.dart`
    - Añadir `_TabItem(icon: Icons.people_outline, label: 'Amigos')` a `_tabs`
    - Añadir `_NavItem` para índice 4 en `_AppBottomBar` Row (lado derecho, después de "Más")
    - Manejar índice 4 en el `onTap` con `navigationShell.goBranch(4, ...)`

17. `lib/ui/pages/tools/tools_page.dart`
    - Añadir `_ToolCard` para Amigos:
      ```dart
      _ToolCard(
        icon: Icons.people_outline,
        label: 'Amigos',
        description: 'Tu directorio\nde talento',
        color: const Color(0xFF3A7EC8),
        onTap: () => context.push(AppRouter.friends),
      ),
      ```

---

## Referencia visual de componentes reutilizados

| Componente a reutilizar | Origen | Uso en este feature |
|---|---|---|
| `RetroBackground` | `lib/ui/widgets/retro_background.dart` | Fondo de `FriendListPage` y `FriendFormPage` |
| `OwlMascot` | `lib/ui/widgets/owl_mascot.dart` | Estado vacío + encabezado lista |
| `_ToolCard` | `lib/ui/pages/tools/tools_page.dart` | Nueva tarjeta en ToolsPage |
| Patrón `_ClientCard` | `lib/ui/pages/client/client_list_page.dart` | Plantilla para `_FriendCard` |
| Patrón `_ClientImagePicker` | `lib/ui/pages/client/client_form_page.dart` | Plantilla para `_FriendImagePicker` |
| Patrón `_SectionTitle` | `lib/ui/pages/client/client_form_page.dart` | Separadores de sección en form |
| `formatCop()` / `formatCurrency()` | `lib/ui/widgets/invoice/currency_format_helper.dart` | Valor hora en tarjeta |
| `AppTheme` | `lib/config/theme/app_theme.dart` | Colores: `accentColor`, `textSecondary`, `cardBorder` |

---

## Decisiones de diseño clave

- **Foto**: `ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70)` → `base64Encode(bytes)`
- **Chips knowledge**: máx visibles en tarjeta = 3; en formulario sin límite
- **Validación al guardar**: en `SaveFriendUseCase` (domain); UI muestra el `error` del estado
- **Eliminación**: sólo en modo edición; `showDialog` de confirmación antes de llamar `delete()`
- **IDs**: `const Uuid().v4()` generado en `FriendNotifier.generateId()`

---

## Checklist de calidad pre-merge

- [ ] `flutter analyze --no-pub` → 0 issues
- [ ] `flutter test` → todos los tests de domain y providers pasan
- [ ] `_FriendCard` tiene `Key('friend-card-${friend.id}')` para testabilidad
- [ ] `_FriendCard` nombre tiene `Key('friend-name-${friend.id}')`
- [ ] Botón guardar tiene `key: Key('save-friend-button')`
- [ ] El NavBar muestra los 5 tabs correctamente en dispositivo/simulador
- [ ] La tarjeta en ToolsPage navega correctamente a `/friends`
- [ ] Commit sigue el skill `/commit` con tipo `feat(friends): 🆕`
