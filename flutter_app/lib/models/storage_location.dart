class StorageLocation {
  final int? id;
  final String name;
  final int sortOrder;
  final DateTime? createdAt;

  StorageLocation({
    this.id,
    required this.name,
    this.sortOrder = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sortOrder': sortOrder,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory StorageLocation.fromMap(Map<String, dynamic> map) {
    return StorageLocation(
      id: map['id'] as int?,
      name: map['name'] as String,
      sortOrder: map['sortOrder'] as int? ?? 0,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
    );
  }
}
