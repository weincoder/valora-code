import '../issuer_config.dart';

abstract class IssuerConfigGateway {
  Future<IssuerConfig?> get();
  Future<void> save(IssuerConfig config);
}
