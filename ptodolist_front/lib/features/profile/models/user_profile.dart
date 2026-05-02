enum PublicMode { friends, off }

extension PublicModeX on PublicMode {
  String get value => switch (this) {
        PublicMode.friends => 'friends',
        PublicMode.off => 'off',
      };

  String get label => switch (this) {
        PublicMode.friends => '친구에게 공개',
        PublicMode.off => '비공개',
      };

  String get description => switch (this) {
        PublicMode.friends => '친구로 등록한 사람만 내 오늘 달성률을 볼 수 있어요.',
        PublicMode.off => '아무에게도 노출되지 않아요. 친구가 봐도 텅 빈 카드만 보여요.',
      };

  /// 구버전 'always' / 'today_only' 는 모두 friends 로 마이그레이션.
  static PublicMode fromString(String? raw) => switch (raw) {
        'friends' || 'always' || 'today_only' => PublicMode.friends,
        _ => PublicMode.off,
      };
}

class UserProfile {
  final String uid;
  final String nickname;
  final String friendCode;
  final PublicMode publicMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.nickname,
    required this.friendCode,
    required this.publicMode,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'nickname': nickname,
        'friendCode': friendCode,
        'publicMode': publicMode.value,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      nickname: (map['nickname'] as String?) ?? '',
      friendCode: (map['friendCode'] as String?) ?? '',
      publicMode: PublicModeX.fromString(map['publicMode'] as String?),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? nickname,
    String? friendCode,
    PublicMode? publicMode,
  }) {
    return UserProfile(
      uid: uid,
      nickname: nickname ?? this.nickname,
      friendCode: friendCode ?? this.friendCode,
      publicMode: publicMode ?? this.publicMode,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
