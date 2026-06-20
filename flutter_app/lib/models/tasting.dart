class Tasting {
  final int? id;
  final int wineId;
  final String scoringMode; // standard, quick, professional
  final int isBlind; // 0 or 1
  final int isRevealed; // 0 or 1
  final DateTime? drinkingDate;
  final DateTime? purchaseDate;
  final String? venue;
  final int? score100;
  final String? notes;
  final String? customNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int isDeleted; // 0 or 1

  Tasting({
    this.id,
    required this.wineId,
    this.scoringMode = 'standard',
    this.isBlind = 0,
    this.isRevealed = 0,
    this.drinkingDate,
    this.purchaseDate,
    this.venue,
    this.score100,
    this.notes,
    this.customNote,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wineId': wineId,
      'scoringMode': scoringMode,
      'isBlind': isBlind,
      'isRevealed': isRevealed,
      'drinkingDate': drinkingDate?.toIso8601String(),
      'purchaseDate': purchaseDate?.toIso8601String(),
      'venue': venue,
      'score100': score100,
      'notes': notes,
      'customNote': customNote,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory Tasting.fromMap(Map<String, dynamic> map) {
    return Tasting(
      id: map['id'] as int?,
      wineId: map['wineId'] as int,
      scoringMode: map['scoringMode'] as String? ?? 'standard',
      isBlind: map['isBlind'] as int? ?? 0,
      isRevealed: map['isRevealed'] as int? ?? 0,
      drinkingDate: map['drinkingDate'] != null ? DateTime.parse(map['drinkingDate'] as String) : null,
      purchaseDate: map['purchaseDate'] != null ? DateTime.parse(map['purchaseDate'] as String) : null,
      venue: map['venue'] as String?,
      score100: map['score100'] as int?,
      notes: map['notes'] as String?,
      customNote: map['customNote'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
      isDeleted: map['isDeleted'] as int? ?? 0,
    );
  }

  Tasting copyWith({
    int? id,
    int? wineId,
    String? scoringMode,
    int? isBlind,
    int? isRevealed,
    DateTime? drinkingDate,
    DateTime? purchaseDate,
    String? venue,
    int? score100,
    String? notes,
    String? customNote,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? isDeleted,
  }) {
    return Tasting(
      id: id ?? this.id,
      wineId: wineId ?? this.wineId,
      scoringMode: scoringMode ?? this.scoringMode,
      isBlind: isBlind ?? this.isBlind,
      isRevealed: isRevealed ?? this.isRevealed,
      drinkingDate: drinkingDate ?? this.drinkingDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      venue: venue ?? this.venue,
      score100: score100 ?? this.score100,
      notes: notes ?? this.notes,
      customNote: customNote ?? this.customNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
