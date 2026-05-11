# Contract: ClientGateway

**Capa**: `lib/domain/models/client/gateway/client_gateway.dart`  
**Feature**: `001-gestion-clientes-cuentas-cobro`

## Propósito

Define el contrato de persistencia para la entidad `Client`. Cualquier implementación concreta (actualmente `ClientHiveAdapter`) debe cumplir este contrato sin que el dominio conozca los detalles de almacenamiento.

## Interfaz

```dart
abstract class ClientGateway {
  /// Retorna la lista completa de clientes persistidos.
  Future<List<Client>> getAll();

  /// Retorna el cliente con el [id] dado, o `null` si no existe.
  Future<Client?> getById(String id);

  /// Retorna el cliente con el [documentId] dado, o `null` si no existe.
  /// Usado para validar unicidad antes de guardar.
  Future<Client?> getByDocumentId(String documentId);

  /// Persiste un nuevo cliente o actualiza uno existente (identificado por [client.id]).
  Future<void> save(Client client);

  /// Elimina el cliente con el [id] dado. No lanza error si no existe.
  Future<void> delete(String id);
}
```

## Casos de uso que consumen este contrato

| Use Case | Operaciones |
|----------|-------------|
| `GetAllClientsUseCase` | `getAll()` |
| `GetClientByIdUseCase` | `getById(id)` |
| `SaveClientUseCase` | `getByDocumentId(documentId)` + `save(client)` |

## Invariantes

- `getAll()` nunca retorna `null`; retorna lista vacía si no hay clientes.
- `save()` es un upsert: crea si el `id` no existe, actualiza si ya existe.
- `getByDocumentId()` se usa exclusivamente para validación de unicidad antes de persistir.
