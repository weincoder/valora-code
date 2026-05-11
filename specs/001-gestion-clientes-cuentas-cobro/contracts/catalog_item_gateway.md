# Contract: CatalogItemGateway

**Capa**: `lib/domain/models/catalog_item/gateway/catalog_item_gateway.dart`  
**Feature**: `001-gestion-clientes-cuentas-cobro`

## Propósito

Define el contrato de persistencia para la entidad `CatalogItem`. Gestiona el catálogo de productos y servicios facturables disponibles para añadir a una cuenta de cobro.

## Interfaz

```dart
abstract class CatalogItemGateway {
  /// Retorna la lista completa de ítems del catálogo.
  Future<List<CatalogItem>> getAll();

  /// Retorna el ítem con el [id] dado, o `null` si no existe.
  Future<CatalogItem?> getById(String id);

  /// Persiste un nuevo ítem o actualiza uno existente (upsert por [item.id]).
  Future<void> save(CatalogItem item);

  /// Elimina el ítem con el [id] dado. No lanza error si no existe.
  Future<void> delete(String id);
}
```

## Casos de uso que consumen este contrato

| Use Case | Operaciones |
|----------|-------------|
| `GetAllCatalogItemsUseCase` | `getAll()` |
| `GetCatalogItemByIdUseCase` | `getById(id)` |
| `SaveCatalogItemUseCase` | `save(item)` |

## Invariantes

- `getAll()` nunca retorna `null`; retorna lista vacía si no hay ítems.
- `getById()` retorna `null` (no lanza excepción) si el ítem no existe.
- Eliminar un ítem del catálogo no afecta cuentas de cobro ya creadas (las líneas usan snapshots de nombre y precio).
