# F5: 일일 기록 & 자정 리셋 - UX Flow

## 개요
사용자에게 직접 보이지 않는 인프라 기능. 매일 자정에 루틴 완료 상태를 자동 초기화하고, 이전 기록을 통계용으로 보존한다.

---

## 자정 초기화 3가지 시나리오

### 시나리오 A: 앱이 포그라운드에서 자정 넘김
```
23:59 → 00:00
  → Timer (60초 주기) 날짜 변경 감지
  → 새 DailyRecord 생성 (모든 활성 루틴 = false)
  → 홈 화면 자동 갱신 (모든 체크박스 미완료로)
```

### 시나리오 B: 백그라운드 복귀
```
앱이 백그라운드 → 자정 지남 → 포그라운드 복귀
  → AppLifecycleState.resumed 감지
  → 날짜 비교 → 변경됨
  → 새 DailyRecord 생성
  → 홈 화면 갱신
```

### 시나리오 C: 며칠 만에 앱 실행
```
앱 실행
  → main.dart에서 getOrCreateToday() 호출
  → 오늘 날짜의 DailyRecord 없음
  → 새 DailyRecord 생성
  → (중간 날짜는 생성하지 않음 - 빈 데이터)
```

---

## DailyRecord 생성 로직
```
getOrCreateToday():
  today = format(DateTime.now(), 'yyyy-MM-dd')
  record = hiveBox.get(today)
  if record == null:
    activeRoutines = routineRepo.getActive()
    record = DailyRecord(
      date: today,
      routineCompletions: { for r in activeRoutines: r.id → false }
    )
    hiveBox.put(today, record)
  return record
```

## 핵심 규칙
- 이전 날짜의 DailyRecord는 **절대 수정하지 않음** (통계용 보존)
- 추가 할 일(AdditionalTask)은 자정에 초기화되지 않음
- 비활성화된 루틴은 새 DailyRecord에 포함되지 않음
