# Feature Specification: Gestión de Amigos y Especialidades

**Feature Branch**: `002-amigos-especialidades`  
**Created**: 2026-05-10  
**Status**: Draft  
**Input**: User description: "vamos agregar una experiencia donde pueda agregar amigos y sus especialidades. Puede ponerse la foto el nombre y en que tecnologías o áreas del conocimiento son buenos, también se podrá poner cuanto vale su hora de trabajo. Para este tema deberíamos tener una identidad para mapear los amigos con atributos: nombre, conocimientos, valorHora. Por otro lado debemos tener los estilos de las tarjetas de amigos que sean iguales a las que tenemos en las cuentas de cobro. El formulario de agregar amigo debe respetar los estilos establecidos. El buho la mascota de la app debe estar presente"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Registrar un amigo con especialidades (Priority: P1)

El usuario quiere guardar en la app el perfil de un colega o amigo de la industria, indicando su nombre, las tecnologías o áreas en las que es experto y cuánto cobra por hora. Esto le permite tener a mano un directorio de talento de confianza con información relevante para referir o contratar.

**Why this priority**: Sin la capacidad de agregar amigos no hay ninguna otra funcionalidad posible. Es el núcleo del módulo.

**Independent Test**: Puede probarse completamente abriendo el formulario, llenando nombre, al menos un área de conocimiento y el valor por hora, guardando y verificando que la tarjeta aparece en la lista.

**Acceptance Scenarios**:

1. **Given** el usuario está en la lista de amigos vacía, **When** presiona el botón flotante (+), **Then** se abre el formulario de nuevo amigo con el búho mascota y los campos vacíos.
2. **Given** el formulario está abierto, **When** el usuario ingresa nombre, al menos un área de conocimiento y el valor por hora, y presiona Guardar, **Then** el amigo se persiste y aparece como tarjeta en la lista.
3. **Given** el usuario intenta guardar sin nombre, **When** presiona Guardar, **Then** el sistema muestra un mensaje de validación indicando que el nombre es obligatorio.
4. **Given** el usuario intenta guardar con valor de hora negativo, **When** presiona Guardar, **Then** el sistema muestra un error de validación.

---

### User Story 2 - Ver la lista de amigos con tarjetas visuales (Priority: P2)

El usuario quiere ver todos sus amigos registrados en una lista con tarjetas visuales atractivas, coherentes con el resto de la aplicación. Cada tarjeta debe mostrar la foto (o avatar con inicial), nombre, áreas de conocimiento y valor por hora.

**Why this priority**: La vista de lista es la pantalla principal del módulo. Sin ella el usuario no puede consultar sus amigos registrados.

**Independent Test**: Puede probarse creando 2-3 amigos y verificando que cada uno se muestra en una tarjeta con el estilo correcto (borde izquierdo de acento, foto/avatar, nombre en negrita, chips de conocimiento, valor hora).

**Acceptance Scenarios**:

1. **Given** no hay amigos registrados, **When** el usuario abre la pantalla de amigos, **Then** se muestra el búho mascota con un mensaje invitando a agregar el primer amigo.
2. **Given** hay amigos registrados, **When** el usuario abre la pantalla, **Then** cada amigo aparece en una tarjeta con: foto o avatar con inicial, nombre, áreas de conocimiento (como etiquetas/chips), y valor por hora formateado en COP.
3. **Given** la lista de amigos, **When** el usuario toca una tarjeta, **Then** se abre el formulario de edición con los datos del amigo precargados.

---

### User Story 3 - Editar o eliminar un amigo (Priority: P3)

El usuario quiere poder actualizar la información de un amigo (nueva foto, agregar conocimientos, cambiar valor hora) o eliminarlo del directorio si ya no es relevante.

**Why this priority**: Es parte del ciclo de vida completo de los datos. Sin edición/eliminación el directorio se vuelve difícil de mantener.

**Independent Test**: Puede probarse abriendo un amigo existente, modificando su valor hora, guardando y verificando que la tarjeta muestra el nuevo valor. Para eliminación: abrir un amigo, eliminar y verificar que desaparece de la lista.

