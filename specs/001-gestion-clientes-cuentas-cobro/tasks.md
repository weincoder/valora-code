# Tasks: Gestión de Clientes y Cuentas de Cobro

**Input**: Design documents from `/specs/001-gestion-clientes-cuentas-cobro/`  
**Prerequisites**: [plan.md](./plan.md) · [spec.md](./spec.md) · [research.md](./research.md) · [data-model.md](./data-model.md) · [contracts/](./contracts/) · [quickstart.md](./quickstart.md)  
**Branch**: `001-gestion-clientes-cuentas-cobro`

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no shared dependencies between parallel tasks)
- **[US1/US2/US3]**: Which user story this task belongs to
- All paths are relative to `valora_code/`

---

## Phase 1: Setup (Infraestructura compartida)

**Purpose**: Inicialización del módulo — registrar cajas Hive y constantes de rutas antes de empezar cualquier historia de usuario.

- [X] T001 Abrir las 4 cajas Hive del módulo (`clients`, `catalog_items`, `issuer_config`, `invoices`) en `lib/main.dart`
- [X] T002 [P] Declarar las 10 constantes de ruta del módulo (`clients`, `clientNew`, `clientEdit`, `catalog`, `catalogNew`, `catalogEdit`, `issuerConfig`, `invoices`, `invoiceNew`, `invoiceDetail`) en `lib/config/routes/app_router.dart`

**Checkpoint**: Las cajas Hive y las constantes de ruta están declaradas. Cualquier fase posterior puede referenciarlas.

---

## Phase 2: Foundational — Configuración del Emisor (IssuerConfig)

**Purpose**: `IssuerConfig` es prerequisito para `CreateInvoiceUseCase` (genera el número consecutivo y copia el snapshot del emisor en la cuenta). DEBE completarse antes de US2.

> **Nota**: Esta fase puede ejecutarse **en paralelo con Phase 3 (US1)** — US1 no depende de IssuerConfig.

- [X] T003 Crear entidad `IssuerConfig` con `copyWith` y getter `formattedNextNumber` en `lib/domain/models/issuer_config/issuer_config.dart`
- [X] T004 [P] Crear `IssuerConfigGateway` (abstract: `get()`, `save()`) en `lib/domain/models/issuer_config/gateway/issuer_config_gateway.dart`
- [X] T005 Crear `GetIssuerConfigUseCase` con `execute()` en `lib/domain/usecase/issuer_config/get_issuer_config_use_case.dart`
- [X] T006 [P] Crear `SaveIssuerConfigUseCase` con `execute(IssuerConfig config)` en `lib/domain/usecase/issuer_config/save_issuer_config_use_case.dart`
- [X] T007 Crear funciones puras `issuerConfigToJson` / `issuerConfigFromJson` en `lib/infrastructure/helpers/mappers/issuer_config_mapper.dart`
- [X] T008 Crear `IssuerConfigHiveAdapter implements IssuerConfigGateway` (clave fija `issuer_config`) en `lib/infrastructure/driven_adapters/issuer_config/issuer_config_hive_adapter.dart`
- [X] T009 Crear `IssuerConfigState`, `IssuerConfigNotifier` e `issuerConfigProvider` (`StateNotifierProvider`) en `lib/config/providers/issuer_config_provider.dart`
- [X] T010 Crear `IssuerConfigPage` (formulario: nombre/razón social, NIT, dirección, prefijo) en `lib/ui/pages/issuer_config/issuer_config_page.dart`
- [X] T011 Registrar el `GoRoute` de `/issuer-config` → `IssuerConfigPage` en `lib/config/routes/app_router.dart`

**Checkpoint**: La configuración del emisor puede guardarse y leerse. `CreateInvoiceUseCase` (Phase 4) puede usar este gateway.

---

## Phase 3: User Story 1 — Registrar y consultar clientes (Priority: P1) 🎯 MVP

**Goal**: El administrador puede registrar clientes con nombre, NIT/documento, email y teléfono, y consultar la lista completa. Entrega valor inmediato como directorio de clientes.

