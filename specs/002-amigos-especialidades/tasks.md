# Tasks: Gestión de Amigos y Especialidades

**Feature**: `002-amigos-especialidades`  
**Branch**: `002-amigos-especialidades`  
**Input**: [spec.md](spec.md) · [plan.md](plan.md) · [research.md](research.md) · [data-model.md](data-model.md) · [quickstart.md](quickstart.md)  
**Date**: 2026-05-10

## Format: `[ID] [P?] [Story?] Description con ruta exacta`

- **[P]**: Puede correr en paralelo (archivos distintos, sin dependencias incompletas)
- **[Story]**: A qué historia de usuario pertenece la tarea
- Rutas desde la raíz del proyecto Flutter: `valora_code/`

---

## Phase 1: Setup (Infraestructura compartida)

**Purpose**: Habilitar persistencia del nuevo módulo — sin esto nada funciona.

- [X] T001 Añadir `Hive.openBox<Map>('friends')` al `Future.wait` en `valora_code/lib/main.dart`

**Checkpoint**: La caja Hive está disponible al iniciar la app — el módulo puede ser implementado.

---

## Phase 2: Foundational — Dominio (Bloqueante para todas las historias)

**Purpose**: Contratos y reglas de negocio en Dart puro — no dependen de nada externo.

**⚠️ CRÍTICO**: Ninguna historia de usuario puede comenzar hasta que esta fase esté completa.

- [X] T002 [P] Crear entidad `Friend` con `copyWith` en `valora_code/lib/domain/models/friend/friend.dart`
- [X] T003 [P] Crear excepción `FriendException` en `valora_code/lib/domain/models/friend/friend_exception.dart`
- [X] T004 [P] Crear contrato `FriendGateway` (getAll, getById, save, delete) en `valora_code/lib/domain/models/friend/gateway/friend_gateway.dart`
- [X] T005 [P] Implementar `GetAllFriendsUseCase` en `valora_code/lib/domain/usecase/friend/get_all_friends_use_case.dart`
- [X] T006 [P] Implementar `GetFriendByIdUseCase` en `valora_code/lib/domain/usecase/friend/get_friend_by_id_use_case.dart`
- [X] T007 Implementar `SaveFriendUseCase` con validaciones (nombre, hourlyRate, currency) en `valora_code/lib/domain/usecase/friend/save_friend_use_case.dart`
- [X] T008 [P] Implementar `DeleteFriendUseCase` en `valora_code/lib/domain/usecase/friend/delete_friend_use_case.dart`
- [X] T009 [P] Escribir tests de `SaveFriendUseCase` (happy path + 3 casos de error) en `valora_code/test/domain/usecase/friend/save_friend_use_case_test.dart`
- [X] T034 [P] Escribir tests de `GetAllFriendsUseCase` (lista vacía + lista con elementos) en `valora_code/test/domain/usecase/friend/get_all_friends_use_case_test.dart`
- [X] T035 [P] Escribir tests de `GetFriendByIdUseCase` (encontrado + no encontrado) en `valora_code/test/domain/usecase/friend/get_friend_by_id_use_case_test.dart`
- [X] T036 [P] Escribir tests de `DeleteFriendUseCase` (id válido + delegación al gateway) en `valora_code/test/domain/usecase/friend/delete_friend_use_case_test.dart`

**Checkpoint**: Domain completo y testeado — infraestructura puede comenzar en paralelo con la UI básica.

---

## Phase 3: User Story 1 — Registrar un amigo (Priority: P1) 🎯 MVP

**Goal**: El usuario puede crear un amigo con nombre, áreas de conocimiento y valor por hora, y verlo en la lista.

**Independent Test**: Abrir formulario → llenar nombre + 1 conocimiento + valor hora → Guardar → la tarjeta aparece en la lista.

### Infrastructure para US1

- [X] T010 [P] Implementar `friend_mapper.dart` (friendToJson / friendFromJson con fallback currency 'COP') en `valora_code/lib/infrastructure/helpers/mappers/friend_mapper.dart`
- [X] T011 [P] Añadir función `formatCurrency(double amount, String currency)` a `valora_code/lib/ui/widgets/invoice/currency_format_helper.dart`
- [X] T012 Implementar `FriendHiveAdapter implements FriendGateway` en `valora_code/lib/infrastructure/driven_adapters/friend/friend_hive_adapter.dart`
- [X] T033 Escribir tests de `FriendHiveAdapter` con fake Hive box en `valora_code/test/infrastructure/driven_adapters/friend/friend_hive_adapter_test.dart`

### Provider para US1

- [X] T013 Crear `FriendState`, `FriendNotifier` y `friendProvider` en `valora_code/lib/config/providers/friend_provider.dart`
- [X] T014 [P] Escribir tests de `friend_provider` con mocks en `valora_code/test/config/providers/friend_provider_test.dart`

