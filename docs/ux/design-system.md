# pTODOlist - Design System

## Creative North Star: "The Digital Sanctuary"

인터페이스는 고급 문구 세트처럼 느껴져야 한다 — 무거운 종이, 부드러운 빛, 의도적인 여백.
"Tonal Architecture"를 통해 선이 아닌 표면의 명도 변화로 시선을 안내한다.

### 시그니처 무브
- **Intentional White Space**: 헤드라인 주변에 충분한 여백
- **Typographic Scale**: 얇은 Display + 컴팩트한 Body로 에디토리얼 느낌
- **Tonal Layering**: 그림자 대신 Surface 톤 계층으로 깊이 표현

---

## 1. 공통 UI 컴포넌트

### RoutineTile (루틴 항목)
- 사각 체크박스 (rounded-md 6dp) + 제목 + 카테고리 색상 도트
- 배경: Surface Container Lowest (`#FFFFFF`)
- 완료 시: Primary Container 20% 배경, 텍스트 취소선
- 하위 정보: 서브태스크 수, 스트릭 (🔥 아이콘 + 일 수)
- 스와이프: 오른쪽→삭제 (Error 배경 + delete 아이콘)
- 간격: 카드 간 8dp 마진

### TaskCard (할 일 항목)
- 아이콘 원형 (40dp, 카테고리 색상 10% 배경) + 제목 + 완료 원형 버튼 (32dp)
- 배경: Surface Container Lowest (`#FFFFFF`)
- 완료 시: 텍스트 취소선, 원형 버튼 Primary fill
- 하위 정보: D+N (overdue), 서브태스크 수
- 스와이프: 오른쪽→삭제

### CategoryChip
- pill 형태 (rounded-full)
- 선택됨: Primary Container 배경 + On Primary Container 텍스트
- 미선택: Surface Container Low 배경 + On Surface Variant 텍스트
- 아이콘 + 텍스트 조합

### ProgressRing (Focus Ring)
- 원형 프로그레스 인디케이터 (140dp)
- SVG 스타일 CustomPaint: 8px 트랙 + 8px 프로그레스
- 중앙: 퍼센트 (Manrope Bold) + "DONE" 라벨 (Inter uppercase)
- 색상: 0~49% Tertiary, 50~99% Primary, 100% Primary

### SectionHeader
- 타이틀: Manrope 18sp Bold
- 선택적 배지: pill (Tertiary Container 배경), 9sp uppercase
- 선택적 트레일링: 액션 텍스트 버튼 (Primary 색상)

### EmptyState
- 중앙 아이콘 (64dp, Primary 40% 투명도) + 제목 + 설명
- 아이콘 예: eco (홈), leaderboard (통계)

### AddBottomSheet
- 상단 핸들 바 (32dp × 4dp, Outline Variant)
- 타이틀: Manrope 20sp Light
- 옵션 카드: 아이콘 박스 (44dp, rounded-lg 12dp) + 제목/설명 + chevron
- 카드 간 8dp 간격

### InsightCard (통계)
- Primary Container 배경, rounded-lg 16dp
- 섹션 라벨: "SMART INSIGHT" (10sp uppercase tracking-wide)
- 메인 텍스트: Manrope 22sp Light/Bold 혼합
- 장식: 우하단 큰 아이콘 (flare, 8% 투명도)

### PrivacyCard (설정)
- Primary Container 30% 배경, rounded-2xl 20dp
- Ghost Border: Primary Container 40%
- 아이콘 + Bold 타이틀 + 설명 텍스트
- 장식: 우하단 원형 blur

### SettingItem
- 아이콘 원형 (40dp, Surface Container High 배경) + 제목/설명 + chevron
- 배경: Surface Container Lowest, rounded-lg 16dp
- 위험 항목: Error 색상 아이콘/텍스트 + warning 아이콘

### SystemStatCard
- Surface Container Low 배경, rounded-2xl 20dp
- 라벨: 9sp uppercase tracking-wide
- 값: Manrope 24sp Light
- 선택적: LinearProgressIndicator (4px, rounded-full)

---

## 2. 화면 패턴

### 홈 화면 (Today's Progress)
- AppBar: 브랜드 아이콘 + "pTODOlist" (Manrope Bold, Brand Accent)
- Welcome 섹션: 섹션 라벨 + Display 헤드라인 ("Today's **Progress**") + 설명 + ProgressRing
- 루틴 섹션: SectionHeader (배지 "반복") + RoutineTile 리스트
- 할 일 섹션: SectionHeader (트레일링 "새 할 일") + TaskCard 리스트
- 명언 섹션: 인용문 카드 (Surface Container Low, eco 아이콘)
- FAB: 우하단 추가 버튼

