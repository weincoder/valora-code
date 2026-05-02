import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:valora_code/ui/pages/tools/tools_page.dart';

Widget _buildApp() {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const ToolsPage()),
      GoRoute(path: '/quotation', builder: (_, _) => const Scaffold()),
      GoRoute(path: '/backup', builder: (_, _) => const Scaffold()),
      GoRoute(path: '/product/new', builder: (_, _) => const Scaffold()),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

void main() {
  group('ToolsPage', () {
    testWidgets('renders AppBar with title', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Herramientas'), findsOneWidget);
    });

    testWidgets('shows tool cards', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Cotización PDF'), findsOneWidget);
      expect(find.text('Respaldo'), findsOneWidget);
      expect(find.text('Productos'), findsOneWidget);
    });

    testWidgets('shows owl mascot', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Todo bajo control 🧘'), findsOneWidget);
    });

    testWidgets('shows card descriptions', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Genera cotizaciones\npara tus clientes'),
        findsOneWidget,
      );
      expect(find.text('Exporta e importa\ntus datos'), findsOneWidget);
    });
  });
}
