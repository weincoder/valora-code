import '../../models/issuer_config/issuer_config.dart';
import '../../models/issuer_config/gateway/issuer_config_gateway.dart';

class GetIssuerConfigUseCase {
  final IssuerConfigGateway _gateway;

  GetIssuerConfigUseCase(this._gateway);

  Future<IssuerConfig?> execute() => _gateway.get();
}
