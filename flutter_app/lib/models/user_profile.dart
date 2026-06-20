class UserProfile {
  final int? id;
  final String? nickname;
  final String? avatarPath;
  final String? userId;
  final int darkMode; // 0 or 1

  UserProfile({
    this.id = 1,
    this.nickname,
    this.avatarPath,
    this.userId,
    this.darkMode = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? 1,
      'nickname': nickname,
      'avatarPath': avatarPath,
      'userId': userId,
      'darkMode': darkMode,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int? ?? 1,
      nickname: map['nickname'] as String?,
      avatarPath: map['avatarPath'] as String?,
      userId: map['userId'] as String?,
      darkMode: map['darkMode'] as int? ?? 0,
    );
  }

  UserProfile copyWith({
    int? id,
    String? nickname,
    String? avatarPath,
    String? userId,
    int? darkMode,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarPath: avatarPath ?? this.avatarPath,
      userId: userId ?? this.userId,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
