import 'package:go_router/go_router.dart';
import '../../ui/pages/home/home_page.dart';
import '../../ui/pages/product_form/product_form_page.dart';
import '../../ui/pages/quotation/quotation_page.dart';
import '../../ui/pages/balance/balance_page.dart';
import '../../ui/pages/backup/backup_page.dart';
import '../../ui/pages/dashboard/dashboard_page.dart';
import '../../ui/pages/sale_record/sale_list_page.dart';
import '../../ui/pages/sale_record/sale_record_form_page.dart';
import '../../ui/pages/expense/expense_list_page.dart';
import '../../ui/pages/expense/expense_form_page.dart';

class AppRouter {
  static const String home = '/';
  static const String productNew = '/product/new';
  static const String productEdit = '/product/:id';
  static const String quotation = '/quotation';
  static const String balance = '/balance';
  static const String backup = '/backup';
  static const String dashboard = '/dashboard';
  static const String saleList = '/sales';
  static const String saleNew = '/sale/new';
  static const String saleEdit = '/sale/:id';
  static const String expenseList = '/expenses';
  static const String expenseNew = '/expense/new';
  static const String expenseEdit = '/expense/:id';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(path: home, builder: (context, _) => const HomePage()),
      GoRoute(
        path: '/product/new',
        builder: (context, _) => const ProductFormPage(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (_, state) =>
            ProductFormPage(productId: state.pathParameters['id']),
      ),
      GoRoute(path: quotation, builder: (context, _) => const QuotationPage()),
      GoRoute(path: balance, builder: (context, _) => const BalancePage()),
      GoRoute(path: backup, builder: (context, _) => const BackupPage()),
      GoRoute(path: dashboard, builder: (context, _) => const DashboardPage()),
      GoRoute(path: saleList, builder: (context, _) => const SaleListPage()),
      GoRoute(
        path: '/sale/new',
        builder: (context, _) => const SaleRecordFormPage(),
      ),
      GoRoute(
        path: '/sale/:id',
        builder: (_, state) =>
            SaleRecordFormPage(saleRecordId: state.pathParameters['id']),
      ),
      GoRoute(
        path: expenseList,
        builder: (context, _) => const ExpenseListPage(),
      ),
      GoRoute(
        path: '/expense/new',
        builder: (context, _) => const ExpenseFormPage(),
      ),
      GoRoute(
        path: '/expense/:id',
        builder: (_, state) =>
            ExpenseFormPage(expenseId: state.pathParameters['id']),
      ),
    ],
  );
}
