# Data Model: Gestión de Clientes y Cuentas de Cobro

**Feature**: `001-gestion-clientes-cuentas-cobro`  
**Última revisión**: 2026-05-10 — Eliminación de `CatalogItem` (duplicado de `ProductItem`), adición de imagen en `Client`, generación de PDF en cuentas de cobro.

---

## Decisiones de diseño

| ID | Decisión |
|----|----------|
| A-010 | `CatalogItem` eliminado. Las cuentas de cobro reutilizan `ProductItem` (catálogo de la cotización) para no duplicar datos maestros. |
| A-011 | `Client` soporta imagen opcional (`imageBase64`) para consistencia visual con `ProductItem`. |
| A-012 | La cuenta de cobro se puede exportar como PDF (misma biblioteca `pdf`/`printing` que usa la cotización). |
| A-013 | `InvoiceLine.productItemId` reemplaza a `catalogItemId`; referencia a `ProductItem` original. |

---

## Entidades del Dominio

### 1. `Client` — Cliente

**Capa**: `lib/domain/models/client/client.dart`  
**Descripción**: Persona natural o empresa a quien se emite la cuenta de cobro. Soporta foto/logo opcional.

| Campo | Tipo | Restricciones |
|-------|------|---------------|
| `id` | `String` | UUID v4, generado automáticamente al crear |
| `fullName` | `String` | Requerido, no vacío |
| `documentId` | `String` | Requerido, **único en el sistema** (NIT o cédula) |
| `email` | `String` | Requerido, formato email válido |
| `phone` | `String` | Requerido, texto libre |
| `imageBase64` | `String?` | Opcional; foto de perfil o logo del cliente codificada en base64 |

**Reglas de negocio**:
- No puede existir dos `Client` con el mismo `documentId` (FR-002).
- El `email` debe coincidir con el patrón `user@domain.tld` (FR-003).
- `imageBase64` se almacena directamente en Hive como string; sin validación de formato (A-007).

```dart
class Client {
  final String id;
  final String fullName;
  final String documentId;
  final String email;
  final String phone;
  final String? imageBase64; // nuevo

  const Client({
    required this.id,
    required this.fullName,
    required this.documentId,
    required this.email,
    required this.phone,
    this.imageBase64,
  });

  Client copyWith({ ... });
}
```

---

### 2. ~~`CatalogItem`~~ — **ELIMINADO** (A-010)

> ~~Este modelo ya no existe.~~ Las cuentas de cobro utilizan directamente `ProductItem` del módulo de cotización (`lib/domain/models/product_item/product_item.dart`). Los campos relevantes del `ProductItem` para una cuenta de cobro son `id`, `title`, `salePrice` e `imageBase64`.

---

### 3. `IssuerConfig` — Configuración del Emisor

**Sin cambios respecto al diseño original.**

| Campo | Tipo | Restricciones |
|-------|------|---------------|
| `businessName` | `String` | Requerido |
| `nit` | `String` | Requerido |
| `address` | `String` | Requerido |
| `invoicePrefix` | `String` | Requerido (default `"CC"`) |
| `nextConsecutive` | `int` | ≥ 1, autoincremental |

Getter: `formattedNextNumber` → `"CC-0001"`.

---

### 4. `IssuerSnapshot` — Snapshot del Emisor (Value Object)

**Sin cambios.** Embebido en `Invoice`.

| Campo | Tipo |
|-------|------|
| `businessName` | `String` |
| `nit` | `String` |
| `address` | `String` |
| `invoicePrefix` | `String` |

---

### 5. `ClientSnapshot` — Snapshot del Cliente (Value Object)

Actualizado para incluir imagen.

| Campo | Tipo |
|-------|------|
| `clientId` | `String` |
| `fullName` | `String` |
| `documentId` | `String` |
| `email` | `String` |
| `phone` | `String` |
| `imageBase64` | `String?` |

---

### 6. `InvoiceLine` — Línea de Cuenta de Cobro (Value Object)

`catalogItemId` renombrado a `productItemId` (referencia a `ProductItem`).

| Campo | Tipo | Restricciones |
|-------|------|---------------|
| `productItemId` | `String` | Referencia al `ProductItem` original (auditoría) |
| `itemName` | `String` | Snapshot del `ProductItem.title` al momento de creación |
| `unitPrice` | `double` | Snapshot de `ProductItem.salePrice` (≥ 0) |
| `quantity` | `int` | > 0 |
| `subtotal` | `double` | Getter puro: `unitPrice × quantity` |

---

### 7. `Invoice` — Cuenta de Cobro

**Sin cambios estructurales.** Exportable como PDF.