### UI para US1 (crear primero para que el routing pueda referenciarla)

- [X] T017 [US1] Crear `FriendListPage` (vacío con `OwlMascot`, encabezado, `ListView` con `_FriendCard`, FAB) en `valora_code/lib/ui/pages/friend/friend_list_page.dart`

### Routing para US1 (depende de T017)

- [X] T015 Añadir constantes de ruta (`friends`, `friendNew`, `friendEdit`) y `GoRoute` para `/friends/new` a `valora_code/lib/config/routes/app_router.dart`
- [X] T016 Añadir 5ª `StatefulShellBranch` para `/friends` → `FriendListPage` en `valora_code/lib/config/routes/app_router.dart`

### Resto UI para US1
- [X] T018 [US1] Crear `FriendFormPage` modo creación (RetroBackground, secciones, `_KnowledgeTagInput`, dropdown moneda, validaciones) en `valora_code/lib/ui/pages/friend/friend_form_page.dart`
- [X] T019 [US1] Añadir tab "Amigos" (`Icons.people_outline`) al `_AppBottomBar` en `valora_code/lib/ui/widgets/app_shell.dart`
- [X] T020 [US1] Añadir tarjeta "Amigos" en `ToolsPage` en `valora_code/lib/ui/pages/tools/tools_page.dart`

> **Orden dentro de US1**: T017 → T015/T016 → T018 → T019/T020

**Checkpoint**: US1 completamente funcional — el usuario puede agregar amigos y verlos en lista y en la barra de navegación.

---

## Phase 4: User Story 2 — Ver lista con tarjetas visuales (Priority: P2)

**Goal**: La lista muestra tarjetas atractivas y consistentes con el resto de la app.

**Independent Test**: Crear 2-3 amigos (incluido uno sin foto) → verificar tarjetas con borde acento, avatar/foto circular, nombre en negrita, chips de conocimiento y valor hora formateado.

### UI para US2

- [X] T021 [US2] Pulir `_FriendCard` en `valora_code/lib/ui/pages/friend/friend_list_page.dart` (depende de T017):
  - Borde izquierdo 4px `AppTheme.accentColor`
  - Avatar `ClipOval(Image.memory(...))` si `imageBase64 != null`, sino `CircleAvatar` con inicial
  - Nombre en negrita, chips de `knowledgeAreas` (máx 3 + "+N más"), valor hora con `formatCurrency`
  - `Key('friend-card-\${friend.id}')` y `Key('friend-name-\${friend.id}')`
- [X] T022 [P] [US2] Asegurar que `_FriendCard` navega a edición al ser presionada (llama `context.push(AppRouter.friendEdit, extra: friend.id)`)

**Checkpoint**: US2 completa — las tarjetas son visualmente consistentes con `invoice_list_page.dart`.

---

## Phase 5: User Story 3 — Editar o eliminar un amigo (Priority: P3)

**Goal**: El usuario puede actualizar datos de un amigo o eliminarlo con confirmación.

**Independent Test**: Abrir amigo existente → cambiar valor hora → Guardar → tarjeta muestra nuevo valor. Abrir amigo → Eliminar → confirmar → amigo desaparece de la lista.

### UI para US3

- [X] T023 [US3] Habilitar modo edición en `FriendFormPage`: recibir `friendId`, cargar con `getById`, precargar todos los campos en `valora_code/lib/ui/pages/friend/friend_form_page.dart`
- [X] T024 [US3] Añadir botón Eliminar en modo edición con `showDialog` de confirmación y llamada a `friendProvider.notifier.delete(id)` en `valora_code/lib/ui/pages/friend/friend_form_page.dart`
- [X] T025 [US3] Añadir `GoRoute` para `/friends/:friendId` que pase `friendId` a `FriendFormPage` en `valora_code/lib/config/routes/app_router.dart`

**Checkpoint**: US3 completa — el ciclo de vida completo del amigo funciona (crear, leer, actualizar, eliminar).

---

## Phase 6: User Story 4 — Foto de perfil (Priority: P4)

**Goal**: El usuario puede asignar una foto de galería al amigo, que se muestra circular en la tarjeta.

**Independent Test**: Abrir formulario → tocar selector de imagen → elegir foto → Guardar → tarjeta muestra foto circular.

### UI para US4

- [X] T026 [US4] Crear widget `_FriendImagePicker` (igual que `_ClientImagePicker` en `client_form_page.dart`) dentro de `valora_code/lib/ui/pages/friend/friend_form_page.dart`
- [X] T027 [US4] Integrar `_FriendImagePicker` en `FriendFormPage`: `ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70)` → `base64Encode(bytes)` → actualiza estado del form en `valora_code/lib/ui/pages/friend/friend_form_page.dart`
- [X] T028 [US4] Verificar integración foto end-to-end: guardar amigo con foto → reabrir lista → tarjeta muestra `ClipOval(Image.memory(...))` (la lógica de renderizado ya fue implementada en T021)

