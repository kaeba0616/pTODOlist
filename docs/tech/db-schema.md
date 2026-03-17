# pTODOlist - DB Schema (Hive)

## 개요
모든 데이터는 Hive NoSQL 로컬 저장소에 저장된다.
각 엔티티는 Hive Box에 저장되며, TypeAdapter로 직렬화한다.

---

## 1. Hive Boxes

### Box: `categories` (typeId: 0)
| 필드 | 타입 | 설명 |
|---|---|---|
| id | String (UUID) | PK |
| name | String | 카테고리 이름 (예: "운동") |
| color | String | Hex 색상 코드 (예: "#EF4444") |
| icon | String? | 아이콘 이름 (nullable) |

**키**: `id` (String)
**기본 시드**: 운동, 공부, 업무, 생활, 기타

---

### Box: `routines` (typeId: 1)
| 필드 | 타입 | 설명 |
|---|---|---|
| id | String (UUID) | PK |
| title | String | 루틴 제목 |
| categoryId | String | FK → categories.id |
| createdAt | DateTime | 생성일시 |
| isActive | bool | 활성 여부 (기본: true) |
| order | int | 정렬 순서 |

**키**: `id` (String)

---

### Box: `additionalTasks` (typeId: 2)
| 필드 | 타입 | 설명 |
|---|---|---|
| id | String (UUID) | PK |
| title | String | 할 일 제목 |
| categoryId | String | FK → categories.id |
| createdAt | DateTime | 생성일시 |
| targetDate | String | 대상 날짜 (yyyy-MM-dd) |
| isCompleted | bool | 완료 여부 (기본: false) |
| order | int | 정렬 순서 |

**키**: `id` (String)

---

### Box: `dailyRecords` (typeId: 3)
| 필드 | 타입 | 설명 |
|---|---|---|
| date | String | PK (yyyy-MM-dd) |
| routineCompletions | Map<String, bool> | routineId → 완료여부 |

**키**: `date` (String, yyyy-MM-dd)

**생성 규칙**:
- 앱 실행 시 오늘 날짜의 레코드가 없으면 자동 생성
- 활성 루틴 목록으로 `routineCompletions` 초기화 (모두 false)
- 이전 날짜의 레코드는 수정하지 않음 (통계용 보존)

---

### Box: `appSettings` (typeId: 4)
| 필드 | 타입 | 설명 |
|---|---|---|
| notificationEnabled | bool | 알림 활성 (기본: true) |
| notificationTime | String | 알림 시간 (기본: "23:00") |
| retentionMonths | int | 데이터 보관 기간 (기본: 6) |
| themeMode | String | 테마 (light/dark/system, 기본: system) |

**키**: 싱글턴 ("settings")

---

## 2. 관계 다이어그램

```
┌──────────────┐
│  categories  │
│  (id, name,  │
│   color)     │
└──────┬───────┘
       │ 1:N
  ┌────┴─────┐
  │          │
  ▼          ▼
┌─────────┐ ┌──────────────┐
│ routines│ │additionalTasks│
│ (title, │ │(title, target │
│  order) │ │ Date, done)   │
└────┬────┘ └──────────────┘
     │
     │ N:M (via routineCompletions)
     ▼
┌──────────────┐
│ dailyRecords │
│ (date,       │
│  completions)│
└──────────────┘
```

---

## 3. 마이그레이션 전략

- Hive TypeAdapter에 `typeId`를 고정 할당하여 버전 관리
- 필드 추가 시: 새 필드에 기본값 설정, 기존 데이터는 자동으로 null/기본값
- 필드 삭제/타입 변경 시: 마이그레이션 함수 작성 후 `DatabaseService.init()`에서 실행
- 마이그레이션 버전은 `appSettings` 박스에 `schemaVersion` 필드로 추적

---

## 4. 데이터 정리 정책

- 앱 실행 시 `DataCleanupService`가 실행
- `retentionMonths` 설정값에 따라 오래된 `dailyRecords` 삭제
- 기본값: 6개월 (180일 이상 된 레코드 삭제)
- `additionalTasks`에서 완료 + targetDate가 보관기간 초과한 항목도 삭제
