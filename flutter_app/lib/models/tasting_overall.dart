class TastingOverall {
  final int? id;
  final int tastingId;
  final int typicality; // 0-10
  final int enjoyment; // 0-10
  final int value; // 0-10
  final int agingPotential; // 0-10
  final String? agingAdvice;
  final int repurchase; // 0-10

  TastingOverall({
    this.id,
    required this.tastingId,
    this.typicality = 0,
    this.enjoyment = 0,
    this.value = 0,
    this.agingPotential = 0,
    this.agingAdvice,
    this.repurchase = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tastingId': tastingId,
      'typicality': typicality,
      'enjoyment': enjoyment,
      'value': value,
      'agingPotential': agingPotential,
      'agingAdvice': agingAdvice,
      'repurchase': repurchase,
    };
  }

  factory TastingOverall.fromMap(Map<String, dynamic> map) {
    return TastingOverall(
      id: map['id'] as int?,
      tastingId: map['tastingId'] as int,
      typicality: map['typicality'] as int? ?? 0,
      enjoyment: map['enjoyment'] as int? ?? 0,
      value: map['value'] as int? ?? 0,
      agingPotential: map['agingPotential'] as int? ?? 0,
      agingAdvice: map['agingAdvice'] as String?,
      repurchase: map['repurchase'] as int? ?? 0,
    );
  }

  TastingOverall copyWith({
    int? id,
    int? tastingId,
    int? typicality,
    int? enjoyment,
    int? value,
    int? agingPotential,
    String? agingAdvice,
    int? repurchase,
  }) {
    return TastingOverall(
      id: id ?? this.id,
      tastingId: tastingId ?? this.tastingId,
      typicality: typicality ?? this.typicality,
      enjoyment: enjoyment ?? this.enjoyment,
      value: value ?? this.value,
      agingPotential: agingPotential ?? this.agingPotential,
      agingAdvice: agingAdvice ?? this.agingAdvice,
      repurchase: repurchase ?? this.repurchase,
    );
  }
}
