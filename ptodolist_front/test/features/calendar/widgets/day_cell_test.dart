import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/features/calendar/widgets/day_cell.dart';

void main() {
  group('DayCell', () {
    Widget buildTestWidget({
      required int day,
      double? completionRate,
      bool isToday = false,
      bool isFuture = false,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 48,
            height: 48,
            child: DayCell(
              day: day,
              completionRate: completionRate,
              isToday: isToday,
              isFuture: isFuture,
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    testWidgets('날짜 숫자가 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget(day: 15));
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('오늘 날짜는 테두리가 표시된다', (tester) async {
      await tester.pumpWidget(buildTestWidget(day: 19, isToday: true));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('미래 날짜는 탭해도 콜백이 호출되지 않는다', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildTestWidget(
        day: 25,
        isFuture: true,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.text('25'));
      expect(tapped, isFalse);
    });

    testWidgets('과거 날짜를 탭하면 콜백이 호출된다', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildTestWidget(
        day: 10,
        completionRate: 0.5,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.text('10'));
      expect(tapped, isTrue);
    });

    testWidgets('completionColor가 달성률에 따라 다르다', (tester) async {
      const colorScheme = ColorScheme.light();
      // 0% - 빈 셀
      expect(DayCell.completionColor(0.0, colorScheme: colorScheme), isNotNull);
      // 100% - primary full
      expect(DayCell.completionColor(1.0, colorScheme: colorScheme), isNotNull);
      // 다른 달성률은 다른 색상 반환
      expect(
        DayCell.completionColor(0.0, colorScheme: colorScheme),
        isNot(equals(DayCell.completionColor(1.0, colorScheme: colorScheme))),
      );
    });
  });
}
