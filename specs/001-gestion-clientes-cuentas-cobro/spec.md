# Feature Specification: Gestión de Clientes y Cuentas de Cobro

**Feature Branch**: `001-gestion-clientes-cuentas-cobro`  
**Created**: 2026-05-07  
**Status**: Draft  
**Input**: User description: "Crea el módulo de Gestión de Clientes y Cuentas de Cobro para la aplicación."

---

## Clarifications

### Session 2026-05-07

- Q: ¿La Cuenta de Cobro debe incluir datos del emisor (quien factura), o se asume que esos datos son fijos de la aplicación y no forman parte del documento? → A: Los datos del emisor (nombre, NIT, dirección) se configuran una vez en la app y se copian en cada Cuenta de Cobro al crearla.
- Q: ¿Las cuentas de cobro deben tener un número de referencia único (consecutivo)? → A: La app genera un número consecutivo automático al crear cada cuenta (ej. CC-0001, CC-0002…); el prefijo es configurable junto con los datos del emisor.
- Q: ¿Los datos deben persistir de forma permanente en el dispositivo (almacenamiento local)? → A: Todos los datos (clientes, catálogo, cuentas de cobro) se almacenan de forma permanente en el dispositivo y sobreviven al cierre y reinicio de la aplicación.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Registrar y consultar clientes (Priority: P1)

El administrador de la aplicación necesita mantener un directorio de clientes. Puede registrar un nuevo cliente ingresando su nombre completo, NIT o número de documento, correo electrónico y teléfono. Puede también consultar la lista de clientes registrados y ver el detalle de cada uno.

**Por qué esta prioridad**: Sin clientes registrados no es posible emitir ninguna cuenta de cobro. Es el bloque fundamental de todo el módulo.

**Independent Test**: Se puede probar de forma aislada registrando un cliente y verificando que aparece en la lista con todos sus datos correctamente almacenados. Entrega valor inmediato como directorio de clientes.

**Acceptance Scenarios**:

1. **Dado** que no existe ningún cliente registrado, **cuando** el administrador ingresa nombre, NIT/documento, email y teléfono válidos y confirma, **entonces** el cliente queda almacenado y aparece en la lista de clientes.
2. **Dado** que ya existe un cliente con el mismo NIT/documento, **cuando** el administrador intenta registrar otro cliente con ese mismo NIT/documento, **entonces** el sistema muestra un mensaje de error indicando que el identificador ya está en uso y no crea el registro.
3. **Dado** que existen clientes registrados, **cuando** el administrador abre la lista de clientes, **entonces** ve todos los clientes con nombre y NIT/documento visibles.
4. **Dado** que el administrador ingresa un email con formato inválido, **cuando** intenta guardar el cliente, **entonces** el sistema indica que el formato del email no es correcto sin guardar el registro.

---

### User Story 2 - Crear cuenta de cobro (Priority: P2)

El administrador puede crear una nueva cuenta de cobro seleccionando un cliente existente y añadiendo una lista de productos o servicios con sus cantidades. Al añadir ítems, el sistema calcula automáticamente el subtotal por línea y el total de la cuenta.

**Por qué esta prioridad**: Es el flujo central del módulo y el motivo principal de la funcionalidad. Depende de que existan clientes registrados (US1).

**Independent Test**: Con al menos un cliente y un producto/servicio registrado, se puede crear una cuenta de cobro completa y verificar que los cálculos son correctos. Entrega el valor central del módulo.

**Acceptance Scenarios**:

1. **Dado** que hay clientes y productos/servicios registrados, **cuando** el administrador selecciona un cliente, añade dos ítems con sus cantidades y confirma, **entonces** la cuenta de cobro queda almacenada con subtotales por línea y total calculados correctamente.
2. **Dado** que el administrador intenta crear una cuenta de cobro sin seleccionar ningún cliente, **cuando** intenta confirmar, **entonces** el sistema muestra un mensaje de error y no guarda la cuenta.
3. **Dado** que el administrador intenta crear una cuenta de cobro sin ningún ítem, **cuando** intenta confirmar, **entonces** el sistema muestra un mensaje de error indicando que debe añadir al menos un producto o servicio.
4. **Dado** que el administrador añade un ítem a la cuenta, **cuando** modifica la cantidad, **entonces** el subtotal de esa línea y el total de la cuenta se actualizan inmediatamente en pantalla.
5. **Dado** una cuenta de cobro con varios ítems, **cuando** el administrador elimina uno de ellos, **entonces** el total se recalcula automáticamente.

