import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valora_code/domain/models/issuer_config/issuer_config.dart';
import 'package:valora_code/domain/models/issuer_config/gateway/issuer_config_gateway.dart';
import 'package:valora_code/domain/usecase/issuer_config/save_issuer_config_use_case.dart';

class _MockIssuerConfigGateway extends Mock implements IssuerConfigGateway {}

void main() {
  late _MockIssuerConfigGateway mockGateway;
  late SaveIssuerConfigUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const IssuerConfig(
        businessName: 'FB',
        nit: '0',
        address: 'FB',
        invoicePrefix: 'FB',
        nextConsecutive: 1,
      ),
    );
  });

  const config = IssuerConfig(
    businessName: 'Mi Empresa SAS',
    nit: '900123456-1',
    address: 'Calle 10 #5-20',
    invoicePrefix: 'FV',
    nextConsecutive: 1,
  );

  setUp(() {
    mockGateway = _MockIssuerConfigGateway();
    useCase = SaveIssuerConfigUseCase(mockGateway);
  });

  group('IssuerConfig.formattedNextNumber', () {
    test('should format number as prefix-XXXX with leading zeros', () {
      // Arrange
      const cfg = IssuerConfig(
        businessName: 'X',
        nit: 'Y',
        address: 'Z',
        invoicePrefix: 'FV',
        nextConsecutive: 5,
      );

      // Act
      final result = cfg.formattedNextNumber;

      // Assert
      expect(result, 'FV-0005');
    });

    test('should format number with 4 digits when consecutive >= 1000', () {
      // Arrange
      const cfg = IssuerConfig(
        businessName: 'X',
        nit: 'Y',
        address: 'Z',
        invoicePrefix: 'CC',
        nextConsecutive: 1000,
      );

      // Act
      final result = cfg.formattedNextNumber;

      // Assert
      expect(result, 'CC-1000');
    });
  });

  group('SaveIssuerConfigUseCase.execute', () {
    test('should save issuer config successfully', () async {
      // Arrange
      when(() => mockGateway.save(any())).thenAnswer((_) async {});

      // Act
      await useCase.execute(config);

      // Assert
      verify(() => mockGateway.save(config)).called(1);
    });
  });
}
