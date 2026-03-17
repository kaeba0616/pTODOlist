# pTODOlist - Architecture

## 시스템 다이어그램

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                           │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │                  Views (Widgets)                  │   │
│  │  HomeView │ StatsView │ SettingsView │ Forms     │   │
│  └────────────────────┬────────────────────────────┘   │
│                       │ watch/read                      │
│  ┌────────────────────▼────────────────────────────┐   │
│  │              ViewModels (Riverpod)                │   │
│  │  HomeVM │ RoutineVM │ TaskVM │ StatsVM │ etc.   │   │
│  └────────────────────┬────────────────────────────┘   │
│                       │ call                            │
│  ┌────────────────────▼────────────────────────────┐   │
│  │               Repositories                        │   │
│  │  CategoryRepo │ RoutineRepo │ TaskRepo │ etc.    │   │
│  │  ┌─────────────────────────────────────┐         │   │
│  │  │  Mock Provider (USE_MOCK=true)      │         │   │
│  │  │  → returns mock data               │         │   │
│  │  ├─────────────────────────────────────┤         │   │
│  │  │  Real Provider (default)            │         │   │
│  │  │  → reads/writes Hive boxes         │         │   │
│  │  └─────────────────────────────────────┘         │   │
│  └────────────────────┬────────────────────────────┘   │
│                       │ read/write                      │
│  ┌────────────────────▼────────────────────────────┐   │
│  │              Hive Local Storage                   │   │
│  │  categories │ routines │ tasks │ records │ settings│  │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │              Core Services                        │   │
│  │  MidnightResetService │ NotificationService      │   │
│  │  DataCleanupService   │ DatabaseService          │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘

외부 의존:
  ├── OS Notification System (flutter_local_notifications)
  └── OS Background Task (workmanager)
```

---

## 레이어 규칙

1. **Views** → ViewModels만 참조 (Repository 직접 접근 금지)
2. **ViewModels** → Repositories만 참조 (Hive Box 직접 접근 금지)
3. **Repositories** → Hive Boxes 또는 Mock 데이터 접근
4. **Services** → Repositories를 통해 데이터 접근 (Hive 직접 접근은 초기화 시에만)

---

## 자정 리셋 아키텍처

```
┌──────────────┐     ┌────────────────────┐     ┌─────────────┐
│  Timer (60s) │────▶│ MidnightResetService│────▶│ DailyRecord │
│  periodic    │     │ checks date change  │     │ Repository  │
└──────────────┘     └────────────────────┘     └──────┬──────┘
                              ▲                        │
┌──────────────┐              │                        ▼
│ AppLifecycle │──── resumed ──┘                 ┌────────────┐
│ Observer     │                                 │ Hive Box   │
└──────────────┘                                 │ dailyRecords│
                                                 └────────────┘
```

---

## 알림 아키텍처

```
┌──────────────────┐
│   WorkManager     │ ← 매일 22:55 스케줄
│   Background Task │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Hive 재초기화     │────▶│ DailyRecord 조회  │
│ (isolate)        │     │ 미완료 카운트      │
└──────────────────┘     └────────┬─────────┘
                                  │
                         ┌────────▼─────────┐
                         │  미완료 > 0 ?     │
                         ├── Yes ──▶ 알림 표시│
                         └── No ───▶ 무음    │
                         └──────────────────┘
```
