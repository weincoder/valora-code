import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/config/providers/backup_provider.dart';
import 'package:valora_code/domain/models/backup/gateway/backup_gateway.dart';
import 'package:valora_code/domain/usecase/backup/backup_use_case.dart';
import 'package:valora_code/ui/pages/backup/backup_page.dart';

class _MockBackupGateway extends Mock implements BackupGateway {}

Widget _buildApp() {
  final mockGateway = _MockBackupGateway();
  when(() => mockGateway.exportToJson()).thenAnswer((_) async => '{}');
  when(() => mockGateway.importFromJson(any())).thenAnswer((_) async {});

  return ProviderScope(
    overrides: [
      backupProvider.overrideWith(
        (ref) => BackupNotifier(
          useCase: BackupUseCase(gateway: mockGateway),
          ref: ref,
        ),
      ),
    ],
    child: const MaterialApp(home: BackupPage()),
  );
}

void main() {
  group('Find the page widgets', () {
    testWidgets('should find AppBar with Backup title', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.text('Backup'), findsOneWidget);
    });

    testWidgets('should find export button', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('export-backup-button')), findsOneWidget);
    });

    testWidgets('should find import button', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('import-backup-button')), findsOneWidget);
    });

    testWidgets('should find section headers', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.text('Exportar respaldo'), findsOneWidget);
      expect(find.text('Importar respaldo'), findsOneWidget);
    });
  });

  group('Interaction with page widgets', () {
    testWidgets('should show confirmation dialog on import tap', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act
      await tester.tap(find.byKey(const Key('import-backup-button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Restaurar backup'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('should dismiss dialog on cancel', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      await tester.tap(find.byKey(const Key('import-backup-button')));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Restaurar backup'), findsNothing);
    });
  });

  group('Test Page Experience', () {
    testWidgets('should not show last backup date initially', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('last-backup-date')), findsNothing);
    });

    testWidgets('should not show loading indicator initially', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());

      // Act & Assert
      expect(find.byKey(const Key('backup-loading-indicator')), findsNothing);
    });
  });
}