**Acceptance Scenarios**:

1. **Given** el formulario de edición está abierto con datos del amigo, **When** el usuario modifica cualquier campo y presiona Guardar, **Then** los datos se actualizan y la tarjeta refleja los cambios.
2. **Given** el formulario de edición está abierto, **When** el usuario presiona el botón Eliminar y confirma la acción, **Then** el amigo es removido de la lista permanentemente.
3. **Given** el usuario tiene una foto asignada, **When** selecciona limpiar la foto, **Then** el avatar vuelve a mostrar la inicial del nombre.

---

### User Story 4 - Agregar foto al perfil del amigo (Priority: P4)

El usuario quiere personalizar el perfil de cada amigo con una foto de perfil tomada desde la galería del dispositivo, de la misma forma en que puede hacerlo con clientes y productos.

**Why this priority**: Mejora significativamente la identificación visual en la lista, pero la funcionalidad core opera sin foto.

**Independent Test**: Puede probarse tocando el selector de imagen en el formulario, eligiendo una foto de galería, guardando y verificando que la tarjeta muestra la foto circular en lugar del avatar de inicial.

**Acceptance Scenarios**:

1. **Given** el formulario de amigo está abierto, **When** el usuario toca el área de foto, **Then** se abre el selector de galería del dispositivo.
2. **Given** el usuario selecciona una imagen, **When** regresa al formulario, **Then** la imagen se previsualiza en el selector con un botón para limpiarla.
3. **Given** el amigo tiene foto asignada, **When** la tarjeta se muestra en la lista, **Then** la foto aparece recortada en forma circular.

---

### Edge Cases

- ¿Qué pasa si el usuario no agrega ningún área de conocimiento? → Se guarda con lista vacía de conocimientos; no es obligatorio.
- ¿Qué pasa si el valor de hora es cero? → Se permite (puede ser un amigo que colabora sin costo).
- ¿Qué pasa si el nombre tiene solo espacios en blanco? → El sistema aplica trim y lo trata como campo vacío, mostrando error de validación.
- ¿Qué pasa si dos amigos tienen el mismo nombre? → Se permite; el sistema los identifica internamente por su `id` único. El usuario los distingue visualmente por foto o conocimientos.
- ¿Qué pasa si la imagen seleccionada es muy pesada? → Se comprime automáticamente (calidad 70%) antes de almacenarla.
- ¿Qué pasa si el usuario tiene muchos conocimientos en un amigo? → La tarjeta muestra los primeros 3 chips y un indicador "+N más" si hay más de 3.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE permitir crear un nuevo amigo con nombre (obligatorio), áreas de conocimiento (opcionales, múltiples) y valor por hora (obligatorio, ≥ 0). Las áreas de conocimiento se ingresan mediante un campo de texto con botón "Agregar" que convierte cada entrada en un chip removible; se pueden agregar múltiples sin límite definido.
- **FR-012**: El sistema DEBE permitir seleccionar la moneda del valor por hora entre COP y USD. La moneda se almacena junto al valor numérico y se muestra con el símbolo correspondiente ($ para COP, USD para dólares) en la tarjeta y el formulario.
- **FR-002**: El sistema DEBE permitir adjuntar una foto de galería al perfil del amigo, almacenada localmente en formato base64.
- **FR-003**: El sistema DEBE mostrar la lista de amigos en tarjetas visuales con el mismo estilo que las tarjetas de cuentas de cobro (borde izquierdo de acento, fondo oscuro de la app).
- **FR-004**: Cada tarjeta DEBE mostrar: foto circular (o avatar con inicial si no hay foto), nombre, áreas de conocimiento como etiquetas y valor por hora formateado en la moneda seleccionada (COP o USD).
- **FR-005**: El sistema DEBE mostrar el búho mascota animado cuando la lista de amigos está vacía.
- **FR-006**: El formulario de amigo DEBE respetar los estilos visuales establecidos (fondo RetroBackground, secciones con título, campos con íconos prefijos).
- **FR-007**: El sistema DEBE permitir editar cualquier dato de un amigo existente.
- **FR-008**: El sistema DEBE permitir eliminar un amigo con confirmación previa.
- **FR-009**: El sistema DEBE persistir los datos de amigos de forma local sin necesidad de conexión a internet.
- **FR-013**: El módulo de amigos DEBE ser accesible desde dos puntos de entrada: (1) una tarjeta en la pantalla de herramientas (Tools Page) con ícono `people_outline` y etiqueta "Amigos", y (2) un ítem en la barra de navegación inferior de la aplicación con el mismo ícono y etiqueta.
- **FR-010**: El sistema DEBE validar que el nombre no esté vacío antes de guardar.
- **FR-011**: El sistema DEBE validar que el valor por hora sea un número mayor o igual a cero.

