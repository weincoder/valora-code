# Research: Gestión de Clientes y Cuentas de Cobro

**Feature**: `001-gestion-clientes-cuentas-cobro`  
**Phase**: 0 — Investigación técnica  
**Date**: 2026-05-07

---

## 1. Persistencia local con Hive

**Decision**: Usar `hive ^2.2.3` + `hive_flutter ^1.1.0` (ya instalados).  
**Rationale**: El proyecto ya emplea Hive en todos los adaptadores existentes (`ExpenseHiveAdapter`, `SaleRecordHiveAdapter`, etc.). El patrón `Hive.openBox(boxName)` + `box.put(id, json)` está probado y es consistente con la arquitectura. No se requiere ninguna dependencia adicional.  
**Alternatives considered**:
- `sqflite` (SQLite relacional): rechazado porque añadiría una dependencia nueva y requeriría migraciones de esquema, añadiendo complejidad innecesaria (YAGNI).
- `shared_preferences`: rechazado porque no está diseñado para colecciones de entidades; sólo apropiado para configuración clave-valor simple.

---

## 2. Gestión de estado con Riverpod

**Decision**: Usar `flutter_riverpod ^2.6.1` con el patrón `StateNotifier<T>` (ya establecido).  
**Rationale**: Todos los providers existentes (`SaleRecordNotifier`, `ExpenseNotifier`, etc.) usan `StateNotifier<State>` con Riverpod. La constitución menciona `ChangeNotifier`, pero el código real ya migró a Riverpod — se sigue el código existente para coherencia del proyecto.  
**Pattern used**:
```dart
// State inmutable con copyWith
class ClientState { final List<Client> clients; final bool isLoading; final String? error; }

// Notifier con Use Cases inyectados por constructor
class ClientNotifier extends StateNotifier<ClientState> { ... }

// Provider global
final clientProvider = StateNotifierProvider<ClientNotifier, ClientState>((ref) {
  final gateway = ClientHiveAdapter();
  return ClientNotifier(
    getAll: GetAllClientsUseCase(gateway: gateway),
    save: SaveClientUseCase(gateway: gateway),
  );
});
```
**Alternatives considered**:
- `ChangeNotifier`: descartado porque el código existente ya usa Riverpod y mezclarlos crearía inconsistencia.

---

## 3. Numeración consecutiva de Cuentas de Cobro

**Decision**: Almacenar el `nextConsecutive` (entero) dentro de la entidad `IssuerConfig`. Al crear una cuenta de cobro, el `CreateInvoiceUseCase` lee la config actual, genera el número, incrementa el contador y persiste ambos (invoice + config actualizada) en una secuencia síncrona.  
**Rationale**: La app es single-user y offline (A-001, A-008), por lo que no existe concurrencia real. No se necesita un mecanismo de transacciones distribuidas. El número nunca se reutiliza porque el contador sólo sube.  
**Format**: `"${config.invoicePrefix}-${nextConsecutive.toString().padLeft(4, '0')}"` → ej. `CC-0001`.  
**Alternatives considered**:
- Caja Hive separada para el contador: rechazado por complejidad innecesaria; el contador forma parte lógica de la configuración del emisor.
- Timestamp como ID: rechazado porque la spec requiere un número consecutivo legible y configurable.

---

## 4. Snapshots de datos en Cuentas de Cobro

**Decision**: Al crear una `Invoice`, se copian (snapshot) los datos del emisor (`IssuerSnapshot`) y del cliente (`ClientSnapshot`) dentro del documento. Las `InvoiceLine` copian `itemName` y `unitPrice` del `CatalogItem` elegido.  
**Rationale**: FR-012 y FR-014 exigen explícitamente que cambios futuros en clientes, catálogo o configuración del emisor no afecten cuentas ya guardadas. Un snapshot inmutable es la solución más simple y directa.  
**Implementation**: `IssuerSnapshot` y `ClientSnapshot` son clases Dart puras sin herencia; se serializan junto con la `Invoice` en el mismo mapa JSON en Hive.  
**Alternatives considered**:
- Guardar solo los IDs y resolver en runtime: rechazado porque viola FR-012/FR-014.
- Entity references con versioning: demasiado complejo para el alcance single-user definido.

---

## 5. Validaciones de dominio

**Decision**: Las validaciones de unicidad del NIT/documento del cliente y el formato de email se implementan en el `SaveClientUseCase`, que consulta el gateway antes de persistir. Si hay conflicto, lanza `ClientException`.  
**Rationale**: La lógica de negocio debe vivir en el dominio (constitución Principio I). El Use Case tiene acceso al Gateway y puede verificar unicidad antes de guardar.  
**Validation rules**:
- `documentId` único: `getAll()` → verificar que ningún cliente existente tenga el mismo `documentId` (excluyendo el propio en edición).
- Email regex: validación con `RegExp` en el Use Case o en la entidad `Client`.
- Cantidad > 0 en `InvoiceLine`: validado en el `CreateInvoiceUseCase`.
- Precio unitario ≥ 0: permitido (servicios gratuitos, edge case de la spec).

---

## 6. Navegación con go_router

**Decision**: Añadir nuevas rutas al `AppRouter` existente siguiendo el patrón ya establecido con `GoRoute`.  
**New routes**:
```
/clients                 → ClientListPage
/clients/new             → ClientFormPage
/clients/:id             → ClientFormPage (edición)
/catalog                 → CatalogItemListPage
/catalog/new             → CatalogItemFormPage
/catalog/:id             → CatalogItemFormPage (edición)
/issuer-config           → IssuerConfigPage
/invoices                → InvoiceListPage
/invoices/new            → InvoiceFormPage
/invoices/:id/detail     → InvoiceDetailPage
```
**Rationale**: Patrón idéntico al existente para `sale`, `expense`, `product`.

---

## 7. Dart 3 — Features aplicables

**Decision**: Usar Records y Pattern Matching de Dart 3 donde aporten legibilidad real, sin over-engineering.  
**Applicable uses**:
- **Records** para resultados de validación compuesta: `(bool isValid, String? error)` como tipo de retorno en helpers de validación.
- **Pattern matching (`switch` expressions)** en los mappers para parsear strings a enums o para manejar variantes de error.
- **Named constructors** en entidades para construcción semántica (ej. `Invoice.create(...)`).
**Alternatives considered**:
- Sealed classes para resultados de Use Cases: evaluado pero descartado por ahora — añade complejidad sin beneficio claro dado el patrón simple de throw/catch ya establecido.

---

## Resolución de incógnitas

Todas las incógnitas técnicas identificadas en el Technical Context han sido resueltas:

| Incógnita | Resolución |
|-----------|------------|
| ¿Cómo persistir los datos del módulo? | Hive (patrón existente, sin nueva dependencia) |
| ¿Cómo gestionar el estado? | Riverpod StateNotifier (patrón existente) |
| ¿Cómo garantizar unicidad del número de cuenta? | Counter en `IssuerConfig`, incremento síncrono en `CreateInvoiceUseCase` |
| ¿Cómo evitar que cambios en clientes/emisor afecten cuentas? | Snapshots inmutables en `Invoice` |
| ¿Dónde viven las validaciones de negocio? | En los Use Cases (dominio) |
| ¿Cómo integrar Dart 3? | Records para validación; pattern matching en mappers |
