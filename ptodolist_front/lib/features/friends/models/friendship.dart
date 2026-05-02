/// 두 사용자 사이의 친구 관계. members 배열로 양방향 표현.
/// docId = pairId = sorted(uidA, uidB).join('_')
class Friendship {
  final String pairId;
  final List<String> members; // [uidA, uidB] 정렬 보장
  final DateTime createdAt;

  const Friendship({
    required this.pairId,
    required this.members,
    required this.createdAt,
  });

  /// 두 uid 로 정규화된 pairId 생성.
  static String makePairId(String a, String b) {
    final list = [a, b]..sort();
    return '${list[0]}_${list[1]}';
  }

  String otherMember(String myUid) {
    if (!members.contains(myUid)) return '';
    return members.firstWhere((m) => m != myUid, orElse: () => '');
  }

  Map<String, dynamic> toMap() => {
        'members': members,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Friendship.fromMap(String pairId, Map<String, dynamic> map) {
    return Friendship(
      pairId: pairId,
      members: (map['members'] as List<dynamic>? ?? []).cast<String>(),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// 받은/보낸 친구 요청.
class FriendRequest {
  final String fromUid;
  final String fromNickname;
  final String fromCode;
  final DateTime createdAt;

  const FriendRequest({
    required this.fromUid,
    required this.fromNickname,
    required this.fromCode,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'fromUid': fromUid,
        'fromNickname': fromNickname,
        'fromCode': fromCode,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      fromUid: (map['fromUid'] as String?) ?? '',
      fromNickname: (map['fromNickname'] as String?) ?? '',
      fromCode: (map['fromCode'] as String?) ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
