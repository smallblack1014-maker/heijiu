class TastingPalate {
  final int? id;
  final int tastingId;
  final int acidity; // 0-10
  final int tannin; // 0-10
  final String? tanninTexture;
  final int body; // 0-10
  final int balance; // 0-10
  final int complexity; // 0-10
  final int finishLength; // 0-10
  final String? finishCharacter;
  final int? alcoholPerception;

  TastingPalate({
    this.id,
    required this.tastingId,
    this.acidity = 0,
    this.tannin = 0,
    this.tanninTexture,
    this.body = 0,
    this.balance = 0,
    this.complexity = 0,
    this.finishLength = 0,
    this.finishCharacter,
    this.alcoholPerception,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tastingId': tastingId,
      'acidity': acidity,
      'tannin': tannin,
      'tanninTexture': tanninTexture,
      'body': body,
      'balance': balance,
      'complexity': complexity,
      'finishLength': finishLength,
      'finishCharacter': finishCharacter,
      'alcoholPerception': alcoholPerception,
    };
  }

  factory TastingPalate.fromMap(Map<String, dynamic> map) {
    return TastingPalate(
      id: map['id'] as int?,
      tastingId: map['tastingId'] as int,
      acidity: map['acidity'] as int? ?? 0,
      tannin: map['tannin'] as int? ?? 0,
      tanninTexture: map['tanninTexture'] as String?,
      body: map['body'] as int? ?? 0,
      balance: map['balance'] as int? ?? 0,
      complexity: map['complexity'] as int? ?? 0,
      finishLength: map['finishLength'] as int? ?? 0,
      finishCharacter: map['finishCharacter'] as String?,
      alcoholPerception: map['alcoholPerception'] as int?,
    );
  }

  TastingPalate copyWith({
    int? id,
    int? tastingId,
    int? acidity,
    int? tannin,
    String? tanninTexture,
    int? body,
    int? balance,
    int? complexity,
    int? finishLength,
    String? finishCharacter,
    int? alcoholPerception,
  }) {
    return TastingPalate(
      id: id ?? this.id,
      tastingId: tastingId ?? this.tastingId,
      acidity: acidity ?? this.acidity,
      tannin: tannin ?? this.tannin,
      tanninTexture: tanninTexture ?? this.tanninTexture,
      body: body ?? this.body,
      balance: balance ?? this.balance,
      complexity: complexity ?? this.complexity,
      finishLength: finishLength ?? this.finishLength,
      finishCharacter: finishCharacter ?? this.finishCharacter,
      alcoholPerception: alcoholPerception ?? this.alcoholPerception,
    );
  }
}
