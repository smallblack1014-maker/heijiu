class TastingFlavor {
  final int? id;
  final int tastingId;
  final int flavorId;

  TastingFlavor({
    this.id,
    required this.tastingId,
    required this.flavorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tastingId': tastingId,
      'flavorId': flavorId,
    };
  }

  factory TastingFlavor.fromMap(Map<String, dynamic> map) {
    return TastingFlavor(
      id: map['id'] as int?,
      tastingId: map['tastingId'] as int,
      flavorId: map['flavorId'] as int,
    );
  }
}
