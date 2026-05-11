import '../../../domain/models/issuer_config/issuer_config.dart';

Map<String, dynamic> issuerConfigToJson(IssuerConfig config) => {
  'businessName': config.businessName,
  'nit': config.nit,
  'address': config.address,
  'invoicePrefix': config.invoicePrefix,
  'nextConsecutive': config.nextConsecutive,
};

IssuerConfig issuerConfigFromJson(Map<dynamic, dynamic> json) => IssuerConfig(
  businessName: json['businessName'] as String,
  nit: json['nit'] as String,
  address: json['address'] as String,
  invoicePrefix: json['invoicePrefix'] as String,
  nextConsecutive: json['nextConsecutive'] as int,
);