| Campo | Tipo | Restricciones |
|-------|------|---------------|
| `id` | `String` | UUID v4 |
| `invoiceNumber` | `String` | Generado automáticamente (`CC-0001`), único |
| `issuerSnapshot` | `IssuerSnapshot` | Snapshot al momento de creación |
| `clientSnapshot` | `ClientSnapshot` | Snapshot al momento de creación (incluye imagen) |
| `createdAt` | `DateTime` | Fecha de creación |
| `lines` | `List<InvoiceLine>` | ≥ 1 línea requerida |
| `total` | `double` | Getter: suma de subtotales |

**Generación PDF**: la `InvoiceDetailPage` ofrece un botón "Descargar PDF" que genera un PDF equivalente al de la cotización, con logo del emisor, datos del cliente y tabla de ítems.

---

## Relaciones entre Entidades

```
IssuerConfig ──(snapshot al crear)──► IssuerSnapshot ─┐
                                                        ├──► Invoice ◄── InvoiceLine ──(snapshot)── ProductItem
Client ──────(snapshot al crear)──► ClientSnapshot ───┘

Invoice ──[lista de]──► InvoiceLine
ProductItem ──(reutilizado directamente en InvoiceFormPage)
```

**Notas**:
- `CatalogItem` eliminado. `InvoiceFormPage` carga la lista de `ProductItem` vía `productItemProvider`.
- `ClientSnapshot` ahora incluye `imageBase64` para mostrar el logo del cliente en el PDF.
- `Invoice` permanece inmutable post-creación (A-006).

---

## Excepciones de Dominio

| Clase | Ubicación | Casos de uso |
|-------|-----------|--------------|
| `ClientException` | `lib/domain/models/client/client_exception.dart` | NIT duplicado, email inválido |
| ~~`CatalogItemException`~~ | ~~eliminado~~ | — |
| `InvoiceException` | `lib/domain/models/invoice/invoice_exception.dart` | Sin cliente, sin líneas, cantidad inválida, sin IssuerConfig |

---

## Estado de los Providers (Riverpod)

```dart
// ClientState — agrega soporte imagen
class ClientState {
  final List<Client> clients;
  final bool isLoading;
  final String? error;
}

// InvoiceState — draftLines ahora referencian ProductItem
class InvoiceState {
  final List<Invoice> invoices;
  final bool isLoading;
  final String? error;
  final List<InvoiceLine> draftLines; // construidas desde ProductItem
  final String? selectedClientId;
}
```

---

## Transiciones de Estado — Creación de una Cuenta de Cobro

```
[InvoiceFormPage]
  1. Usuario selecciona cliente (de lista de Client con imagen)
     → invoiceProvider.selectClient(clientId)
  2. Usuario selecciona ProductItem + cantidad
     → invoiceProvider.addLine(InvoiceLine(
          productItemId: item.id,
          itemName: item.title,
          unitPrice: item.salePrice,
          quantity: qty,
        ))
  3. Subtotales calculados en tiempo real (getter puro)
  4. Usuario confirma → invoiceProvider.createInvoice(selectedClient)
     └─► CreateInvoiceUseCase.execute(client, lines)
           ├─► issuerConfigGateway.get() → IssuerConfig
           ├─► Valida: lines.isNotEmpty, config != null
           ├─► Genera invoiceNumber
           ├─► Construye Invoice con snapshots (incluye imageBase64 del client)
           ├─► invoiceGateway.save(invoice)
           └─► issuerConfigGateway.save(config con nextConsecutive + 1)
  5. InvoiceDetailPage muestra la cuenta + botón "Descargar PDF"
```


**Feature**: `001-gestion-clientes-cuentas-cobro`  
**Phase**: 1 — Diseño de entidades  
**Date**: 2026-05-07

---

## Entidades del Dominio

### 1. `Client` — Cliente

**Capa**: `lib/domain/models/client/client.dart`  
**Descripción**: Persona natural o empresa a quien se emite la cuenta de cobro.

| Campo | Tipo | Restricciones |
|-------|------|---------------|
| `id` | `String` | UUID v4, generado automáticamente al crear |
| `fullName` | `String` | Requerido, no vacío |
| `documentId` | `String` | Requerido, **único en el sistema** (NIT o cédula) |
| `email` | `String` | Requerido, formato email válido |
| `phone` | `String` | Requerido, texto libre (A-007) |

**Reglas de negocio**:
- No puede existir dos `Client` con el mismo `documentId` (FR-002).
- El `email` debe coincidir con el patrón `user@domain.tld` (FR-003).

```dart
class Client {
  final String id;
  final String fullName;
  final String documentId; // NIT o número de documento (único)
  final String email;
  final String phone;

  const Client({
    required this.id,
    required this.fullName,
    required this.documentId,
    required this.email,
    required this.phone,
  });

  Client copyWith({ ... });
}
```