### 통계 화면 (Statistics)
- 타이틀: "PERFORMANCE OVERVIEW" 라벨 + "통계" (Manrope 36sp Light)
- 기간 선택: SegmentedButton (일별/주별/월별)
- 주간 카드: 바 차트 (fl_chart) + 달성률 퍼센트
- 인사이트 카드: InsightCard (가장 꾸준한 루틴)
- 카테고리 섹션: CategoryBreakdown (카드형, 프로그레스 바)
- 하단 통계: 2열 (오늘 달성률 + 남은 할 일)

### 설정 화면 (Settings)
- 타이틀: "WORKSPACE" 라벨 + "설정" (Manrope 36sp ExtraLight)
- 프라이버시 카드: PrivacyCard
- 섹션 라벨: "DATA & ROUTINE" (10sp uppercase)
- 설정 항목: SettingItem 리스트 (카테고리, 알림, 보관기간, 테마)
- 위험 영역: 앱 초기화 (Error 색상)
- 시스템 통계: 2열 SystemStatCard (스토리지, 테마)

### 캘린더 화면
- 월 네비게이션: 좌/우 화살표 + 년월 타이틀
- 스트릭 배너: 연속 달성일 표시
- 캘린더 그리드: 7열, 달성률 기반 색상 (GitHub 잔디 스타일)
  - 0%: Surface Container Low
  - 1~25%: Primary 15%
  - 26~50%: Primary 35%
  - 51~75%: Primary 60%
  - 76~100%: Primary 100%
- 일별 상세: DraggableScrollableSheet

### 폼 화면 (모달/바텀시트)
- 상단: 제목 + 닫기 버튼
- 입력: "Quiet Input" 스타일 (테두리 없음, Surface Container Lowest 배경)
- 카테고리 선택: CategoryChip 그리드
- 하단: 저장 버튼 (Primary, rounded-full)

---

## 3. 인터랙션 패턴

### 체크박스 토글
1. 탭 → 체크 상태 토글
2. 완료 시 배경 톤 변경 (Surface → Primary Container 20%)
3. 프로그레스 링 업데이트

### 스와이프 삭제
1. 오른쪽→왼쪽 스와이프 → Error 배경 + delete 아이콘
2. 임계값 넘기면 즉시 삭제
3. 항목 제거 + 프로그레스 업데이트

### 항목 추가
1. FAB 탭 → AddBottomSheet (루틴/할 일 선택)
2. 선택 → 폼 바텀시트 슬라이드 업
3. 저장 → 리스트에 항목 추가

### 바텀시트 선택 (설정)
1. 설정 항목 탭 → 바텀시트 옵션 리스트
2. 현재 선택 항목에 Primary 체크 아이콘
3. 선택 → 바텀시트 닫힘 + 값 업데이트

---

## 4. 레퍼런스 / 벤치마킹

- **Moonly App**: Tonal Architecture, 명상적 UI, 프리미엄 감성
- **Apple Reminders**: 심플한 체크리스트 UX
- **Things 3**: 에디토리얼 타이포그래피, 여백 활용
- **Streaks**: 원형 프로그레스, 습관 완료 시각화
- **Notion**: 토널 레이어링, Ghost Border 패턴

> 위 서비스의 톤 앤 매너를 참고하되, 브랜드 자산은 복제하지 않는다.

---

## 5. Surface Hierarchy (No-Line Rule)

```
┌─────────────────────────────────────┐
│  Surface (#F8F9FA) - Base Layer     │
│  ┌───────────────────────────────┐  │
│  │ Surface Container Low         │  │
│  │ (#F1F4F5) - Secondary         │  │
│  │  ┌─────────────────────────┐  │  │
│  │  │ Surface Container       │  │  │
│  │  │ Lowest (#FFFFFF)        │  │  │
│  │  │ - Interactive Cards     │  │  │
│  │  └─────────────────────────┘  │  │
│  └───────────────────────────────┘  │
│                                     │
│  Active/Focus: Primary Container    │
│  (#B1F0CE) - Soft Minty Glow       │
└─────────────────────────────────────┘
```

구조는 배경 색상의 톤 차이로 표현한다.
1px solid 보더로 섹션을 나누지 않는다.
