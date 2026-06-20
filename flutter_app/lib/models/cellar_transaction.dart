class CellarTransaction {
  final int? id;
  final int cellarId;
  final int? tastingId;
  final String transType; // add, remove, consume
  final int quantity;
  final DateTime? transDate;
  final String? notes;
  final DateTime? createdAt;

  CellarTransaction({
    this.id,
    required this.cellarId,
    this.tastingId,
    required this.transType,
    this.quantity = 1,
    this.transDate,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cellarId': cellarId,
      'tastingId': tastingId,
      'transType': transType,
      'quantity': quantity,
      'transDate': transDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory CellarTransaction.fromMap(Map<String, dynamic> map) {
    return CellarTransaction(
      id: map['id'] as int?,
      cellarId: map['cellarId'] as int,
      tastingId: map['tastingId'] as int?,
      transType: map['transType'] as String,
      quantity: map['quantity'] as int? ?? 1,
      transDate: map['transDate'] != null ? DateTime.parse(map['transDate'] as String) : null,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
    );
  }
}
