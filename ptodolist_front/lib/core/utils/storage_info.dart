import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageInfo {
  static Future<int> getHiveBoxesSizeBytes() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      int total = 0;
      await for (final entity in dir.list()) {
        if (entity is File) {
          final p = entity.path.toLowerCase();
          if (p.endsWith('.hive') || p.endsWith('.lock')) {
            total += await entity.length();
          }
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 KB';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// 화면에 큰 숫자와 단위를 나눠 표시할 때 사용.
  /// 반환: ('12.4', 'MB') 혹은 ('254', 'KB')
  static (String, String) formatSplit(int bytes) {
    if (bytes <= 0) return ('0', 'KB');
    if (bytes < 1024) return ('$bytes', 'B');
    if (bytes < 1024 * 1024) {
      return ((bytes / 1024).toStringAsFixed(1), 'KB');
    }
    return ((bytes / (1024 * 1024)).toStringAsFixed(2), 'MB');
  }
}
