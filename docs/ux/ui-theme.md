# pTODOlist - UI Theme Guide

## 디자인 원칙: "The Digital Sanctuary"

- **Mindful Canvas** 디자인 시스템 기반
- Material Design 3 + Tonal Architecture
- "No-Line Rule": 디바이더 대신 배경 톤 차이로 구조 표현
- 프리미엄 스테이셔너리 느낌의 "Calm Productivity" 환경
- Manrope + Inter 서체 조합으로 에디토리얼 타이포그래피

---

## 1. 컬러 팔레트: "Mint & Stone"

### Primary Colors (Forest Green)
| 이름 | Hex | 용도 |
|---|---|---|
| Primary | `#2D6A4F` | 주요 버튼, FAB, 완료 표시 |
| Primary Dim | `#1F5E44` | Primary 호버/프레스 상태 |
| Primary Container | `#B1F0CE` | 선택된 항목 배경, 활성 네비 |
| On Primary | `#E6FFEE` | Primary 위의 텍스트/아이콘 |
| On Primary Container | `#1D5C42` | Primary Container 위 텍스트 |
| Brand Accent | `#006A6A` | AppBar 타이틀, 브랜드 강조 |

### Secondary Colors
| 이름 | Hex | 용도 |
|---|---|---|
| Secondary | `#426658` | 보조 요소 |
| Secondary Container | `#C4EBD9` | 보조 배경 |

### Tertiary Colors
| 이름 | Hex | 용도 |
|---|---|---|
| Tertiary | `#56634A` | 진행 중 상태, 보조 강조 |
| Tertiary Container | `#EFFFDE` | 반복 배지 배경 |

### Surface Colors (Tonal Architecture)
| 이름 | Hex | 용도 | 레이어 |
|---|---|---|---|
| Surface / Background | `#F8F9FA` | 앱 전체 배경 | Base Layer |
| Surface Container Low | `#F1F4F5` | 섹션 그룹 배경, 명언 카드 | Secondary |
| Surface Container | `#EBEEF0` | 컨테이너 기본 | - |
| Surface Container High | `#E5E9EB` | 아이콘 배경, 세팅 항목 | - |
| Surface Container Highest | `#DEE3E6` | 프로그레스 트랙, 인터랙티브 | Foremost |
| Surface Container Lowest | `#FFFFFF` | 카드, 입력 필드 (pop 효과) | Interactive |

### Text Colors
| 이름 | Hex | 용도 |
|---|---|---|
| On Surface | `#2D3335` | 주요 텍스트 (순수 검정 금지) |
| On Surface Variant | `#5A6062` | 보조 텍스트, 설명 |

### Outline Colors
| 이름 | Hex | 용도 |
|---|---|---|
| Outline | `#767C7E` | 테두리 (최소 사용) |
| Outline Variant | `#ADB3B5` | Ghost Border (15% 투명도) |

### Semantic Colors
| 이름 | Hex | 용도 |
|---|---|---|
| Success | `#2D6A4F` | 완료 (Primary와 동일) |
| Warning | `#F59E0B` | 부분 달성, 스트릭 |
| Error | `#A83836` | 삭제, 초기화 |
| Error Container | `#FA746F` | 에러 배경 |

### Category Default Colors
| 카테고리 | Hex |
|---|---|
| 운동 | `#EF4444` (Red) |
| 공부 | `#3B82F6` (Blue) |
| 업무 | `#F59E0B` (Amber) |
| 생활 | `#10B981` (Green) |
| 기타 | `#8B5CF6` (Purple) |

### Dark Mode
| 이름 | Light | Dark |
|---|---|---|
| Background | `#F8F9FA` | `#0C0F10` |
| Surface | `#F8F9FA` | `#1A1C1E` |
| Card | `#FFFFFF` | `#22252A` |
| Border | transparent | `#2E3238` |
| On Surface | `#2D3335` | `#F1F4F5` |
| On Surface Variant | `#5A6062` | `#9CA3AF` |
| Primary | `#2D6A4F` | `#B1F0CE` |
| Primary Container | `#B1F0CE` | `#005050` |
| On Primary | `#E6FFEE` | `#003737` |

---

## 2. 타이포그래피: Editorial Authority

### 서체
| 역할 | 서체 | 특징 |
|---|---|---|
| Display / Headline | **Manrope** | 기하학적, 모던, 넓은 aperture |
| Body / Label | **Inter** | 최적의 가독성, 정보 밀도 |

