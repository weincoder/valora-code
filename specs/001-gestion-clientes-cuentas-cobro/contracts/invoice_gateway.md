# Contract: InvoiceGateway

**Capa**: `lib/domain/models/invoice/gateway/invoice_gateway.dart`  
**Feature**: `001-gestion-clientes-cuentas-cobro`

## Propósito

Define el contrato de persistencia para la entidad `Invoice` (Cuenta de Cobro). Las cuentas de cobro son **inmutables** una vez creadas (A-006): no se expone operación de actualización ni eliminación en esta versión.

## Interfaz

```dart
abstract class InvoiceGateway {
  /// Retorna la lista completa de cuentas de cobro guardadas,
  /// ordenadas por fecha de creación descendente (más reciente primero).
  Future<List<Invoice>> getAll();

  /// Retorna la cuenta de cobro con el [id] dado, o `null` si no existe.
  Future<Invoice?> getById(String id);

  /// Persiste una nueva cuenta de cobro.
  /// Sólo se llama desde `CreateInvoiceUseCase`.
  /// No se expone método de actualización ni eliminación (A-006).
  Future<void> save(Invoice invoice);
}
```

## Casos de uso que consumen este contrato

| Use Case | Operaciones |
|----------|-------------|
| `GetAllInvoicesUseCase` | `getAll()` |
| `GetInvoiceByIdUseCase` | `getById(id)` |
| `CreateInvoiceUseCase` | `save(invoice)` |

## Invariantes

- `getAll()` nunca retorna `null`; retorna lista vacía si no hay cuentas.
- `getById()` retorna `null` (no lanza excepción) si la cuenta no existe.
- `save()` sólo se llama con una nueva `Invoice` (id único recién generado); no se usa como upsert.
- No existen métodos `update()` ni `delete()` en esta versión (A-006: cuentas inmutables).
- Cada `Invoice` persistida contiene snapshots completos del emisor, del cliente y de cada línea; no hay referencias externas que resolver en lectura.

## Nota sobre serialización

El mapper `invoiceFromJson` / `invoiceToJson` (en `lib/infrastructure/helpers/mappers/invoice_mapper.dart`) es responsable de serializar el grafo completo: `IssuerSnapshot`, `ClientSnapshot` y la lista de `InvoiceLine`, todo embebido en el mismo mapa JSON de Hive.
