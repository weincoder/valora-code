# Implementation Plan: Gestión de Clientes y Cuentas de Cobro

**Branch**: `001-gestion-clientes-cuentas-cobro` | **Date**: 2026-05-07 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/001-gestion-clientes-cuentas-cobro/spec.md`

## Summary

Implementar el módulo de **Gestión de Clientes y Cuentas de Cobro** para la app Valora Code. El módulo permite registrar clientes, mantener un catálogo de ítems facturables, configurar los datos del emisor y generar cuentas de cobro numeradas consecutivamente. Todos los datos persisten en Hive (almacenamiento local). La implementación sigue las capas existentes del proyecto: Domain → Infrastructure → Config (Riverpod StateNotifier) → UI (go_router + Material Design).

## Technical Context

**Language/Version**: Dart 3 (SDK ^3.11.0) / Flutter 3.x  
**Primary Dependencies**: `flutter_riverpod ^2.6.1` (StateNotifier), `hive ^2.2.3` + `hive_flutter ^1.1.0` (persistencia local), `go_router ^14.6.2` (navegación), `uuid ^4.5.1` (generación de IDs)  
**Storage**: Hive — cajas NoSQL en disco local; patrón `openBox(boxName)` ya establecido en el proyecto  
**Testing**: `flutter_test` + `mocktail ^1.0.4` — tests unitarios de dominio e infraestructura  
**Target Platform**: Android / iOS (mobile-first); la app ya corre en ambas plataformas  
**Project Type**: Mobile app (Flutter)  
**Performance Goals**: 60 fps constante; cálculos de subtotales y totales instantáneos (sin operaciones async en la UI)  
**Constraints**: 100 % offline; sin sincronización en la nube; single-user (A-001, A-008)  
**Scale/Scope**: ~4 nuevas entidades de dominio, ~4 gateways, ~10 casos de uso, ~4 adaptadores Hive, ~4 providers Riverpod, ~8 páginas UI

## Constitution Check

*GATE: Debe pasar antes de la Fase 0. Re-verificar tras el diseño de la Fase 1.*

| Principio | Estado | Evidencia |
|-----------|--------|-----------|
| I. Domain Isolation | ✅ PASS | Todas las nuevas entidades son Dart puro; ningún import externo en `lib/domain/` |
| II. Dependency Inversion & Constructor Injection | ✅ PASS | Gateways se inyectan por constructor en cada Use Case; Providers instancian Adapters y los pasan al Use Case |
| III. Strict Layer Separation | ✅ PASS | UI → Config → Domain ← Infrastructure; ningún cruce invertido planificado |
| IV. Test-First Development | ✅ PASS | Tests unitarios definidos para todas las entidades, gateways y use cases antes de su implementación |
| V. Code & Language Conventions | ✅ PASS | Identificadores en inglés, textos UI en español; sufijos `Gateway`, `UseCase`, `HiveAdapter`; método único `execute()` |

**Resultado**: Sin violaciones. Se puede proceder a la Fase 0.

## Project Structure

### Documentation (this feature)

```text
specs/001-gestion-clientes-cuentas-cobro/
├── plan.md              # Este archivo — salida de /speckit.plan
├── research.md          # Fase 0 — decisiones técnicas y patrones
├── data-model.md        # Fase 1 — entidades, atributos, relaciones
├── quickstart.md        # Fase 1 — guía de inicialización
├── contracts/           # Fase 1 — contratos de Gateway (interfaces públicas)
│   ├── client_gateway.md
│   ├── catalog_item_gateway.md
│   ├── issuer_config_gateway.md
│   └── invoice_gateway.md
└── tasks.md             # Fase 2 — salida de /speckit.tasks (aún no creado)
```

### Source Code (valora_code/)

```text
valora_code/lib/
├── domain/
│   ├── models/
│   │   ├── client/
│   │   │   ├── client.dart                          # Entidad Cliente
│   │   │   ├── client_exception.dart                # Excepción de dominio
│   │   │   └── gateway/
│   │   │       └── client_gateway.dart              # Contrato CRUD de Cliente
│   │   ├── catalog_item/
│   │   │   ├── catalog_item.dart                    # Entidad Ítem del catálogo
│   │   │   ├── catalog_item_exception.dart
│   │   │   └── gateway/
│   │   │       └── catalog_item_gateway.dart
│   │   ├── issuer_config/
│   │   │   ├── issuer_config.dart                   # Entidad Configuración del emisor
│   │   │   └── gateway/
│   │   │       └── issuer_config_gateway.dart
│   │   └── invoice/
│   │       ├── invoice.dart                         # Entidad Cuenta de Cobro
│   │       ├── invoice_line.dart                    # Value Object Línea
│   │       ├── issuer_snapshot.dart                 # Snapshot inmutable del emisor
│   │       ├── client_snapshot.dart                 # Snapshot inmutable del cliente
│   │       ├── invoice_exception.dart
│   │       └── gateway/
│   │           └── invoice_gateway.dart
│   └── usecase/
│       ├── client/
│       │   ├── get_all_clients_use_case.dart
│       │   ├── get_client_by_id_use_case.dart
│       │   └── save_client_use_case.dart
│       ├── catalog_item/
│       │   ├── get_all_catalog_items_use_case.dart
│       │   ├── get_catalog_item_by_id_use_case.dart
│       │   └── save_catalog_item_use_case.dart
│       ├── issuer_config/
│       │   ├── get_issuer_config_use_case.dart
│       │   └── save_issuer_config_use_case.dart
│       └── invoice/
│           ├── create_invoice_use_case.dart         # Genera número consecutivo + persiste
│           ├── get_all_invoices_use_case.dart
│           └── get_invoice_by_id_use_case.dart
├── infrastructure/
│   ├── driven_adapters/
│   │   ├── client/
│   │   │   └── client_hive_adapter.dart             # implements ClientGateway
│   │   ├── catalog_item/
│   │   │   └── catalog_item_hive_adapter.dart
│   │   ├── issuer_config/
│   │   │   └── issuer_config_hive_adapter.dart
│   │   └── invoice/
│   │       └── invoice_hive_adapter.dart
│   └── helpers/mappers/
│       ├── client_mapper.dart                       # clientToJson / clientFromJson
│       ├── catalog_item_mapper.dart
│       ├── issuer_config_mapper.dart
│       └── invoice_mapper.dart                      # incluye InvoiceLine, snapshots
├── config/
│   └── providers/
│       ├── client_provider.dart                     # StateNotifier<ClientState>
│       ├── catalog_item_provider.dart
│       ├── issuer_config_provider.dart
│       └── invoice_provider.dart
└── ui/
    ├── pages/
    │   ├── client/
    │   │   ├── client_list_page.dart
    │   │   └── client_form_page.dart
    │   ├── catalog_item/
    │   │   ├── catalog_item_list_page.dart
    │   │   └── catalog_item_form_page.dart
    │   ├── issuer_config/
    │   │   └── issuer_config_page.dart
    │   └── invoice/
    │       ├── invoice_list_page.dart
    │       ├── invoice_form_page.dart
    │       └── invoice_detail_page.dart
    └── widgets/
        └── invoice/
            ├── invoice_line_tile.dart
            └── invoice_summary_card.dart

valora_code/test/
├── domain/
│   ├── models/
│   │   ├── client/
│   │   ├── catalog_item/
│   │   ├── issuer_config/
│   │   └── invoice/
│   └── usecase/
│       ├── client/
│       ├── catalog_item/
│       ├── issuer_config/
│       └── invoice/
└── infrastructure/
    └── driven_adapters/
        ├── client/
        ├── catalog_item/
        ├── issuer_config/
        └── invoice/
```

**Structure Decision**: Proyecto Flutter único (`valora_code/`). Se reutiliza el patrón arquitectónico 100 % establecido: entidades Dart puras + Gateways abstractos en `domain/`, adaptadores Hive en `infrastructure/driven_adapters/`, mappers puros en `infrastructure/helpers/mappers/`, StateNotifier Riverpod en `config/providers/`, y páginas/widgets en `ui/`.

## Complexity Tracking

> Sin violaciones de constitución; no se requiere justificación de complejidad.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
