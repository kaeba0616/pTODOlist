import 'package:flutter/foundation.dart';

/// 클라우드 동기화 (pull / wipe) 가 끝날 때마다 increment.
/// 데이터를 보여주는 모든 뷰가 listen 해서 데이터 새로고침.
final ValueNotifier<int> appSyncTick = ValueNotifier<int>(0);

/// 외부 호출자가 명시적으로 트리거.
void notifySyncCompleted() {
  appSyncTick.value++;
}