**Independent Test**: Registrar un cliente con datos válidos → aparece en la lista. Intentar registrar un duplicado de NIT → error visible. Email inválido → error de validación sin guardar.

> **Puede ejecutarse en paralelo con Phase 2 (IssuerConfig).**

- [X] T012 [P] [US1] Crear entidad `Client` con `copyWith` en `lib/domain/models/client/client.dart`
- [X] T013 [P] [US1] Crear `ClientException` en `lib/domain/models/client/client_exception.dart`
- [X] T014 [US1] Crear `ClientGateway` (abstract: `getAll()`, `getById()`, `getByDocumentId()`, `save()`, `delete()`) en `lib/domain/models/client/gateway/client_gateway.dart`
- [X] T015 [P] [US1] Crear `GetAllClientsUseCase` con `execute()` en `lib/domain/usecase/client/get_all_clients_use_case.dart`
- [X] T016 [P] [US1] Crear `GetClientByIdUseCase` con `execute(String id)` en `lib/domain/usecase/client/get_client_by_id_use_case.dart`
- [X] T017 [US1] Crear `SaveClientUseCase` con validación de `documentId` único y regex de email en `lib/domain/usecase/client/save_client_use_case.dart`
- [X] T018 [P] [US1] Crear funciones puras `clientToJson` / `clientFromJson` en `lib/infrastructure/helpers/mappers/client_mapper.dart`
- [X] T019 [US1] Crear `ClientHiveAdapter implements ClientGateway` en `lib/infrastructure/driven_adapters/client/client_hive_adapter.dart`
- [X] T020 [US1] Crear `ClientState`, `ClientNotifier` y `clientProvider` en `lib/config/providers/client_provider.dart`
- [X] T021 [US1] Crear `ClientListPage` (lista con nombre y NIT/documento visibles, FAB para crear) en `lib/ui/pages/client/client_list_page.dart`
- [X] T022 [US1] Crear `ClientFormPage` (campos: nombre, NIT/doc, email, teléfono; feedback de validación inline) en `lib/ui/pages/client/client_form_page.dart`
- [X] T023 [US1] Registrar `GoRoute`s de `/clients`, `/clients/new` y `/clients/:id` en `lib/config/routes/app_router.dart`

**Checkpoint**: US1 es completamente funcional y testeable de forma aislada. El directorio de clientes entrega valor inmediato.

---

## Phase 4: User Story 2 — Crear cuenta de cobro (Priority: P2)

**Goal**: El administrador puede registrar ítems del catálogo y crear cuentas de cobro: seleccionar cliente, añadir ítems con cantidad, ver subtotales en tiempo real y confirmar. El sistema genera el número consecutivo y persiste snapshots inmutables.

**Independent Test**: Con un cliente y un ítem del catálogo creados (y la config del emisor guardada), crear una cuenta de cobro con 2 líneas → verificar que el total = suma de subtotales, el número tiene formato `<prefijo>-XXXX`, y los datos del cliente/emisor están copiados correctamente.

> **Requiere Phase 2 (IssuerConfig) Y Phase 3 (US1) completas.**

### 4a — Catálogo de ítems (prerequisito para el formulario de cuenta)

- [X] T024 [P] [US2] Crear entidad `CatalogItem`
- [X] T025 [P] [US2] Crear `CatalogItemException`
- [X] T026 [US2] Crear `CatalogItemGateway`
- [X] T027 [P] [US2] Crear `GetAllCatalogItemsUseCase`
- [X] T028 [P] [US2] Crear `GetCatalogItemByIdUseCase`
- [X] T029 [US2] Crear `SaveCatalogItemUseCase`
- [X] T030 [P] [US2] Crear funciones puras `catalogItemToJson` / `catalogItemFromJson`
- [X] T031 [US2] Crear `CatalogItemHiveAdapter`
- [X] T032 [US2] Crear `CatalogItemState`, `CatalogItemNotifier` y `catalogItemProvider`
- [X] T033 [US2] Crear `CatalogItemListPage`
- [X] T034 [US2] Crear `CatalogItemFormPage`
- [X] T035 [US2] Registrar `GoRoute`s de `/catalog`, `/catalog/new` y `/catalog/:id`

