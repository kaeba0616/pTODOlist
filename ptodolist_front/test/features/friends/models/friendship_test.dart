import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/friends/models/friendship.dart';

void main() {
  group('Friendship.makePairId', () {
    test('두 uid 를 정렬해서 결합 (순서 무관)', () {
      expect(Friendship.makePairId('aaa', 'bbb'), 'aaa_bbb');
      expect(Friendship.makePairId('bbb', 'aaa'), 'aaa_bbb');
    });

    test('같은 uid 면 동일하게 처리', () {
      expect(Friendship.makePairId('xx', 'xx'), 'xx_xx');
    });
  });

  group('Friendship.otherMember', () {
    test('내 uid 를 빼고 상대 uid 반환', () {
      final f = Friendship(
        pairId: 'a_b',
        members: const ['a', 'b'],
        createdAt: DateTime(2026, 1, 1),
      );
      expect(f.otherMember('a'), 'b');
      expect(f.otherMember('b'), 'a');
    });

    test('내 uid 가 없는 경우 빈 문자열', () {
      final f = Friendship(
        pairId: 'a_b',
        members: const ['a', 'b'],
        createdAt: DateTime(2026, 1, 1),
      );
      expect(f.otherMember('z'), '');
    });
  });

  group('FriendRequest.fromMap/toMap', () {
    test('round trip', () {
      final r = FriendRequest(
        fromUid: 'u1',
        fromNickname: '하이디',
        fromCode: 'KX7B-29M3',
        createdAt: DateTime(2026, 5, 2, 12, 0),
      );
      final back = FriendRequest.fromMap(r.toMap());
      expect(back.fromUid, 'u1');
      expect(back.fromNickname, '하이디');
      expect(back.fromCode, 'KX7B-29M3');
      expect(back.createdAt, DateTime(2026, 5, 2, 12, 0));
    });
  });
}
