# ValoraCode 🗿

**Gestión financiera para freelancers y pequeños negocios.**  
Calcula precios, registra ventas, controla gastos y visualiza tu balance en tiempo real — todo offline, sin cuentas, sin suscripciones.

---

## ✨ Funcionalidades

| Módulo | Descripción |
|---|---|
| 🛍️ Productos / Servicios | Crea ítems con tarifa por hora, horas estimadas, costos adicionales y margen de utilidad |
| 💸 Ventas | Registra cada venta vinculada a un producto; calcula el total automáticamente |
| 🧾 Gastos | Categoriza gastos (Software, Hardware, Marketing, Servicios, Otro) con fecha y notas |
| 📊 Balance | Reporte en tiempo real: ingresos, gastos, utilidad, margen promedio y gráficas mensuales |
| 📄 Cotizaciones | Genera cotizaciones en PDF listas para compartir |
| 💾 Backup | Exporta e importa todos tus datos en JSON para respaldo o migración entre dispositivos |

---

## 🏗️ Arquitectura

El proyecto implementa **Clean Architecture** con separación estricta en 4 capas:

```
UI  →  Config  →  Infrastructure  →  Domain
```

- **Domain**: entidades puras Dart, gateways abstractos y casos de uso. Cero dependencias externas.
- **Infrastructure**: adaptadores Hive (persistencia local), serializers y mappers.
- **Config**: providers Riverpod (`StateNotifier`), inyección de dependencias y rutas (`go_router`).
- **UI**: páginas y widgets Flutter. Todo texto en español, todo código en inglés.

### Estructura de carpetas

```
lib/
├── config/
│   ├── providers/       # StateNotifierProviders (product_item, sale_record, expense, balance, backup)
│   ├── routes/          # AppRouter con go_router
│   └── theme/           # AppTheme (primaryColor, accentColor)
├── domain/
│   ├── models/          # ProductItem, SaleRecord, Expense, BalanceReport, BackupData + gateways
│   └── usecase/         # Casos de uso por entidad
├── infrastructure/
│   ├── driven_adapters/ # Implementaciones Hive de cada gateway
│   └── helpers/         # BackupSerializer, mappers (productItem, saleRecord, expense)
└── ui/
    ├── pages/           # home, dashboard, product_form, sale_record, expense, balance, backup, quotation
    ├── painters/        # RetroGridPainter
    └── widgets/         # RetroBackground, ProductCard, CostCalculatorForm, AdditionalCostRow
```

---

## 🚀 Setup

**Requisitos:** Flutter ≥ 3.11.0 · Dart ≥ 3.11.0

```bash
# 1. Clonar el repositorio
git clone <repo-url>
cd valora_code

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en modo debug
flutter run
```

---

## 🧪 Tests

```bash
# Correr todos los tests
flutter test

# Con cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**90 tests** cubriendo: modelos del dominio, casos de uso, providers y adaptadores de infraestructura.

---

## 📦 Dependencias principales

| Paquete | Uso |
|---|---|
| `flutter_riverpod ^2.6.1` | Gestión de estado (`StateNotifier`) |
| `hive ^2.2.3` + `hive_flutter` | Persistencia local offline |
| `go_router ^14.6.2` | Navegación declarativa |
| `pdf ^3.11.1` + `printing` | Generación de cotizaciones en PDF |
| `file_picker ^8.1.6` | Importar backup desde el sistema de archivos |
| `share_plus ^10.1.4` | Compartir backup / cotizaciones |
| `uuid ^4.5.1` | Generación de IDs únicos |
| `mocktail ^1.0.4` | Mocks en tests |

---

## 🎨 Diseño

- Paleta principal: `#1A0047` (primaryColor) · `#4233CE` (accentColor)
- Estética retro-grid en todos los fondos (`RetroGridPainter`)
- Soporte para iOS, Android, macOS, Linux y Web