### Key Entities

- **Friend** (Amigo): Representa un colega o contacto del directorio de talento. Atributos: `id` (identificador único), `fullName` (nombre completo, obligatorio), `knowledgeAreas` (lista de áreas de conocimiento / tecnologías, puede ser vacía), `hourlyRate` (valor numérico por hora, ≥ 0), `currency` (moneda del valor hora: `COP` o `USD`), `imageBase64` (foto de perfil opcional en base64).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El usuario puede registrar un nuevo amigo completo (nombre + 2 conocimientos + valor hora + foto) en menos de 2 minutos.
- **SC-002**: La lista de amigos se carga y muestra en menos de 300 ms al abrir la pantalla con hasta 100 amigos almacenados (medido desde que el usuario toca el tab hasta que las tarjetas son visibles).
- **SC-003**: El 100% de la información clave del amigo (nombre, primer conocimiento, valor hora) es visible en la tarjeta sin necesidad de abrir el detalle.
- **SC-004**: El directorio de amigos sigue siendo accesible y funcional sin conexión a internet.
- **SC-005**: La tarjeta de amigo reutiliza el mismo patrón visual que `_InvoiceCard`: borde izquierdo 4px `AppTheme.accentColor`, fondo oscuro de la app, tipografía de nombre en negrita y valor monetario destacado en color acento.

## Clarifications

### Session 2026-05-10

- Q: ¿Cómo ingresa el usuario las áreas de conocimiento en el formulario? → A: Campo de texto + botón "Agregar"; cada área se convierte en un chip removible debajo del campo.
- Q: ¿En qué moneda se ingresa y muestra el valor por hora? → A: El usuario elige entre COP y USD al registrar el valor; ambas monedas son soportadas.
- Q: ¿Qué ocurre si se intenta agregar un amigo con el mismo nombre que uno existente? → A: Se permite; no hay restricción de nombres únicos. El identificador interno distingue los registros.
- Q: ¿Desde dónde se accede al módulo de amigos? → A: Tarjeta en Tools Page (igual que otros módulos) y además como ítem en la barra de navegación inferior.
- Q: ¿Qué ícono y etiqueta usa el módulo de Amigos en el navbar y Tools Page? → A: Ícono `people_outline`, etiqueta "Amigos".

## Assumptions

- Los conocimientos/tecnologías son etiquetas de texto libre que el usuario escribe; no hay un catálogo predefinido de tecnologías.
- El valor por hora soporta dos monedas: COP (pesos colombianos) y USD (dólares). El usuario selecciona la moneda mediante un selector en el formulario. La moneda se persiste junto al valor numérico.
- Los nombres de amigos no son únicos; el sistema no impide registrar dos amigos con el mismo nombre.
- No existe una relación directa entre amigos y cuentas de cobro en esta fase; el módulo es independiente.
- Las fotos son opcionales; el sistema muestra un avatar con la inicial del nombre cuando no hay foto.
- Los datos se almacenan localmente usando el mismo mecanismo de persistencia del resto de la app (sin sincronización en la nube).
- La pantalla de amigos es accesible desde dos puntos: tarjeta en Tools Page y nuevo ítem en la barra de navegación inferior. La barra de navegación debe actualizarse para incluir el módulo de Amigos.
- No se requiere búsqueda ni filtrado de amigos en esta primera versión; la lista es suficiente para el volumen esperado.
