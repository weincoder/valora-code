import '../../models/issuer_config/issuer_config.dart';
import '../../models/issuer_config/gateway/issuer_config_gateway.dart';

class SaveIssuerConfigUseCase {
  final IssuerConfigGateway _gateway;

  SaveIssuerConfigUseCase(this._gateway);

  Future<void> execute(IssuerConfig config) => _gateway.save(config);
}