---

### 2. `CatalogItem` — Ítem del catálogo (producto o servicio)

**Capa**: `lib/domain/models/catalog_item/catalog_item.dart`  
**Descripción**: Ítem facturable disponible para añadir a una cuenta de cobro.

| Campo | Tipo | Restricciones |
|-------|------|---------------|
| `id` | `String` | UUID v4 |
| `name` | `String` | Requerido, no vacío |
| `description` | `String` | Opcional, puede ser vacío |
| `unitPrice` | `double` | Requerido, ≥ 0 (precio 0 permitido, edge case spec) |

**Reglas de negocio**:
- `unitPrice` ≥ 0 (FR-005; servicios gratuitos son válidos).
- El precio registrado en una cuenta de cobro es un snapshot del momento de creación; cambios futuros no afectan cuentas ya creadas (FR-012).

```dart
class CatalogItem {
  final String id;
  final String name;
  final String description;
  final double unitPrice;

  const CatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.unitPrice,
  });

  CatalogItem copyWith({ ... });
}
```

---

### 3. `IssuerConfig` — Configuración del Emisor

**Capa**: `lib/domain/models/issuer_config/issuer_config.dart`  
**Descripción**: Datos del prestador de servicios que emite las cuentas de cobro. Se configura una sola vez y persiste en Hive con una clave fija.

| Campo | Tipo | Restricciones |
|-------|------|---------------|
| `businessName` | `String` | Requerido, no vacío (nombre o razón social) |
| `nit` | `String` | Requerido, no vacío |
| `address` | `String` | Requerido, no vacío |
| `invoicePrefix` | `String` | Requerido, no vacío (default: `"CC"`) |
| `nextConsecutive` | `int` | ≥ 1; se incrementa en cada nueva cuenta (nunca se reutiliza) |

**Reglas de negocio**:
- `nextConsecutive` sólo puede incrementar; no se puede decrementar ni reusar (FR-015).
- Los datos del emisor al momento de crear una cuenta se copian como `IssuerSnapshot`; cambios futuros no afectan cuentas ya creadas (FR-014).

```dart
class IssuerConfig {
  final String businessName;
  final String nit;
  final String address;
  final String invoicePrefix;
  final int nextConsecutive; // contador autoincremental

  const IssuerConfig({
    required this.businessName,
    required this.nit,
    required this.address,
    required this.invoicePrefix,
    required this.nextConsecutive,
  });

  IssuerConfig copyWith({ ... });

  // Genera el número de cuenta formateado: "CC-0001"
  String get formattedNextNumber =>
      '$invoicePrefix-${nextConsecutive.toString().padLeft(4, '0')}';
}
```

---

### 4. `IssuerSnapshot` — Snapshot del Emisor (Value Object)

**Capa**: `lib/domain/models/invoice/issuer_snapshot.dart`  
**Descripción**: Copia inmutable de los datos del emisor al momento de creación de la cuenta de cobro. Embebido dentro de `Invoice`.

| Campo | Tipo |
|-------|------|
| `businessName` | `String` |
| `nit` | `String` |
| `address` | `String` |
| `invoicePrefix` | `String` |

---

### 5. `ClientSnapshot` — Snapshot del Cliente (Value Object)

**Capa**: `lib/domain/models/invoice/client_snapshot.dart`  
**Descripción**: Copia inmutable de los datos del cliente al momento de creación de la cuenta de cobro. Embebido dentro de `Invoice`.

| Campo | Tipo |
|-------|------|
| `clientId` | `String` |
| `fullName` | `String` |
| `documentId` | `String` |
| `email` | `String` |
| `phone` | `String` |

---

### 6. `InvoiceLine` — Línea de Cuenta de Cobro (Value Object)

**Capa**: `lib/domain/models/invoice/invoice_line.dart`  
**Descripción**: Ítem individual dentro de una cuenta de cobro. Los precios y nombres son snapshots.

| Campo | Tipo | Restricciones |
|-------|------|---------------|
| `catalogItemId` | `String` | Referencia al `CatalogItem` original |
| `itemName` | `String` | Snapshot del nombre al momento de creación |
| `unitPrice` | `double` | Snapshot del precio al momento de creación (≥ 0) |
| `quantity` | `int` | > 0 (edge case: cantidad 0 o negativa es inválida) |
| `subtotal` | `double` | Calculado: `unitPrice × quantity` (pure getter) |

**Reglas de negocio**:
- `quantity` > 0 obligatorio (edge case spec).
- `unitPrice` ≥ 0 permitido.
- `subtotal` es un getter puro, no se persiste directamente (se recalcula al deserializar o se guarda para eficiencia de lectura — decisión: guardarlo como double para consistencia con la snapshot).