---

### User Story 3 - Visualizar cuenta de cobro (Priority: P3)

El administrador puede abrir una cuenta de cobro guardada y verla en una vista de presentación limpia que muestre los datos del cliente, el detalle de los ítems facturados, los subtotales y el total. Esta vista está diseñada para servir de base en la futura exportación a PDF.

**Por qué esta prioridad**: Complementa el flujo de creación y es requisito previo para la exportación a PDF (fuera de alcance en esta versión). Depende de US2.

**Independent Test**: Con una cuenta de cobro creada, se puede abrir la vista de presentación y verificar que todos los datos aparecen completos y correctamente formateados.

**Acceptance Scenarios**:

1. **Dado** que existe una cuenta de cobro guardada, **cuando** el administrador la abre en modo de presentación, **entonces** ve los datos completos del cliente, la lista de ítems con nombre, cantidad, precio unitario y subtotal, y el total al final.
2. **Dado** la vista de presentación, **cuando** el administrador la revisa, **entonces** no hay campos vacíos ni valores calculados incorrectamente.
- **Dado** que hay múltiples cuentas de cobro, **cuando** el administrador accede a la lista de cuentas, **entonces** puede identificar cada una por número de cuenta, cliente y fecha de creación.

---

### Edge Cases

- ¿Qué sucede cuando se intenta crear una cuenta de cobro y no hay ningún cliente registrado? → El sistema debe indicar que primero se debe registrar un cliente.
- ¿Qué sucede si se intenta añadir una cantidad de cero o negativa a un ítem? → El sistema rechaza el valor y solicita una cantidad mayor a cero.
- ¿Qué sucede si el precio unitario de un ítem es cero? → El sistema debe permitirlo (servicios gratuitos en la factura) pero mostrarlo explícitamente.
- ¿Qué sucede si se navega fuera de la cuenta de cobro sin guardar? → El sistema advierte al usuario sobre la pérdida de datos no guardados.
- ¿Qué sucede cuando el total de la cuenta supera valores muy grandes (ej. millones de pesos)? → El sistema formatea los valores numéricos correctamente sin truncar dígitos.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE permitir registrar un cliente con los siguientes datos obligatorios: nombre completo, NIT o número de documento, correo electrónico y teléfono.
- **FR-002**: El sistema DEBE validar que el NIT/documento de cada cliente sea único; no puede existir dos clientes con el mismo identificador.
- **FR-003**: El sistema DEBE validar que el correo electrónico del cliente tenga formato válido.
- **FR-004**: El sistema DEBE mostrar la lista completa de clientes registrados.
- **FR-005**: El sistema DEBE permitir registrar productos o servicios facturables con nombre, descripción breve y precio unitario.
- **FR-006**: El sistema DEBE permitir crear una cuenta de cobro asociando exactamente un cliente registrado con una o más líneas de productos/servicios.
- **FR-007**: Cada línea de la cuenta de cobro DEBE incluir el producto/servicio seleccionado, la cantidad y el precio unitario vigente al momento de creación.
- **FR-008**: El sistema DEBE calcular automáticamente el subtotal de cada línea (cantidad × precio unitario) y el total de la cuenta de cobro (suma de subtotales).
- **FR-009**: El sistema DEBE impedir guardar una cuenta de cobro que no tenga cliente asociado o que no tenga al menos una línea de ítem.
- **FR-010**: El sistema DEBE mostrar la cuenta de cobro en una vista de presentación con: datos del cliente, fecha de creación, listado de ítems (nombre, cantidad, precio unitario, subtotal), y total.
- **FR-011**: El sistema DEBE mostrar la lista de cuentas de cobro existentes identificadas por cliente y fecha.
- **FR-012**: Los precios de los productos/servicios registrados en una cuenta de cobro DEBEN mantenerse fijos en la cuenta; cambios futuros en el catálogo no deben afectar cuentas ya creadas.
- **FR-013**: El sistema DEBE permitir configurar los datos del emisor (nombre o razón social, NIT, dirección, prefijo de numeración) desde un apartado de configuración de la aplicación.
- **FR-014**: Al crear una cuenta de cobro, el sistema DEBE copiar y persistir los datos del emisor vigentes en ese momento dentro del documento; cambios futuros en la configuración del emisor no deben afectar cuentas ya creadas.
- **FR-015**: El sistema DEBE generar automáticamente un número consecutivo único para cada cuenta de cobro usando el formato `<prefijo>-<número de 4 dígitos>` (ej. CC-0001). El contador se incrementa con cada cuenta creada y nunca se reutiliza.
- **FR-016**: Todos los datos del módulo (configuración del emisor, clientes, catálogo de productos/servicios y cuentas de cobro) DEBEN persistir de forma permanente en el dispositivo. Los datos deben estar disponibles tras cerrar y reiniciar la aplicación.

