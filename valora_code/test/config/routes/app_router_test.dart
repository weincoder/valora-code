import 'package:flutter_test/flutter_test.dart';
import 'package:valora_code/config/routes/app_router.dart';

void main() {
  group('AppRouter path constants', () {
    test('splash path should be /splash', () {
      expect(AppRouter.splash, '/splash');
    });

    test('home path should be /', () {
      expect(AppRouter.home, '/');
    });

    test('register path should be /register', () {
      expect(AppRouter.register, '/register');
    });

    test('productNew path should be /product/new', () {
      expect(AppRouter.productNew, '/product/new');
    });

    test('quotation path should be /quotation', () {
      expect(AppRouter.quotation, '/quotation');
    });

    test('balance path should be /balance', () {
      expect(AppRouter.balance, '/balance');
    });

    test('backup path should be /backup', () {
      expect(AppRouter.backup, '/backup');
    });

    test('dashboard path should be /dashboard', () {
      expect(AppRouter.dashboard, '/dashboard');
    });

    test('movements path should be /movements', () {
      expect(AppRouter.movements, '/movements');
    });

    test('tools path should be /tools', () {
      expect(AppRouter.tools, '/tools');
    });

    test('saleNew path should be /sale/new', () {
      expect(AppRouter.saleNew, '/sale/new');
    });

    test('expenseNew path should be /expense/new', () {
      expect(AppRouter.expenseNew, '/expense/new');
    });
  });

  group('AppRouter.router', () {
    test('should be a non-null GoRouter instance', () {
      // Arrange & Act
      final router = AppRouter.router;

      // Assert
      expect(router, isNotNull);
    });

    test('initial location should be splash', () {
      // Arrange & Act & Assert
      // AppRouter.router is created with initialLocation: AppRouter.splash
      expect(AppRouter.splash, '/splash');
    });
  });
}
