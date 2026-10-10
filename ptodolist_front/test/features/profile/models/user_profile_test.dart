import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/profile/models/user_profile.dart';

void main() {
  group('UserProfile (개인 전용)', () {
    final created = DateTime(2026, 1, 1);
    final updated = DateTime(2026, 1, 2);

    test('toMap 은 uid/nickname/createdAt/updatedAt 만 담고 친구 필드는 없다', () {
      final profile = UserProfile(
        uid: 'u1',
        nickname: '하루',
        createdAt: created,
        updatedAt: updated,
      );

      final map = profile.toMap();

      expect(map, {
        'uid': 'u1',
        'nickname': '하루',
        'createdAt': created.toIso8601String(),
        'updatedAt': updated.toIso8601String(),
      });
      expect(map.containsKey('friendCode'), isFalse);
      expect(map.containsKey('publicMode'), isFalse);
    });

    test('fromMap 은 구버전 friendCode/publicMode 필드가 있어도 무시한다', () {
      final profile = UserProfile.fromMap({
        'uid': 'u1',
        'nickname': '하루',
        'friendCode': 'ABCD-EFGH',
        'publicMode': 'friends',
        'createdAt': created.toIso8601String(),
        'updatedAt': updated.toIso8601String(),
      });

      expect(profile.uid, 'u1');
      expect(profile.nickname, '하루');
      expect(profile.createdAt, created);
      expect(profile.updatedAt, updated);
    });

    test('copyWith 은 nickname 만 바꾸고 updatedAt 을 갱신한다', () {
      final profile = UserProfile(
        uid: 'u1',
        nickname: '하루',
        createdAt: created,
        updatedAt: updated,
      );

      final copy = profile.copyWith(nickname: '나무');

      expect(copy.uid, 'u1');
      expect(copy.nickname, '나무');
      expect(copy.createdAt, created);
      expect(copy.updatedAt.isAfter(updated), isTrue);
    });
  });
}
