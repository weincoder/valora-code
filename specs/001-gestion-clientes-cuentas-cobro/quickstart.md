# Quickstart: Gestión de Clientes y Cuentas de Cobro

**Feature**: `001-gestion-clientes-cuentas-cobro`  
**Branch**: `001-gestion-clientes-cuentas-cobro`

## Prerequisitos

El proyecto `valora_code` ya tiene todas las dependencias necesarias instaladas:

```yaml
# pubspec.yaml — ya presente, no añadir nada nuevo
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_riverpod: ^2.6.1
  go_router: ^14.6.2
  uuid: ^4.5.1
```

No se requiere `flutter pub add` adicional.

---

## Registro de cajas Hive

Las nuevas cajas deben inicializarse en `main.dart` junto a las existentes. Añadir:

```dart
// En main() → antes de runApp()
await Hive.openBox('clients');
await Hive.openBox('catalog_items');
await Hive.openBox('issuer_config');
await Hive.openBox('invoices');
```

**Nombres de caja** (constantes definidas en cada Adapter):

| Adapter | Constante | Caja Hive |
|---------|-----------|-----------|
| `ClientHiveAdapter` | `_boxName = 'clients'` | `clients` |
| `CatalogItemHiveAdapter` | `_boxName = 'catalog_items'` | `catalog_items` |
| `IssuerConfigHiveAdapter` | `_boxName = 'issuer_config'` | `issuer_config` |
| `InvoiceHiveAdapter` | `_boxName = 'invoices'` | `invoices` |

---

## Registro de rutas go_router

Añadir en `AppRouter` (`lib/config/routes/app_router.dart`):

```dart
// Constantes de ruta
static const String clients       = '/clients';
static const String clientNew     = '/clients/new';
static const String clientEdit    = '/clients/:id';
static const String catalog       = '/catalog';
static const String catalogNew    = '/catalog/new';
static const String catalogEdit   = '/catalog/:id';
static const String issuerConfig  = '/issuer-config';
static const String invoices      = '/invoices';
static const String invoiceNew    = '/invoices/new';
static const String invoiceDetail = '/invoices/:id/detail';

// GoRoutes a añadir en la lista de routes del GoRouter
GoRoute(path: '/clients',            builder: (_, _) => const ClientListPage()),
GoRoute(path: '/clients/new',        builder: (_, _) => const ClientFormPage()),
GoRoute(path: '/clients/:id',        builder: (_, s) => ClientFormPage(clientId: s.pathParameters['id'])),
GoRoute(path: '/catalog',            builder: (_, _) => const CatalogItemListPage()),
GoRoute(path: '/catalog/new',        builder: (_, _) => const CatalogItemFormPage()),
GoRoute(path: '/catalog/:id',        builder: (_, s) => CatalogItemFormPage(itemId: s.pathParameters['id'])),
GoRoute(path: '/issuer-config',      builder: (_, _) => const IssuerConfigPage()),
GoRoute(path: '/invoices',           builder: (_, _) => const InvoiceListPage()),
GoRoute(path: '/invoices/new',       builder: (_, _) => const InvoiceFormPage()),
GoRoute(path: '/invoices/:id/detail', builder: (_, s) => InvoiceDetailPage(invoiceId: s.pathParameters['id']!)),
```

---

## Orden de implementación por fases

### Fase 1 — Domain (sin dependencias externas)

1. Entidades y value objects:
   - `client.dart`, `client_exception.dart`, `client_gateway.dart`
   - `catalog_item.dart`, `catalog_item_exception.dart`, `catalog_item_gateway.dart`
   - `issuer_config.dart`, `issuer_config_gateway.dart`
   - `invoice_line.dart`, `issuer_snapshot.dart`, `client_snapshot.dart`, `invoice.dart`, `invoice_exception.dart`, `invoice_gateway.dart`

2. Tests unitarios de entidades (AAA, mocktail):
   - `test/domain/models/client/client_test.dart`
   - `test/domain/models/invoice/invoice_test.dart` (validar cálculo de `total`)

3. Use Cases + sus tests:
   - `test/domain/usecase/client/save_client_use_case_test.dart` (mock ClientGateway)
   - `test/domain/usecase/invoice/create_invoice_use_case_test.dart`

### Fase 2 — Infrastructure

4. Mappers puros:
   - `client_mapper.dart`, `catalog_item_mapper.dart`, `issuer_config_mapper.dart`, `invoice_mapper.dart`

5. Adapters Hive:
   - `ClientHiveAdapter`, `CatalogItemHiveAdapter`, `IssuerConfigHiveAdapter`, `InvoiceHiveAdapter`

6. Tests de adapters (fake Hive box o `Hive.init(tempDir.path)`):
   - `test/infrastructure/driven_adapters/client/client_hive_adapter_test.dart`
   - `test/infrastructure/driven_adapters/invoice/invoice_hive_adapter_test.dart`

### Fase 3 — Config (Providers Riverpod)

7. Providers con Use Cases inyectados:
   - `client_provider.dart`, `catalog_item_provider.dart`, `issuer_config_provider.dart`, `invoice_provider.dart`

8. Tests de providers con mocks de Use Cases.

### Fase 4 — UI

9. Páginas (en orden de dependencia funcional):
   - `IssuerConfigPage` → `ClientListPage` + `ClientFormPage` → `CatalogItemListPage` + `CatalogItemFormPage` → `InvoiceListPage` → `InvoiceFormPage` → `InvoiceDetailPage`

10. Widgets compartidos:
    - `InvoiceLineTile`, `InvoiceSummaryCard`

11. Registro de rutas en `AppRouter`.

12. Inicialización de cajas Hive en `main.dart`.

---

## Verificación rápida post-implementación

```bash
cd valora_code

# Análisis estático
dart analyze

# Tests
flutter test

# Cobertura (opcional)
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

Todos los tests deben pasar en verde antes de hacer merge a `main`.

---

## Notas de diseño importantes

- **Inmutabilidad de facturas**: `Invoice` no tiene `copyWith` ni métodos mutadores. Una vez creada, sólo se lee.
- **Snapshot vs referencia**: `Invoice` embebe snapshots completos, NO referencias a IDs de `Client` ni `IssuerConfig`. Esto simplifica la lectura y garantiza FR-012/FR-014.
- **Cálculos en tiempo real**: `InvoiceLine.subtotal` e `Invoice.total` son getters puros (sin async). El Provider puede calcular el total del borrador en el estado sin ninguna llamada a disco.
- **Dart 3 Records**: Usar para typing de validaciones compuestas en Use Cases:
  ```dart
  typedef ValidationResult = (bool isValid, String? errorMessage);
  ```
