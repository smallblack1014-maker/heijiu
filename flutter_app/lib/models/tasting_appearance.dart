class TastingAppearance {
  final int? id;
  final int tastingId;
  final String? color;
  final String? clarity;
  final String? intensity;
  final String? condition;
  final String? tears;
  final String? bubbleFineness;
  final String? bubblePersistence;

  TastingAppearance({
    this.id,
    required this.tastingId,
    this.color,
    this.clarity,
    this.intensity,
    this.condition,
    this.tears,
    this.bubbleFineness,
    this.bubblePersistence,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tastingId': tastingId,
      'color': color,
      'clarity': clarity,
      'intensity': intensity,
      'condition': condition,
      'tears': tears,
      'bubbleFineness': bubbleFineness,
      'bubblePersistence': bubblePersistence,
    };
  }

  factory TastingAppearance.fromMap(Map<String, dynamic> map) {
    return TastingAppearance(
      id: map['id'] as int?,
      tastingId: map['tastingId'] as int,
      color: map['color'] as String?,
      clarity: map['clarity'] as String?,
      intensity: map['intensity'] as String?,
      condition: map['condition'] as String?,
      tears: map['tears'] as String?,
      bubbleFineness: map['bubbleFineness'] as String?,
      bubblePersistence: map['bubblePersistence'] as String?,
    );
  }

  TastingAppearance copyWith({
    int? id,
    int? tastingId,
    String? color,
    String? clarity,
    String? intensity,
    String? condition,
    String? tears,
    String? bubbleFineness,
    String? bubblePersistence,
  }) {
    return TastingAppearance(
      id: id ?? this.id,
      tastingId: tastingId ?? this.tastingId,
      color: color ?? this.color,
      clarity: clarity ?? this.clarity,
      intensity: intensity ?? this.intensity,
      condition: condition ?? this.condition,
      tears: tears ?? this.tears,
      bubbleFineness: bubbleFineness ?? this.bubbleFineness,
      bubblePersistence: bubblePersistence ?? this.bubblePersistence,
    );
  }
}
