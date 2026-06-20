class Cellar {
  final int? id;
  final int wineId;
  final int storageLocationId;
  final DateTime? entryDate;
  final int quantity;
  final double? purchasePrice;
  final DateTime? purchaseDate;
  final int? drinkFrom;
  final int? drinkTo;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cellar({
    this.id,
    required this.wineId,
    required this.storageLocationId,
    this.entryDate,
    this.quantity = 1,
    this.purchasePrice,
    this.purchaseDate,
    this.drinkFrom,
    this.drinkTo,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wineId': wineId,
      'storageLocationId': storageLocationId,
      'entryDate': entryDate?.toIso8601String(),
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'drinkFrom': drinkFrom,
      'drinkTo': drinkTo,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Cellar.fromMap(Map<String, dynamic> map) {
    return Cellar(
      id: map['id'] as int?,
      wineId: map['wineId'] as int,
      storageLocationId: map['storageLocationId'] as int,
      entryDate: map['entryDate'] != null ? DateTime.parse(map['entryDate'] as String) : null,
      quantity: map['quantity'] as int? ?? 1,
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble(),
      purchaseDate: map['purchaseDate'] != null ? DateTime.parse(map['purchaseDate'] as String) : null,
      drinkFrom: map['drinkFrom'] as int?,
      drinkTo: map['drinkTo'] as int?,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
    );
  }

  Cellar copyWith({
    int? id,
    int? wineId,
    int? storageLocationId,
    DateTime? entryDate,
    int? quantity,
    double? purchasePrice,
    DateTime? purchaseDate,
    int? drinkFrom,
    int? drinkTo,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cellar(
      id: id ?? this.id,
      wineId: wineId ?? this.wineId,
      storageLocationId: storageLocationId ?? this.storageLocationId,
      entryDate: entryDate ?? this.entryDate,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      drinkFrom: drinkFrom ?? this.drinkFrom,
      drinkTo: drinkTo ?? this.drinkTo,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
