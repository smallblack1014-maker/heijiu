class Flavor {
  final int? id;
  final String name;
  final String category; // e.g. 水果, 花香, 香料, etc.
  final String? subcategory;
  final String wineType; // red, white, rose, sparkling, sweet
  final int isBuiltin; // 0 or 1
  final DateTime? createdAt;

  Flavor({
    this.id,
    required this.name,
    required this.category,
    this.subcategory,
    required this.wineType,
    this.isBuiltin = 1,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'wineType': wineType,
      'isBuiltin': isBuiltin,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Flavor.fromMap(Map<String, dynamic> map) {
    return Flavor(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      subcategory: map['subcategory'] as String?,
      wineType: map['wineType'] as String,
      isBuiltin: map['isBuiltin'] as int? ?? 1,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
    );
  }
}