### 4b — Entidad Invoice y sus value objects

- [X] T036 [P] [US2] Crear `InvoiceLine`
- [X] T037 [P] [US2] Crear `IssuerSnapshot`
- [X] T038 [P] [US2] Crear `ClientSnapshot`
- [X] T039 [US2] Crear entidad `Invoice`
- [X] T040 [P] [US2] Crear `InvoiceException`
- [X] T041 [US2] Crear `InvoiceGateway`

### 4c — Use Cases de Invoice

- [X] T042 [US2] Crear `CreateInvoiceUseCase`
- [X] T043 [P] [US2] Crear `GetAllInvoicesUseCase`
- [X] T044 [P] [US2] Crear `GetInvoiceByIdUseCase`

### 4d — Infrastructure de Invoice

- [X] T045 [US2] Crear `invoiceToJson` / `invoiceFromJson`
- [X] T046 [US2] Crear `InvoiceHiveAdapter`

### 4e — Provider e UI de Invoice

- [X] T047 [US2] Crear `InvoiceState`, `InvoiceNotifier` e `invoiceProvider`
- [X] T048 [US2] Crear `InvoiceListPage`
- [X] T049 [US2] Crear `InvoiceFormPage`
- [X] T050 [US2] Registrar `GoRoute`s de `/invoices` y `/invoices/new`

**Checkpoint**: US2 es completamente funcional. Se puede crear una cuenta de cobro completa con cálculos en tiempo real y numeración consecutiva automática.

---

## Phase 5: User Story 3 — Visualizar cuenta de cobro (Priority: P3)

**Goal**: El administrador puede abrir cualquier cuenta de cobro guardada en una vista de presentación limpia con todos los datos: emisor, cliente, ítems (nombre, cantidad, precio unitario, subtotal) y total. Base para futura exportación a PDF.

**Independent Test**: Con una cuenta de cobro creada, abrir `InvoiceDetailPage` → verificar que se muestran todos los campos sin vacíos, subtotales correctos y total coincidente.

> **Requiere Phase 4 (US2) completa.**

- [X] T059 Extraer helper `formatCop`
- [X] T051 [P] [US3] Crear widget `InvoiceLineTile`
- [X] T052 [P] [US3] Crear widget `InvoiceSummaryCard`
- [X] T053 [US3] Crear `InvoiceDetailPage`
- [X] T054 [US3] Registrar `GoRoute` de `/invoices/:id/detail`
- [X] T055 [US3] Conectar tap en `InvoiceListPage`

**Checkpoint**: US3 es completamente funcional. La vista de presentación está lista como base para exportación a PDF futura.

---

## Final Phase: Polish & Cross-Cutting Concerns

**Purpose**: Integración con la navegación existente, guards de edge cases definidos en la spec, y formato de moneda compartido.

- [X] T056 Añadir accesos de navegación al módulo en `tools_page.dart`
- [X] T057 [P] Guard en `InvoiceFormPage`: sin clientes → diálogo
- [X] T058 [P] Diálogo de confirmación en `InvoiceFormPage` al navegar fuera con draft no vacío

**Checkpoint**: El módulo está completamente integrado y los edge cases están cubiertos.

---

## Phase: Pruebas — Cumplimiento constitución Principio IV

**Purpose**: La constitución (Principio IV) exige tests unitarios escritos junto a la implementación. Estas tareas cubren el ciclo Red-Green-Refactor para dominio e infraestructura del módulo.

> Pueden ejecutarse en paralelo tan pronto como la fase correspondiente esté completa.

- [X] T060 [P] Tests de `SaveClientUseCase`
- [X] T061 [P] Tests de `IssuerConfig.formattedNextNumber` y `SaveIssuerConfigUseCase`
- [X] T062 [P] Tests de `InvoiceLine.subtotal`, `Invoice.total` y `CreateInvoiceUseCase`
- [X] T063 [P] Tests de `ClientHiveAdapter`
- [X] T064 [P] Tests de `InvoiceHiveAdapter`
- [X] T065 [P] Tests de `ClientNotifier` e `InvoiceNotifier`

