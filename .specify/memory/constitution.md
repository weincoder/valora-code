<!--
SYNC IMPACT REPORT
==================
Version change: [unversioned] → 1.0.0
Modified principles: N/A (initial fill from template)
Added sections: Core Principles (I–V), Architecture Constraints, Development Workflow, Governance
Removed sections: All placeholder tokens replaced
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ — "Constitution Check" gates now derivable from this constitution
  - .specify/templates/spec-template.md ✅ — Layer-separation constraints apply to all future specs
  - .specify/templates/tasks-template.md ✅ — Task phases must include Domain, Infrastructure, UI and Config
  - .specify/templates/checklist-template.md ⚠ pending (review layer-compliance items)
Deferred TODOs: none
-->

# Valora Code Constitution

## Core Principles

### I. Domain Isolation (NON-NEGOTIABLE)

The Domain layer MUST have zero external dependencies — only pure Dart code is permitted
inside `lib/domain/`. No `package:flutter/material.dart`, no HTTP clients, no third-party
packages of any kind may be imported from this layer.

- Entities: MUST contain only properties and pure business logic.
- Gateways: MUST be `abstract` classes with the `Gateway` suffix, placed in
  `lib/domain/models/<entity>/gateway/`.
- Use Cases: MUST accept a Gateway via constructor injection and never reference
  any concrete infrastructure class.

Every future specification or architectural plan MUST treat Domain isolation as an
unbreakable constraint. Any proposal that requires the Domain layer to import an
external package is automatically invalid.

### II. Dependency Inversion & Constructor Injection

All concrete dependencies MUST be injected through constructors. Direct instantiation
of Infrastructure classes inside Use Cases or UI widgets is PROHIBITED.

- `UI` and `Infrastructure` layers depend on `Domain`; `Domain` depends on nothing.
- Providers (`lib/config/providers/`) are the sole composition root: they instantiate
  concrete Adapters, pass them to Use Cases, and expose state to the UI.
- Providers MUST call Use Cases. Calling a Gateway directly from a Provider is PROHIBITED.
- No service locator pattern or global singletons may be introduced without an
  explicit amendment to this constitution.

### III. Strict Layer Separation

The codebase is organized into four non-negotiable layers with a fixed directory contract:

```
lib/
├── domain/           # Zero external deps — business logic only
│   ├── models/       # Entities & abstract Gateways
│   └── usecase/      # Use Cases
├── infrastructure/   # Concrete implementations
│   ├── driven_adapters/   # API, DB, Service adapters (implement Gateways)
│   └── helpers/mappers/   # Pure functions: DTO/JSON → Domain Entity
├── ui/               # Presentation — zero business logic
│   ├── pages/
│   └── widgets/
└── config/           # DI composition root
    ├── providers/    # State managers (ChangeNotifier-based)
    └── routes/       # Navigation
```

Crossing layer boundaries in the wrong direction (e.g., UI importing Infrastructure,
Domain importing UI) constitutes an architectural violation and MUST be rejected in
code review.

Mapper functions in `helpers/mappers/` MUST be pure functions. Returning raw JSON or
DTO objects beyond the Infrastructure layer is PROHIBITED.

### IV. Test-First Development

Unit tests MUST be written before or alongside implementation. The Red-Green-Refactor
cycle MUST be followed for all Domain and Infrastructure code.

- Domain entities, Gateways, and Use Cases MUST each have dedicated unit tests.
- Infrastructure Adapters MUST be tested with mocked HTTP clients or fake services.
- UI Providers MUST be tested with mocked Use Cases, never real Infrastructure.
- Widget tests MUST use mocked Providers; real network calls in tests are PROHIBITED.
- Test file locations MUST mirror the `lib/` structure under `test/`.

### V. Code & Language Conventions

All identifiers (class names, methods, variables, file names) MUST be written in
English. UI-visible text strings MUST be written in Spanish.

- Adapter classes MUST use `implements <Entity>Gateway`.
- Gateway contracts MUST use the `Gateway` suffix.
- Use Cases MUST expose a single public `execute()` method.
- No third-party pub.dev package may be added without explicit request and team review.
  This keeps the dependency graph minimal and auditable.
- Design MUST follow Material Design guidelines with a centralized theme; hardcoded
  colors or styles scattered across widgets are PROHIBITED.

## Architecture Constraints

**Technology stack**: Flutter (Dart) · Material Design · ChangeNotifier state management.

**Forbidden patterns**:
- Service locators / global mutable state.
- Business logic in widget `build()` methods.
- Raw JSON structures (`Map<String, dynamic>`) returned beyond the Infrastructure layer.
- Skipping the mapper layer to pass DTOs directly to Use Cases or UI.

**Performance baseline**: UI MUST remain responsive (60 fps target). Heavy work MUST be
offloaded to Use Cases or Isolates; never block the UI thread in widget code.

**Security**: No credentials, tokens, or secrets may be hardcoded in source files.
Infrastructure Adapters MUST retrieve sensitive values from secure storage or environment
configuration.

## Development Workflow

1. **Spec first**: Every new feature starts with a specification (`spec.md`) that defines
   user stories with acceptance criteria before any code is written.
2. **Domain design gate**: The Domain model (Entities, Gateways, Use Cases) MUST be
   designed and reviewed before Infrastructure or UI work begins.
3. **Constitution check on every plan**: `plan.md` MUST include a "Constitution Check"
   section verifying all five principles are satisfied before Phase 0 research.
4. **Layer-by-layer tasks**: Task lists MUST be organized in the order:
   Domain → Infrastructure → Config/Providers → UI. Cross-layer tasks in the wrong
   order MUST be rejected.
5. **Code review gate**: Any PR that imports an external package into `lib/domain/` or
   instantiates Infrastructure classes outside `lib/config/providers/` MUST be blocked.

6. **Skill Enforcement**: All test generation MUST utilize the local @dart-testing.md skill. All commits MUST be structured using the @commit.md skill to maintain repository standards.

## Governance

This constitution supersedes all other coding guidelines and LLM instructions for this
project. Amendments require:

1. A documented rationale explaining why the change is necessary.
2. An update to `CONSTITUTION_VERSION` following semantic versioning rules.
3. Propagation of the change to all affected templates and command files.
4. Update of `LAST_AMENDED_DATE` to the date of the amendment.

All feature plans and implementation tasks MUST be validated against this constitution
before execution. Complexity MUST be justified; if a simpler approach satisfies the
architecture, it MUST be preferred (YAGNI).

The runtime development guidance file is `.github/instructions/copilot-instructions.md`.

**Version**: 1.0.0 | **Ratified**: 2026-05-07 | **Last Amended**: 2026-05-07
