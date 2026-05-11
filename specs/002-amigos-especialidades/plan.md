# Implementation Plan: Gestión de Amigos y Especialidades

**Branch**: `002-amigos-especialidades` | **Date**: 2026-05-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-amigos-especialidades/spec.md`

## Summary

Módulo de directorio de talento que permite registrar amigos/colegas con nombre, foto, áreas de conocimiento (chips), valor por hora y moneda (COP/USD). Sigue la Clean Architecture existente (Domain → Infrastructure → Config/Provider → UI), reutiliza los componentes visuales del proyecto (`RetroBackground`, `OwlMascot`, `_ToolCard`, estilo de tarjetas de cuentas de cobro) e introduce la entidad `Friend` con su stack completo de capas. El NavBar se extiende de 4 a 5 ramas.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x (SDK ^3.11.0)  
**Primary Dependencies**: flutter_riverpod ^2.6.1 (StateNotifier), hive ^2.2.3 + hive_flutter, go_router ^14.6.2, image_picker ^1.1.2, intl ^0.19.0, uuid ^4.5.1  
**Storage**: Hive — nueva caja `friends` (`Box<Map>`)  
**Testing**: flutter_test + mocktail ^1.0.4  
**Target Platform**: Android + iOS (mobile-first)  
**Project Type**: Mobile app — módulo nuevo dentro de monorepo Flutter en `valora_code/`  
**Performance Goals**: 60 fps — lista de amigos renderizada sin bloquear el hilo UI  
**Constraints**: Offline-capable; sin nuevas dependencias de red; sin pub.dev packages nuevos  
**Scale/Scope**: Directorio personal, se esperan decenas de amigos (no miles)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Estado | Evidencia |
|---|---|---|
| I. Domain Isolation | ✅ PASS | `Friend`, `FriendException`, `FriendGateway`, use cases — sólo Dart puro |
| II. Dependency Inversion | ✅ PASS | `FriendHiveAdapter` inyectado en use cases dentro de `friendProvider`; Provider = única composition root |
| III. Layer Separation | ✅ PASS | `lib/domain/` → `lib/infrastructure/` → `lib/config/providers/` → `lib/ui/` — flujo unidireccional |
| IV. Test-First Development | ✅ PASS | Se planifican tests por entidad, use case y provider antes de UI |
| V. Code & Language Conventions | ✅ PASS | Identificadores en inglés; strings UI en español; Gateway suffix; execute() único |

**Post-design re-check**: Sin violaciones detectadas. La extensión del NavBar a 5 tabs es un cambio UI puro sin impacto en capas de dominio.

## Project Structure

### Documentation (this feature)

```text
specs/002-amigos-especialidades/
├── plan.md        ← este archivo
├── research.md    ← decisiones técnicas y patrones resueltos
├── data-model.md  ← modelo de datos y contratos internos
├── quickstart.md  ← guía de implementación rápida para el agente
└── tasks.md       ← generado por /speckit.tasks (NO por /speckit.plan)
```

### Source Code — archivos nuevos y modificados

```text
valora_code/
├── lib/
│   ├── domain/
│   │   └── models/
│   │       └── friend/
│   │           ├── friend.dart                          [NEW]
│   │           ├── friend_exception.dart                [NEW]
│   │           └── gateway/
│   │               └── friend_gateway.dart              [NEW]
│   │   └── usecase/
│   │       └── friend/
│   │           ├── get_all_friends_use_case.dart        [NEW]
│   │           ├── get_friend_by_id_use_case.dart       [NEW]
│   │           ├── save_friend_use_case.dart            [NEW]
│   │           └── delete_friend_use_case.dart          [NEW]
│   ├── infrastructure/
│   │   ├── driven_adapters/
│   │   │   └── friend/
│   │   │       └── friend_hive_adapter.dart             [NEW]
│   │   └── helpers/
│   │       ├── mappers/
│   │       │   └── friend_mapper.dart                   [NEW]
│   │       └── currency_format_helper.dart              [MODIFY — añadir formatCurrency()]
│   ├── config/
│   │   ├── providers/
│   │   │   └── friend_provider.dart                     [NEW]
│   │   └── routes/
│   │       └── app_router.dart                          [MODIFY — rutas amigos + 5ª rama shell]
│   └── ui/
│       ├── pages/
│       │   └── friend/
│       │       ├── friend_list_page.dart                [NEW]
│       │       └── friend_form_page.dart                [NEW]
│       ├── widgets/
│       │   └── app_shell.dart                           [MODIFY — 5 tabs]
│       └── pages/
│           └── tools/
│               └── tools_page.dart                      [MODIFY — tarjeta Amigos]
├── main.dart                                            [MODIFY — abrir caja 'friends']
└── test/
    ├── domain/
    │   └── usecase/
    │       └── friend/
    │           └── save_friend_use_case_test.dart        [NEW]
    ├── config/
    │   └── providers/
    │       └── friend_provider_test.dart                 [NEW]
    └── infrastructure/
        └── driven_adapters/
            └── friend/
                └── friend_hive_adapter_test.dart         [NEW]
```

## Complexity Tracking

> Sin violaciones de constitución — sin entradas requeridas.

