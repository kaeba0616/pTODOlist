import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/core/utils/friend_code_generator.dart';

void main() {
  group('FriendCodeGenerator', () {
    test('generate 는 기본 8자 + 가운데 하이픈', () {
      final code = FriendCodeGenerator.generate();
      expect(code.length, 9); // 4 + '-' + 4
      expect(code[4], '-');
    });

    test('생성된 코드는 isValid 검증 통과', () {
      for (var i = 0; i < 50; i++) {
        final code = FriendCodeGenerator.generate();
        expect(FriendCodeGenerator.isValid(code), isTrue,
            reason: 'invalid code: $code');
      }
    });

    test('혼동 문자(0,1,I,L,O) 는 절대 안 나옴', () {
      final forbidden = ['0', '1', 'I', 'L', 'O'];
      for (var i = 0; i < 200; i++) {
        final code = FriendCodeGenerator.normalize(FriendCodeGenerator.generate());
        for (final f in forbidden) {
          expect(code.contains(f), isFalse,
              reason: '$code contains forbidden $f');
        }
      }
    });

    test('normalize 는 하이픈/공백 제거 + 대문자', () {
      expect(FriendCodeGenerator.normalize('kx7b-29m3'), 'KX7B29M3');
      expect(FriendCodeGenerator.normalize(' KX 7B-29 M3 '), 'KX7B29M3');
    });

    test('isValid: 8자 미만/초과 → false', () {
      expect(FriendCodeGenerator.isValid('ABC'), isFalse);
      expect(FriendCodeGenerator.isValid('ABCDEFGH9'), isFalse);
    });

    test('isValid: 금지 문자 포함 → false', () {
      expect(FriendCodeGenerator.isValid('ABCDEFG0'), isFalse); // 0
      expect(FriendCodeGenerator.isValid('ABCDEFGI'), isFalse); // I
      expect(FriendCodeGenerator.isValid('ABCDEFGO'), isFalse); // O
    });

    test('isValid: 8자 영숫자 (하이픈 포함도 OK) → true', () {
      expect(FriendCodeGenerator.isValid('KX7B29M3'), isTrue);
      expect(FriendCodeGenerator.isValid('KX7B-29M3'), isTrue);
      expect(FriendCodeGenerator.isValid('kx7b-29m3'), isTrue);
    });
  });
}
