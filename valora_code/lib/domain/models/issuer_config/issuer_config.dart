class IssuerConfig {
  final String businessName;
  final String nit;
  final String address;
  final String invoicePrefix;
  final int nextConsecutive;

  const IssuerConfig({
    required this.businessName,
    required this.nit,
    required this.address,
    required this.invoicePrefix,
    required this.nextConsecutive,
  });

  IssuerConfig copyWith({
    String? businessName,
    String? nit,
    String? address,
    String? invoicePrefix,
    int? nextConsecutive,
  }) {
    return IssuerConfig(
      businessName: businessName ?? this.businessName,
      nit: nit ?? this.nit,
      address: address ?? this.address,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      nextConsecutive: nextConsecutive ?? this.nextConsecutive,
    );
  }

  String get formattedNextNumber =>
      '$invoicePrefix-${nextConsecutive.toString().padLeft(4, '0')}';
}
