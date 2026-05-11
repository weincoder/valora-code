class Friend {
  final String id;
  final String fullName;
  final List<String> knowledgeAreas;
  final double hourlyRate;
  final String currency;
  final String? imageBase64;

  const Friend({
    required this.id,
    required this.fullName,
    required this.knowledgeAreas,
    required this.hourlyRate,
    required this.currency,
    this.imageBase64,
  });

  Friend copyWith({
    String? id,
    String? fullName,
    List<String>? knowledgeAreas,
    double? hourlyRate,
    String? currency,
    String? imageBase64,
    bool clearImage = false,
  }) {
    return Friend(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      knowledgeAreas: knowledgeAreas ?? this.knowledgeAreas,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      currency: currency ?? this.currency,
      imageBase64: clearImage ? null : imageBase64 ?? this.imageBase64,
    );
  }
}
