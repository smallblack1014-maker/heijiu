class WeightConfig {
  final int? id;
  final double aromaWeight;
  final double palateWeight;
  final double overallWeight;
  final DateTime? updatedAt;

  WeightConfig({
    this.id = 1,
    this.aromaWeight = 0.3,
    this.palateWeight = 0.4,
    this.overallWeight = 0.3,
    this.updatedAt,
  });

  bool validate() {
    double sum = aromaWeight + palateWeight + overallWeight;
    return (sum - 1.0).abs() < 0.001;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? 1,
      'aromaWeight': aromaWeight,
      'palateWeight': palateWeight,
      'overallWeight': overallWeight,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory WeightConfig.fromMap(Map<String, dynamic> map) {
    return WeightConfig(
      id: map['id'] as int? ?? 1,
      aromaWeight: (map['aromaWeight'] as num?)?.toDouble() ?? 0.3,
      palateWeight: (map['palateWeight'] as num?)?.toDouble() ?? 0.4,
      overallWeight: (map['overallWeight'] as num?)?.toDouble() ?? 0.3,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
    );
  }

  WeightConfig copyWith({
    int? id,
    double? aromaWeight,
    double? palateWeight,
    double? overallWeight,
    DateTime? updatedAt,
  }) {
    return WeightConfig(
      id: id ?? this.id,
      aromaWeight: aromaWeight ?? this.aromaWeight,
      palateWeight: palateWeight ?? this.palateWeight,
      overallWeight: overallWeight ?? this.overallWeight,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
