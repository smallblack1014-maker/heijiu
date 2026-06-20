class TastingAroma {
  final int? id;
  final int tastingId;
  final int intensity; // 0-10
  final int complexity; // 0-10
  final int purity; // 0-10
  final int persistence; // 0-10
  final String? development; // youthful, developing, mature, tired

  TastingAroma({
    this.id,
    required this.tastingId,
    this.intensity = 0,
    this.complexity = 0,
    this.purity = 0,
    this.persistence = 0,
    this.development,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tastingId': tastingId,
      'intensity': intensity,
      'complexity': complexity,
      'purity': purity,
      'persistence': persistence,
      'development': development,
    };
  }

  factory TastingAroma.fromMap(Map<String, dynamic> map) {
    return TastingAroma(
      id: map['id'] as int?,
      tastingId: map['tastingId'] as int,
      intensity: map['intensity'] as int? ?? 0,
      complexity: map['complexity'] as int? ?? 0,
      purity: map['purity'] as int? ?? 0,
      persistence: map['persistence'] as int? ?? 0,
      development: map['development'] as String?,
    );
  }

  TastingAroma copyWith({
    int? id,
    int? tastingId,
    int? intensity,
    int? complexity,
    int? purity,
    int? persistence,
    String? development,
  }) {
    return TastingAroma(
      id: id ?? this.id,
      tastingId: tastingId ?? this.tastingId,
      intensity: intensity ?? this.intensity,
      complexity: complexity ?? this.complexity,
      purity: purity ?? this.purity,
      persistence: persistence ?? this.persistence,
      development: development ?? this.development,
    );
  }
}
