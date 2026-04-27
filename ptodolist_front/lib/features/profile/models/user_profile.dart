enum PublicMode { always, todayOnly, off }

extension PublicModeX on PublicMode {
  String get value => switch (this) {
        PublicMode.always => 'always',
        PublicMode.todayOnly => 'today_only',
        PublicMode.off => 'off',
      };

  String get label => switch (this) {
        PublicMode.always => '항상 공개',
        PublicMode.todayOnly => '오늘만 공개',
        PublicMode.off => '비공개',
      };

  String get description => switch (this) {
        PublicMode.always => '모든 날짜의 루틴 달성률이 피드에 노출됩니다.',
        PublicMode.todayOnly => '오늘의 달성률만 피드에 노출, 자정이 지나면 사라져요.',
        PublicMode.off => '내 정보가 피드에 일절 노출되지 않습니다.',
      };

  static PublicMode fromString(String? raw) => switch (raw) {
        'always' => PublicMode.always,
        'today_only' => PublicMode.todayOnly,
        _ => PublicMode.off,
      };
}

class UserProfile {
  final String uid;
  final String nickname;
  final PublicMode publicMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.nickname,
    required this.publicMode,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'nickname': nickname,
        'publicMode': publicMode.value,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      nickname: (map['nickname'] as String?) ?? '',
      publicMode: PublicModeX.fromString(map['publicMode'] as String?),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  UserProfile copyWith({String? nickname, PublicMode? publicMode}) {
    return UserProfile(
      uid: uid,
      nickname: nickname ?? this.nickname,
      publicMode: publicMode ?? this.publicMode,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
