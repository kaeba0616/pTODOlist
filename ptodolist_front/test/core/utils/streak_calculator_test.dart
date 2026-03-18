import 'package:flutter_test/flutter_test.dart';
import 'package:ptodolist/core/utils/streak_calculator.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';

void main() {
  group('StreakCalculator', () {
    test('기록이 없으면 streak은 0이다', () {
      final streak = StreakCalculator.currentStreak(
        routineId: 'r-1',
        records: [],
        today: '2026-03-19',
      );
      expect(streak, 0);
    });

    test('연속 3일 완료이면 streak은 3이다', () {
      final records = [
        const DailyRecord(
          date: '2026-03-17',
          routineCompletions: {'r-1': true},
        ),
        const DailyRecord(
          date: '2026-03-18',
          routineCompletions: {'r-1': true},
        ),
        const DailyRecord(
          date: '2026-03-19',
          routineCompletions: {'r-1': true},
        ),
      ];
      final streak = StreakCalculator.currentStreak(
        routineId: 'r-1',
        records: records,
        today: '2026-03-19',
      );
      expect(streak, 3);
    });

    test('어제 미완료이면 streak은 오늘만 카운트', () {
      final records = [
        const DailyRecord(
          date: '2026-03-17',
          routineCompletions: {'r-1': true},
        ),
        const DailyRecord(
          date: '2026-03-18',
          routineCompletions: {'r-1': false},
        ),
        const DailyRecord(
          date: '2026-03-19',
          routineCompletions: {'r-1': true},
        ),
      ];
      final streak = StreakCalculator.currentStreak(
        routineId: 'r-1',
        records: records,
        today: '2026-03-19',
      );
      expect(streak, 1);
    });

    test('오늘 아직 미완료이면 streak은 0이다', () {
      final records = [
        const DailyRecord(
          date: '2026-03-18',
          routineCompletions: {'r-1': true},
        ),
        const DailyRecord(
          date: '2026-03-19',
          routineCompletions: {'r-1': false},
        ),
      ];
      final streak = StreakCalculator.currentStreak(
        routineId: 'r-1',
        records: records,
        today: '2026-03-19',
      );
      expect(streak, 0);
    });

    test('기록이 없는 날은 streak을 끊는다', () {
      final records = [
        const DailyRecord(
          date: '2026-03-17',
          routineCompletions: {'r-1': true},
        ),
        // 03-18 기록 없음
        const DailyRecord(
          date: '2026-03-19',
          routineCompletions: {'r-1': true},
        ),
      ];
      final streak = StreakCalculator.currentStreak(
        routineId: 'r-1',
        records: records,
        today: '2026-03-19',
      );
      expect(streak, 1);
    });

    test('activeDays에 해당하지 않는 날은 건너뛴다', () {
      // 월수금(1,3,5)만 활성. 화목은 건너뜀
      final records = [
        const DailyRecord(
          date: '2026-03-17',
          routineCompletions: {'r-1': true},
        ), // 화 - 비활성
        const DailyRecord(
          date: '2026-03-16',
          routineCompletions: {'r-1': true},
        ), // 월 - 활성
        const DailyRecord(
          date: '2026-03-14',
          routineCompletions: {'r-1': true},
        ), // 토 - 비활성
        const DailyRecord(
          date: '2026-03-13',
          routineCompletions: {'r-1': true},
        ), // 금 - 활성
        const DailyRecord(
          date: '2026-03-19',
          routineCompletions: {'r-1': true},
        ), // 목 - 비활성 (오늘)
      ];
      // 3/19(목)은 비활성이므로 오늘 기록 무시, 마지막 활성일부터 시작
      // 실제로 오늘이 비활성이면 streak 계산 시 이전 활성일부터
      final streak = StreakCalculator.currentStreak(
        routineId: 'r-1',
        records: records,
        today: '2026-03-19',
        activeDays: [1, 3, 5],
      );
      // 3/19 목 비활성 → skip, 3/18 수 활성 but no record → break
      // Actually let me reconsider: we should check 3/19 is not active day, skip.
      // Then check 3/18 (수=3, active), no record → break. streak = 0
      expect(streak, 0);
    });

    test('routineId가 record에 없으면 미완료로 취급', () {
      final records = [
        const DailyRecord(
          date: '2026-03-19',
          routineCompletions: {'r-2': true},
        ),
      ];
      final streak = StreakCalculator.currentStreak(
        routineId: 'r-1',
        records: records,
        today: '2026-03-19',
      );
      expect(streak, 0);
    });
  });
}
