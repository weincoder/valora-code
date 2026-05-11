import 'package:go_router/go_router.dart';
import '../../ui/pages/home/home_page.dart';
import '../../ui/pages/splash/splash_page.dart';
import '../../ui/pages/product_form/product_form_page.dart';
import '../../ui/pages/quotation/quotation_page.dart';
import '../../ui/pages/balance/balance_page.dart';
import '../../ui/pages/backup/backup_page.dart';
import '../../ui/pages/dashboard/dashboard_page.dart';
import '../../ui/pages/movements/movements_page.dart';
import '../../ui/pages/tools/tools_page.dart';
import '../../ui/pages/sale_record/sale_record_form_page.dart';
import '../../ui/pages/expense/expense_form_page.dart';
import '../../ui/pages/register/register_page.dart';
import '../../ui/widgets/app_shell.dart';
import '../../ui/pages/issuer_config/issuer_config_page.dart';
import '../../ui/pages/client/client_list_page.dart';
import '../../ui/pages/client/client_form_page.dart';
import '../../ui/pages/invoice/invoice_list_page.dart';
import '../../ui/pages/invoice/invoice_form_page.dart';
import '../../ui/pages/invoice/invoice_detail_page.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String home = '/';
  static const String register = '/register';
  static const String productNew = '/product/new';
  static const String productEdit = '/product/:id';
  static const String quotation = '/quotation';
  static const String balance = '/balance';
  static const String backup = '/backup';
  static const String dashboard = '/dashboard';
  static const String movements = '/movements';
  static const String tools = '/tools';
  static const String saleNew = '/sale/new';
  static const String saleEdit = '/sale/:id';
  static const String expenseNew = '/expense/new';
  static const String expenseEdit = '/expense/:id';

  // ── Módulo: Gestión de Clientes y Cuentas de Cobro ──────────────────────────
  static const String clients = '/clients';
  static const String clientNew = '/clients/new';
  static const String clientEdit = '/clients/:clientId';
  static const String issuerConfig = '/issuer-config';
  static const String invoices = '/invoices';
  static const String invoiceNew = '/invoices/new';
  static const String invoiceDetail = '/invoices/:invoiceId/detail';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (_, _) => const SplashPage()),

      // ── Rutas fuera del shell (push encima) ──────────────────────────────────
      GoRoute(path: register, builder: (_, _) => const RegisterPage()),
      GoRoute(path: backup, builder: (_, _) => const BackupPage()),
      GoRoute(path: dashboard, builder: (_, _) => const DashboardPage()),
      GoRoute(path: quotation, builder: (_, _) => const QuotationPage()),
      GoRoute(path: '/product/new', builder: (_, _) => const ProductFormPage()),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) =>
            ProductFormPage(productId: state.pathParameters['id']),
      ),
      GoRoute(path: '/sale/new', builder: (_, _) => const SaleRecordFormPage()),
      GoRoute(
        path: '/sale/:id',
        builder: (_, state) =>
            SaleRecordFormPage(saleRecordId: state.pathParameters['id']),
      ),
      GoRoute(path: '/expense/new', builder: (_, _) => const ExpenseFormPage()),
      GoRoute(
        path: '/expense/:id',
        builder: (_, state) =>
            ExpenseFormPage(expenseId: state.pathParameters['id']),
      ),
      GoRoute(path: issuerConfig, builder: (_, _) => const IssuerConfigPage()),
      GoRoute(path: clients, builder: (_, _) => const ClientListPage()),
      GoRoute(path: clientNew, builder: (_, _) => const ClientFormPage()),
      GoRoute(
        path: clientEdit,
        builder: (_, state) =>
            ClientFormPage(clientId: state.pathParameters['clientId']),
      ),
      GoRoute(path: invoices, builder: (_, _) => const InvoiceListPage()),
      GoRoute(path: invoiceNew, builder: (_, _) => const InvoiceFormPage()),
      GoRoute(
        path: invoiceDetail,
        builder: (_, state) =>
            InvoiceDetailPage(invoiceId: state.pathParameters['invoiceId']!),
      ),

      // ── Shell con bottom nav (4 tabs) ─────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: home, builder: (_, _) => const HomePage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: movements,
                builder: (_, _) => const MovementsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: balance, builder: (_, _) => const BalancePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: tools, builder: (_, _) => const ToolsPage()),
            ],
          ),
        ],
      ),
    ],
  );
}
