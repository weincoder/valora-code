# Contract: IssuerConfigGateway

**Capa**: `lib/domain/models/issuer_config/gateway/issuer_config_gateway.dart`  
**Feature**: `001-gestion-clientes-cuentas-cobro`

## Propósito

Define el contrato de persistencia para la configuración del emisor (`IssuerConfig`). Es un singleton: existe exactamente una instancia en el sistema, almacenada con clave fija `"issuer_config"` en Hive. También gestiona el contador de numeración consecutiva.

## Interfaz

```dart
abstract class IssuerConfigGateway {
  /// Retorna la configuración del emisor actual.
  /// Retorna `null` si aún no ha sido configurada (primer uso de la app).
  Future<IssuerConfig?> get();

  /// Persiste o actualiza la configuración del emisor.
  /// Usado tanto en la pantalla de configuración como en `CreateInvoiceUseCase`
  /// para incrementar `nextConsecutive` tras crear una cuenta.
  Future<void> save(IssuerConfig config);
}
```

## Casos de uso que consumen este contrato

| Use Case | Operaciones |
|----------|-------------|
| `GetIssuerConfigUseCase` | `get()` |
| `SaveIssuerConfigUseCase` | `save(config)` |
| `CreateInvoiceUseCase` | `get()` + `save(config.copyWith(nextConsecutive: n + 1))` |

## Invariantes

- `get()` retorna `null` (no lanza excepción) si no hay configuración guardada; la UI debe guiar al usuario a la pantalla de configuración.
- `save()` es siempre un upsert con clave fija; no es posible crear múltiples instancias.
- `nextConsecutive` en la entidad `IssuerConfig` es la fuente de verdad para la numeración; sólo `CreateInvoiceUseCase` lo incrementa.
