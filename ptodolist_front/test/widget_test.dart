import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptodolist/main.dart';

void main() {
  group('PtodolistApp', () {
    testWidgets('앱이 실행되고 바텀 네비게이션이 표시된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: PtodolistApp()),
      );
      await tester.pumpAndSettle();

      // 바텀 네비게이션 3개 탭이 표시된다
      expect(find.byType(NavigationDestination), findsNWidgets(3));
      expect(find.text('오늘'), findsWidgets);
      expect(find.text('통계'), findsOneWidget);
      expect(find.text('설정'), findsWidgets);
    });

    testWidgets('기본 탭은 홈(오늘) 화면이다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: PtodolistApp()),
      );
      await tester.pumpAndSettle();

      // 홈 화면의 AppBar 제목
      expect(find.text('오늘의 할 일'), findsOneWidget);
    });

    testWidgets('통계 탭을 누르면 통계 화면으로 전환된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: PtodolistApp()),
      );
      await tester.pumpAndSettle();

      // 통계 탭 탭
      await tester.tap(find.text('통계'));
      await tester.pumpAndSettle();

      expect(find.text('달성률 통계'), findsOneWidget);
    });

    testWidgets('설정 탭을 누르면 설정 화면으로 전환된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: PtodolistApp()),
      );
      await tester.pumpAndSettle();

      // 설정 탭 탭
      await tester.tap(find.text('설정').last);
      await tester.pumpAndSettle();

      // 설정 화면의 body 텍스트
      expect(find.text('설정'), findsWidgets);
    });
  });
}