**Checkpoint**: Todos los use cases críticos y adapters Hive tienen cobertura de test. El módulo cumple el Principio IV de la constitución.

---

## Dependencies Graph

```
Phase 1 (Setup)
  │
  ├──► Phase 2 (IssuerConfig) ──────────────────────────────────┐
  │                                                              │
  └──► Phase 3 (US1 — Clientes) ────────────────────────────────┤
                                                                 │
                                                           Phase 4 (US2 — Cuentas de cobro)
                                                                 │
                                                           Phase 5 (US3 — Vista detalle)
                                                                 │
                                                          Final Phase (Polish)
```

**Historias de usuario independientes**:
- US1 (clientes): Completamente independiente — no requiere IssuerConfig ni Invoice.
- US2 (crear cuenta): Requiere US1 + IssuerConfig completos.
- US3 (visualizar cuenta): Requiere US2 completo.

---

## Parallel Execution Examples

### Sprint 1 — Paralelo (Phase 1 + arranque de Phase 2 y Phase 3 simultáneamente)

```
Dev A: T001 (main.dart) → T003 (IssuerConfig entity) → T004 (gateway) → T005 → T006 → T007 → T008 → T009 → T010 → T011
Dev B: T002 (router constants) → T012 (Client entity) → T013 (ClientException) → T014 → T015 → T016 → T017 → T018 → T019 → T020 → T021 → T022 → T023
```

### Sprint 2 — Paralelo dentro de Phase 4

```
Dev A: T024 → T025 → T026 → T027 → T028 → T029 → T030 → T031 → T032 → T033 → T034 → T035   (catálogo)
Dev B: T036 → T037 → T038 → T039 → T040 → T041 → T042 → T043 → T044 → T045 → T046            (invoice domain + infra)
         [luego juntos] T047 → T048 → T049 → T050
```

### Sprint 3 — Paralelo dentro de Phase 5 y Final

```
Dev A: T059 → T051 → T052 → T053 → T054 → T055   (helper COP + US3 UI)
Dev B: T056 → T057 → T058                          (integración navegación + guards)
```

### Sprint 4 — Tests (paralelo por capa)

```
Dev A: T060 → T061 → T062   (domain tests)
Dev B: T063 → T064 → T065   (infra + provider tests)
```

---

## Implementation Strategy

**MVP recomendado** (entrega de valor inmediato, mínima dependencia): **Phase 1 + Phase 2 + Phase 3**

Con el MVP entregado:
- El directorio de clientes es funcional (US1 completo).
- La configuración del emisor está disponible.
- Se puede pasar inmediatamente a US2 sin bloqueo.

**Incremento 2**: Phase 4 (US2) — el flujo central del módulo.  
**Incremento 3**: Phase 5 + Final Phase (US3 + polish) — vista de presentación y pulido.

---

## Summary

| Fase | Tareas | Historia | Testeable aisladamente |
|------|--------|----------|------------------------|
| Phase 1: Setup | T001–T002 | — | No (infraestructura) |
| Phase 2: Foundational | T003–T011 | IssuerConfig | Sí — guardar y leer configuración del emisor |
| Phase 3: US1 | T012–T023 | Clientes (P1) 🎯 | **Sí — MVP entregable** |
| Phase 4: US2 | T024–T050 | Cuentas de Cobro (P2) | Sí — depende de US1 + IssuerConfig |
| Phase 5: US3 | T059, T051–T055 | Vista detalle (P3) | Sí — depende de US2 |
| Final Phase | T056–T058 | Polish | Sí — integración completa |
| Tests (Principio IV) | T060–T065 | Todas | Sí — paralelo por capa |

**Total de tareas**: 65  
**Tareas paralelizables [P]**: 27  
**Historias de usuario**: 3  
**Oportunidades de paralelismo identificadas**: 4 (Phase 2 ∥ Phase 3; Dev A ∥ Dev B en Phase 4; T059 → T051 ∥ T056–T058; domain tests ∥ infra tests)