**Checkpoint**: US4 completa — el flujo de foto funciona end-to-end (galería → base64 → tarjeta circular).

---

## Phase 7: Polish & Calidad

**Purpose**: Garantizar calidad, consistencia y preparar para merge.

- [X] T029 [P] Ejecutar `flutter analyze --no-pub` y corregir todos los issues en `valora_code/`
- [X] T030 [P] Ejecutar `flutter test` y asegurar que todos los tests del módulo pasan en `valora_code/`
- [X] T031 [P] Verificar que los chips de conocimiento muestran correctamente "+N más" cuando hay más de 3 en `valora_code/lib/ui/pages/friend/friend_list_page.dart`
- [ ] T032 Verificar en dispositivo/simulador que la barra inferior muestra los 5 tabs correctamente y la navegación funciona para todas las rutas del módulo

---

## Dependencies & Execution Order

### Dependencias de fases

- **Phase 1 (Setup)**: Sin dependencias — comenzar inmediatamente
- **Phase 2 (Domain)**: Depende de Phase 1 — **bloquea** todas las historias
- **Phase 3 (US1)**: Depende de Phase 2 — T010–T012 pueden empezar en paralelo con T013+; dentro de US1: T017 → T015/T016 → T018 → T019/T020
- **Phase 4 (US2)**: Depende de T017 (lista creada) — refinamiento visual; T021 es secuencial (no [P]) respecto a T017
- **Phase 5 (US3)**: Depende de T018 (formulario creado) — modo edición
- **Phase 6 (US4)**: Depende de T018 (formulario creado) y T021 (tarjeta con avatar ya implementado)
- **Phase 7 (Polish)**: Depende de todas las historias deseadas

### Dependencias dentro de US1 (la más crítica)

```
T001 (Hive box)
  └── T002, T003, T004 (entidad, excepción, gateway) — paralelo
        └── T005, T006, T007, T008 (use cases)
              └── T009 (tests use case)
              └── T010, T011 (mapper, formatCurrency) — paralelo
                    └── T012 (adapter)
                          └── T013 (provider)
                                └── T014 (tests provider)
                                └── T015, T016 (routing)
                                      └── T017 (FriendListPage)
                                      └── T018 (FriendFormPage)
                                            └── T019, T020 (AppShell, ToolsPage)
```

### Oportunidades de paralelismo

- T002, T003, T004 — Domain entities (archivos distintos)
- T005, T006, T008 — Use cases sin validaciones (archivos distintos)
- T009, T034, T035, T036 — Tests de use cases (archivos distintos)
- T010, T011 — Mapper y helper de moneda (archivos distintos)
- T012, T033 — Adapter + su test (T033 puede escribirse antes/junto con T012)
- T022 — Depende de T021 (mismo archivo, secuencial)
- T029, T030, T031 — Verificaciones finales

---

## Parallel Example: Phase 2 (Domain)

```bash
# Ejecutar en paralelo (archivos distintos):
Task: T002 - friend.dart
Task: T003 - friend_exception.dart
Task: T004 - friend_gateway.dart
# Luego:
Task: T005 - get_all_friends_use_case.dart
Task: T006 - get_friend_by_id_use_case.dart
Task: T008 - delete_friend_use_case.dart
# Luego (valida las 3 anteriores):
Task: T007 - save_friend_use_case.dart
Task: T009 - save_friend_use_case_test.dart
```

---

## Implementation Strategy

### MVP (solo US1 — mínimo funcional)

1. Completar Phase 1: Setup (T001)
2. Completar Phase 2: Domain (T002–T009) ← **crítico**
3. Completar Phase 3: US1 (T010–T020)
4. **DETENER y VALIDAR**: Crear un amigo completo, verificar que aparece en la lista y en el NavBar
5. Demo si está listo

### Entrega incremental

1. Setup + Domain → base sólida
2. US1 (crear + listar básico) → MVP demostrable
3. US2 (pulir tarjetas) → experiencia visual completa
4. US3 (editar + eliminar) → ciclo de vida completo
5. US4 (foto) → experiencia premium
6. Polish → listo para merge

---

## Notes

- `[P]` = archivos distintos, sin dependencias incompletas
- `[US1]`..`[US4]` mapean a las historias del spec.md
- Commit después de cada checkpoint usando el skill `/commit` con tipo `feat(friends):`
- La barra de navegación de 5 tabs requiere coordinar `app_router.dart` y `app_shell.dart` juntos (T015/T016 + T019)
- Los tests del adaptador Hive (`friend_hive_adapter_test.dart`) tienen un problema pre-existente con `HiveError` en tests — documentado en research.md; no bloquea el desarrollo
