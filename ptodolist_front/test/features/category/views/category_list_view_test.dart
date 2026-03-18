import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/category/views/category_list_view.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';

void main() {
  group('CategoryListView', () {
    late CategoryRepository mockRepo;

    setUp(() {
      mockRepo = CategoryRepository(useMock: true);
    });

    Widget buildTestWidget() {
      return MaterialApp(home: CategoryListView(repository: mockRepo));
    }

    testWidgets('기본 카테고리 5개가 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('운동'), findsOneWidget);
      expect(find.text('공부'), findsOneWidget);
      expect(find.text('업무'), findsOneWidget);
      expect(find.text('생활'), findsOneWidget);
      expect(find.text('기타'), findsOneWidget);
    });

    testWidgets('"카테고리 추가" 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('카테고리 추가'), findsOneWidget);
    });

    testWidgets('카테고리 추가 버튼을 누르면 바텀시트가 열린다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('카테고리 추가'));
      await tester.pumpAndSettle();

      expect(find.text('카테고리 추가'), findsWidgets); // 버튼 + 시트 제목
      expect(find.text('이름'), findsOneWidget);
      expect(find.text('색상'), findsOneWidget);
      expect(find.text('저장'), findsOneWidget);
    });

    testWidgets('AppBar에 "카테고리 관리" 제목이 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('카테고리 관리'), findsOneWidget);
    });
  });
}
