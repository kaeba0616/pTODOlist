import 'dart:math';

/// 8자 영숫자 친구 코드 생성. 0/O, 1/I/L 등 혼동되는 문자는 제외.
class FriendCodeGenerator {
  static const _chars =
      'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; // 31자 — 숫자 0,1, 알파 I,L,O 제외
  static final _random = Random.secure();

  /// 8자리 코드. 가독성을 위해 가운데에 하이픈 1개 (예: KX7B-29M3).
  static String generate({int length = 8}) {
    final buf = StringBuffer();
    for (var i = 0; i < length; i++) {
      buf.write(_chars[_random.nextInt(_chars.length)]);
      if (i == 3 && length == 8) buf.write('-');
    }
    return buf.toString();
  }

  /// 정규화 — 사용자 입력에서 하이픈/공백 제거하고 대문자로.
  static String normalize(String raw) =>
      raw.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');

  /// 유효성 — 정규화 후 8자, 허용 문자만.
  static bool isValid(String raw) {
    final n = normalize(raw);
    if (n.length != 8) return false;
    for (final c in n.split('')) {
      if (!_chars.contains(c)) return false;
    }
    return true;
  }
}
