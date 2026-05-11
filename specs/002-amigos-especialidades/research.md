# Research: Gestión de Amigos y Especialidades

**Feature**: `002-amigos-especialidades`  
**Date**: 2026-05-10  
**Status**: Complete — sin NEEDS CLARIFICATION pendientes

---

## Decisión 1 — Formato de moneda multi-currency (COP / USD)

**Problema**: El helper actual `formatCop()` en `lib/ui/widgets/invoice/currency_format_helper.dart` está hardcodeado a COP. La entidad `Friend` requiere soporte para COP y USD.

**Decisión**: Añadir un helper paramétrico `formatCurrency(double amount, String currency)` en el mismo archivo:
- `'COP'` → `NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0)`
- `'USD'` → `NumberFormat.currency(locale: 'en_US', symbol: 'USD \$', decimalDigits: 2)`
- Default: COP si el valor de `currency` es desconocido

**Rationale**: Reutiliza la dependencia `intl` ya presente en `pubspec.yaml`. No introduce nuevos paquetes. Es una función pura y fácilmente testeable.

**Alternativas consideradas**:
- Pasar el locale completo desde la UI → rechazado (lógica de presentación en el dominio)
- Usar un enum `Currency` en el dominio → rechazado (añade complejidad innecesaria; `String` con valores canónicos `'COP'`/`'USD'` es suficiente)

---

## Decisión 2 — Tag-input de áreas de conocimiento

**Problema**: Flutter no dispone de un widget nativo de tag-input (campo de texto que genera chips removibles).

**Decisión**: Implementar `_KnowledgeTagInput` como widget privado en `friend_form_page.dart`:
1. `TextEditingController` + `TextFormField` con botón "Agregar" (IconButton `Icons.add_circle_outline`)
2. Al presionar el botón (o `onFieldSubmitted`): si el texto no está vacío → añadir a lista local → limpiar campo
3. Renderizar chips como `Wrap` de `InputChip` con `onDeleted` → eliminar del estado local
4. Límite de visualización: la tarjeta muestra solo los primeros 3 chips + badge `+N` si hay más

**Rationale**: Patrón estándar en Flutter para este tipo de input. No requiere paquetes externos. Consistent con la constitución (sin nuevas dependencias de pub.dev).

**Alternativas consideradas**:
- Paquete `flutter_chips_input` → rechazado (nueva dependencia; constitución prohíbe sin aprobación)
- Campo texto separado por comas → rechazado (UX inferior, clarificación Q1 resolvió esto)

---

## Decisión 3 — Extensión del NavBar de 4 a 5 ramas

**Problema**: El `StatefulShellRoute` actual en `app_router.dart` tiene 4 ramas. El spec requiere añadir "Amigos" como 5ª pestaña en la barra inferior.

**Decisión**: 
- Añadir 5ª `StatefulShellBranch` con ruta `/friends` en `app_router.dart`
- Actualizar `AppShell._tabs` con el nuevo `_TabItem(icon: Icons.people_outline, label: 'Amigos')`
- Ajustar `_AppBottomBar` Row: izquierda → [Inicio(0), Movimientos(1)]; derecha → [Balance(2), Más(3), Amigos(4)]
- El `goBranch(i)` ya funciona por índice; no requiere cambios en la lógica de navegación

**Rationale**: Es el patrón de extensión más natural del shell existente. El layout queda asimétrico (2 izquierda + 3 derecha), lo que es aceptable en Material Design con BottomAppBar + FAB central.

**Alternativas consideradas**:
- Poner "Amigos" como 3ª pestaña izquierda → rechazado (rompe el orden semántico actual)
- Acceso sólo desde Tools Page → rechazado (spec requiere navbar)

---

## Decisión 4 — Caja Hive para `friends`

**Problema**: Se necesita persistencia local para la entidad `Friend`.

**Decisión**: Añadir `Hive.openBox<Map>('friends')` al `Future.wait([...])` en `main.dart`. El adaptador `FriendHiveAdapter` usa `Hive.box<Map>('friends')` (lazy accessor, igual que `ClientHiveAdapter`).

**Rationale**: Mismo patrón que las cajas `clients`, `issuer_config`, `invoices`. Sin cambios estructurales. Mínimo impacto en `main.dart`.

**Alternativas consideradas**:
- SharedPreferences → rechazado (no apto para colecciones estructuradas)
- SQLite (sqflite) → rechazado (nueva dependencia; sobre-ingeniería para el volumen esperado)

---

## Decisión 5 — Manejo del `imageBase64` en tarjeta

**Problema**: La tarjeta debe mostrar foto circular o avatar con inicial. El mismo patrón ya existe en `ClientListPage._ClientCard`.

**Decisión**: Reutilizar exactamente el patrón de `_ClientCard`:
- Si `imageBase64 != null`: `ClipOval(child: Image.memory(base64Decode(...), width: 52, height: 52, fit: BoxFit.cover, errorBuilder: ...))` 
- Si null: `CircleAvatar` con inicial de `fullName[0].toUpperCase()` y color `AppTheme.accentColor.withValues(alpha: 0.2)`

**Rationale**: Consistencia visual explícita requerida por el spec. Código ya probado. Sin nuevas complejidades.

---

## Decisión 6 — Selector de moneda en formulario

**Problema**: El usuario debe elegir COP o USD al ingresar el valor por hora.

**Decisión**: `DropdownButtonFormField<String>` con `initialValue: 'COP'` y dos ítems: `'COP'` y `'USD'`. Se ubica en la misma fila que el campo `hourlyRate` usando `Row(children: [Expanded(child: hourlyRateField), SizedBox(width: 8), currencyDropdown])`.

**Rationale**: UI mínima y familiar. El `DropdownButtonFormField` ya se usa en `invoice_form_page.dart`. Sin paquetes adicionales.

---

## Resumen de decisiones

| # | Área | Decisión |
|---|---|---|
| 1 | Formato moneda | `formatCurrency(amount, currency)` paramétrico en helper existente |
| 2 | Tag-input chips | Widget privado `_KnowledgeTagInput` con Wrap + InputChip |
| 3 | NavBar 5 tabs | 5ª rama shell + 5º `_TabItem` en AppShell; layout 2 izq + 3 der |
| 4 | Hive box | `'friends'` añadida a `Future.wait` en `main.dart` |
| 5 | Avatar/foto | Reutiliza patrón `_ClientCard` con `ClipOval` / `CircleAvatar` |
| 6 | Selector moneda | `DropdownButtonFormField<String>` en fila con `hourlyRate` |