```dart
class InvoiceLine {
  final String catalogItemId;
  final String itemName;
  final double unitPrice;
  final int quantity;

  const InvoiceLine({
    required this.catalogItemId,
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;
}
```

---

### 7. `Invoice` — Cuenta de Cobro

**Capa**: `lib/domain/models/invoice/invoice.dart`  
**Descripción**: Documento que registra los ítems cobrados a un cliente. Inmutable una vez creado (A-006).

| Campo | Tipo | Restricciones |
|-------|------|---------------|
| `id` | `String` | UUID v4 |
| `invoiceNumber` | `String` | Generado automáticamente (ej. `CC-0001`), único, nunca reutilizado |
| `issuerSnapshot` | `IssuerSnapshot` | Snapshot del emisor al momento de creación |
| `clientSnapshot` | `ClientSnapshot` | Snapshot del cliente al momento de creación |
| `createdAt` | `DateTime` | Fecha de creación |
| `lines` | `List<InvoiceLine>` | Al menos 1 línea requerida |
| `total` | `double` | Getter puro: suma de subtotales de todas las líneas |

**Reglas de negocio**:
- `lines` no puede estar vacía (FR-009).
- `total` es siempre la suma de `line.subtotal` para cada línea (FR-008).
- La `Invoice` es inmutable post-creación (A-006): no se ofrecen métodos de edición.

```dart
class Invoice {
  final String id;
  final String invoiceNumber;
  final IssuerSnapshot issuerSnapshot;
  final ClientSnapshot clientSnapshot;
  final DateTime createdAt;
  final List<InvoiceLine> lines;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.issuerSnapshot,
    required this.clientSnapshot,
    required this.createdAt,
    required this.lines,
  });

  double get total => lines.fold(0.0, (sum, l) => sum + l.subtotal);
}
```

---

## Relaciones entre Entidades

```
IssuerConfig ──(snapshot al crear)──► IssuerSnapshot ─┐
                                                        ├──► Invoice ◄── InvoiceLine ──(snapshot al crear)── CatalogItem
Client ──────(snapshot al crear)──► ClientSnapshot ───┘

Invoice ──[lista de]──► InvoiceLine
```

**Notas clave**:
- `Invoice` no mantiene referencia directa a `Client` ni a `IssuerConfig`; sólo a sus snapshots.
- `InvoiceLine` mantiene el `catalogItemId` como referencia histórica (no necesaria para renderizado, pero útil para auditoría).
- `IssuerConfig` no es una entidad identificada por UUID; existe como singleton en Hive con clave fija `issuer_config`.

---

## Excepciones de Dominio

| Clase | Ubicación | Casos de uso |
|-------|-----------|--------------|
| `ClientException` | `lib/domain/models/client/client_exception.dart` | NIT duplicado, email inválido |
| `CatalogItemException` | `lib/domain/models/catalog_item/catalog_item_exception.dart` | Precio inválido |
| `InvoiceException` | `lib/domain/models/invoice/invoice_exception.dart` | Sin cliente, sin líneas, cantidad inválida |

---

## Estado de los Providers (Riverpod)

Cada provider sigue el patrón `State + copyWith` establecido en el proyecto:

```dart
// Ejemplo: ClientState
class ClientState {
  final List<Client> clients;
  final bool isLoading;
  final String? error;
  // ...copyWith
}

// Ejemplo: InvoiceState (añade formulario en construcción)
class InvoiceState {
  final List<Invoice> invoices;
  final bool isLoading;
  final String? error;
  // Lista temporal de líneas durante construcción de una nueva cuenta
  final List<InvoiceLine> draftLines;
  final String? selectedClientId;
  // ...copyWith
}
```

---

## Transiciones de Estado — Creación de una Cuenta de Cobro

```
[InvoiceFormPage]
  1. Usuario selecciona cliente → invoiceProvider.selectClient(clientId)
  2. Usuario añade ítem + cantidad → invoiceProvider.addDraftLine(catalogItemId, quantity)
  3. Sistema calcula subtotal del draft en tiempo real (getter puro, sin async)
  4. Usuario confirma → invoiceProvider.createInvoice()
     └─► CreateInvoiceUseCase.execute(draftLines, clientId)
           ├─► issuerConfigGateway.get() → IssuerConfig
           ├─► clientGateway.getById(clientId) → Client
           ├─► Valida: lines.isNotEmpty, client != null
           ├─► Genera invoiceNumber = config.formattedNextNumber
           ├─► Construye Invoice con snapshots
           ├─► invoiceGateway.save(invoice)
           └─► issuerConfigGateway.save(config con nextConsecutive + 1)
  5. Provider actualiza estado → UI navega al InvoiceDetailPage
```