### 스타일 스케일
| 스타일 | 서체 | 크기 | 무게 | 용도 |
|---|---|---|---|---|
| displayLarge | Manrope | 48sp | ExtraLight (200) | 대형 인트로 텍스트 |
| displayMedium | Manrope | 36sp | Light (300) | 통계 타이틀 |
| headlineLarge | Manrope | 28sp | Bold (700) | 화면 메인 헤드라인 |
| headlineMedium | Manrope | 24sp | Medium (500) | 카드 제목 |
| headlineSmall | Manrope | 20sp | Bold (700) | 섹션 제목 |
| titleLarge | Inter | 20sp | SemiBold (600) | AppBar 타이틀 |
| titleMedium | Inter | 16sp | SemiBold (600) | 카드 내 제목 |
| bodyLarge | Inter | 16sp | Regular (400) | 본문 텍스트 |
| bodyMedium | Inter | 14sp | Regular (400) | 보조 텍스트 |
| bodySmall | Inter | 12sp | Regular (400) | 작은 설명 |
| labelLarge | Inter | 14sp | SemiBold (600) | 버튼 텍스트 |
| labelMedium | Inter | 12sp | SemiBold (600) | 배지 텍스트 |
| labelSmall | Inter | 10sp | Bold (700) | 라벨, 섹션 태그 (tracking: 1.5) |

### 타이포 규칙
- **Visual Drama**: 스케일 건너뛰기 (Headline-SM → Body-MD, 유사 크기 나란히 금지)
- **섹션 라벨**: `text-[10px] uppercase tracking-widest font-bold` 패턴
- `#000000` 순수 검정 텍스트 사용 금지 → `#2D3335` (On Surface)

---

## 3. 여백 & 간격

| 토큰 | 값 | 용도 |
|---|---|---|
| spacing-xs | 4dp | 아이콘-텍스트 간격 |
| spacing-sm | 8dp | 카드 내부 요소 간격 |
| spacing-md | 16dp | 카드 패딩, 리스트 간격 |
| spacing-lg | 24dp | 섹션 간격 |
| spacing-xl | 32dp | 대형 섹션 간격 |
| page-margin | 16dp | 화면 좌우 패딩 |

> "Gallery" 느낌을 위해 `spacing-lg`, `spacing-xl`을 페이지 마진으로 적극 활용

---

## 4. 컴포넌트 스타일

### 체크박스 (루틴)
- 형태: 사각 rounded-md (6dp 반경)
- 미완료: 투명 배경, Primary 30% 테두리 (2px)
- 완료: Primary 배경, On Primary 체크 아이콘
- 크기: 24×24dp

### 완료 원형 버튼 (할 일)
- 형태: 원형 (32×32dp)
- 미완료: 투명 배경, Outline Variant 50% 테두리 (2px)
- 완료: Primary 배경, On Primary 체크 아이콘

### 카드 / 타일
- 배경: Surface Container Lowest (`#FFFFFF`)
- 모서리 반경: 16dp
- 그림자: 없음 (Tonal Architecture)
- 테두리: 없음 (No-Line Rule) — 필요 시 Ghost Border (outline-variant 15%)
- 패딩: 16dp 전체
- 완료된 항목: 텍스트 취소선 + On Surface Variant 색상

### 섹션 헤더
- 타이틀: Manrope 18sp Bold
- 배지: pill 형태 (rounded-full), 9sp uppercase tracking-wide
- 배지 예시: Tertiary Container 배경 + Tertiary 텍스트

### FAB (Floating Action Button)
- 크기: 기본 (56dp)
- 색상: Primary 배경, On Primary 아이콘
- 모서리 반경: 16dp
- 그림자: elevation 4
- 위치: 우하단

### 바텀 네비게이션
- 높이: 72dp
- 배경: Surface 90% 투명도 + backdrop blur
- 활성 탭: Primary Container 배경 pill 안에 아이콘 + 라벨
- 비활성 탭: On Surface Variant 70% 투명도
- 라벨: Inter 10sp Bold uppercase tracking-wide
- 탭 4개: 오늘 / 달력 / 통계 / 설정

### 프로그레스 링 (Focus Ring)
- 크기: 140dp
- 트랙: Surface Container Highest, 8px 두께
- 프로그레스: Primary 색상, rounded cap
- 중앙 텍스트: Manrope 28sp Bold (퍼센트) + Inter 9sp Bold uppercase ("DONE")
- 색상 규칙: 0~49% Tertiary, 50~99% Primary, 100% Primary

### 입력 필드 ("Quiet Input")
- 배경: Surface Container Lowest
- 테두리: 없음 (No-Line Rule)
- 모서리 반경: 16dp
- 포커스 시: Primary Container 10% 배경 전환
- 패딩: horizontal 20dp, vertical 16dp

### 명언/인사이트 카드
- 배경: Surface Container Low
- 모서리 반경: 20dp
- 패딩: horizontal 24dp, vertical 28dp
- 아이콘: eco 아이콘 (Tertiary 색상, 32dp)
- 텍스트: Manrope 16sp italic

---

## 5. 금지 사항 (Design Don'ts)

- ❌ 순수 검정 (`#000000`) 텍스트 사용 금지
- ❌ 1px solid 디바이더로 섹션 구분 금지
- ❌ 날카로운 모서리 (sharp corners) 사용 금지
- ❌ 일반 아이콘 (thick stroke) 사용 금지 → thin-stroke 아이콘 권장
- ❌ Primary 색상을 장식용으로 남용 금지 → 완료/성취의 보상으로만 사용