### Key Entities

- **Configuración del Emisor**: Datos del prestador de servicios que emite las cuentas de cobro. Atributos: nombre o razón social, NIT, dirección, prefijo de numeración (ej. "CC"). Se configura una vez en la aplicación.
- **Cliente**: Persona natural o empresa a quien se emite la cuenta de cobro. Atributos: nombre completo, NIT/documento (único), correo electrónico, teléfono.
- **Producto/Servicio**: Ítem facturable disponible en el catálogo. Atributos: nombre, descripción breve, precio unitario.
- **Cuenta de Cobro**: Documento que agrega los ítems cobrados a un cliente en un momento dado. Atributos: número consecutivo único (generado automáticamente con prefijo configurable, ej. CC-0001), datos del emisor (copiados al momento de creación), cliente asociado, fecha de creación, lista de líneas, total calculado.
- **Línea de Cuenta de Cobro**: Ítem dentro de una cuenta de cobro. Atributos: referencia al producto/servicio, nombre del ítem (copiado al momento de creación), precio unitario (fijo), cantidad, subtotal calculado.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El administrador puede registrar un nuevo cliente en menos de 2 minutos desde la pantalla de registro.
- **SC-002**: El sistema calcula el subtotal y el total de cualquier cuenta de cobro de forma instantánea (sin demora perceptible) al añadir o modificar un ítem.
- **SC-003**: El 100% de las cuentas de cobro guardadas tienen un cliente asociado y al menos un ítem; no existe ninguna cuenta de cobro incompleta almacenada.
- **SC-004**: La vista de presentación de la cuenta de cobro contiene todos los datos necesarios (cliente, ítems, subtotales, total) para su futura exportación a PDF sin requerir ninguna intervención adicional del usuario.
- **SC-005**: El administrador puede crear una cuenta de cobro completa (cliente + ítems + visualización) en menos de 5 minutos.
- **SC-006**: Los datos registrados (clientes, catálogo y cuentas de cobro) están disponibles de inmediato tras reiniciar la aplicación, sin necesidad de re-ingresarlos.

---

## Assumptions

- **A-001**: La aplicación es de uso interno por un único administrador; no se contempla gestión de múltiples usuarios con roles distintos en esta versión.
- **A-008**: El almacenamiento es exclusivamente local en el dispositivo; no se contempla sincronización con servicios en la nube ni acceso multi-dispositivo en esta versión.
- **A-002**: La exportación a PDF está fuera del alcance de esta especificación; la vista de presentación es su prerequisito directo.
- **A-003**: No se aplican impuestos ni IVA sobre el total. El concepto "Cuenta de Cobro" en el contexto colombiano corresponde a un documento emitido por un prestador de servicios no responsable de IVA.
- **A-004**: Los precios se manejan en pesos colombianos (COP) sin conversión de moneda.
- **A-005**: El catálogo de productos/servicios es gestionado dentro de este mismo módulo. No existe un módulo externo previo de catálogo.
- **A-006**: No se contempla la edición ni eliminación de cuentas de cobro ya guardadas en esta versión; son documentos inmutables una vez creados.
- **A-007**: El teléfono del cliente es un campo de texto libre; no se valida formato específico de número colombiano.
