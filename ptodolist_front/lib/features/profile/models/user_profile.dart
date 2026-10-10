class UserProfile {
  final String uid;
  final String nickname;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.nickname,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'nickname': nickname,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// 구버전 문서에 남아있는 friendCode / publicMode 필드는 무시한다.
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      nickname: (map['nickname'] as String?) ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  UserProfile copyWith({String? nickname}) {
    return UserProfile(
      uid: uid,
      nickname: nickname ?? this.nickname,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
