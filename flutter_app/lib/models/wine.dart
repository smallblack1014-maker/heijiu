class Wine {
  final int? id;
  final String name;
  final String? winery;
  final String? country;
  final String? region;
  final String? variety;
  final int? vintage;
  final double? alcohol;
  final double? price;
  final String wineType; // red, white, rose, sparkling, sweet
  final String? photoPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int isDeleted; // 0 or 1

  Wine({
    this.id,
    required this.name,
    this.winery,
    this.country,
    this.region,
    this.variety,
    this.vintage,
    this.alcohol,
    this.price,
    required this.wineType,
    this.photoPath,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'winery': winery,
      'country': country,
      'region': region,
      'variety': variety,
      'vintage': vintage,
      'alcohol': alcohol,
      'price': price,
      'wineType': wineType,
      'photoPath': photoPath,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory Wine.fromMap(Map<String, dynamic> map) {
    return Wine(
      id: map['id'] as int?,
      name: map['name'] as String,
      winery: map['winery'] as String?,
      country: map['country'] as String?,
      region: map['region'] as String?,
      variety: map['variety'] as String?,
      vintage: map['vintage'] as int?,
      alcohol: (map['alcohol'] as num?)?.toDouble(),
      price: (map['price'] as num?)?.toDouble(),
      wineType: map['wineType'] as String,
      photoPath: map['photoPath'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
      isDeleted: map['isDeleted'] as int? ?? 0,
    );
  }

  Wine copyWith({
    int? id,
    String? name,
    String? winery,
    String? country,
    String? region,
    String? variety,
    int? vintage,
    double? alcohol,
    double? price,
    String? wineType,
    String? photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? isDeleted,
  }) {
    return Wine(
      id: id ?? this.id,
      name: name ?? this.name,
      winery: winery ?? this.winery,
      country: country ?? this.country,
      region: region ?? this.region,
      variety: variety ?? this.variety,
      vintage: vintage ?? this.vintage,
      alcohol: alcohol ?? this.alcohol,
      price: price ?? this.price,
      wineType: wineType ?? this.wineType,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
