# pTODOlist - UI Theme Guide

## 디자인 원칙
- Material Design 3 기반
- 미니멀하고 깔끔한 인터페이스
- 직관적인 체크리스트 중심 레이아웃

---

## 1. 컬러 팔레트

### Primary Colors
| 이름 | Hex | 용도 |
|---|---|---|
| Primary | `#4F46E5` | 주요 버튼, FAB, 활성 탭 |
| Primary Container | `#E0E7FF` | 선택된 항목 배경 |
| On Primary | `#FFFFFF` | Primary 위의 텍스트/아이콘 |

### Surface Colors
| 이름 | Hex | 용도 |
|---|---|---|
| Background | `#FAFAFA` | 앱 전체 배경 |
| Surface | `#FFFFFF` | 카드, 바텀시트 배경 |
| Surface Variant | `#F3F4F6` | 섹션 구분 배경 |

### Semantic Colors
| 이름 | Hex | 용도 |
|---|---|---|
| Success | `#10B981` | 완료 체크, 100% 달성 |
| Warning | `#F59E0B` | 부분 달성 |
| Error | `#EF4444` | 삭제, 미달성 |
| Info | `#3B82F6` | 정보성 알림 |

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
| Background | `#FAFAFA` | `#111827` |
| Surface | `#FFFFFF` | `#1F2937` |
| On Surface | `#111827` | `#F9FAFB` |
| Surface Variant | `#F3F4F6` | `#374151` |

---

## 2. 타이포그래피

Flutter의 Material 3 TextTheme 기반:

| 스타일 | 크기 | 무게 | 용도 |
|---|---|---|---|
| headlineLarge | 28sp | Bold | 날짜 헤더 |
| headlineMedium | 24sp | Bold | 섹션 제목 |
| titleLarge | 20sp | SemiBold | 화면 타이틀 |
| titleMedium | 16sp | SemiBold | 카드 제목 |
| bodyLarge | 16sp | Regular | 루틴/할 일 텍스트 |
| bodyMedium | 14sp | Regular | 설명, 부가 텍스트 |
| labelLarge | 14sp | Medium | 버튼 텍스트 |
| labelSmall | 12sp | Regular | 카테고리 태그, 날짜 |

### 폰트
- 기본: Pretendard (한국어 최적화)
- 폴백: System default

---

## 3. 여백 & 간격

| 토큰 | 값 | 용도 |
|---|---|---|
| spacing-xs | 4dp | 아이콘-텍스트 간격 |
| spacing-sm | 8dp | 리스트 아이템 내부 |
| spacing-md | 16dp | 섹션 간격, 카드 패딩 |
| spacing-lg | 24dp | 화면 가장자리 패딩 |
| spacing-xl | 32dp | 섹션 간 대간격 |

---

## 4. 컴포넌트 스타일

### 체크박스
- 미완료: 빈 원형 (border: Primary)
- 완료: 채워진 원형 (fill: Success, checkmark: white)
- 애니메이션: 탭 시 0.2초 스케일 + 체크 드로잉

### 카드 / 타일
- 모서리 반경: 12dp
- 그림자: elevation 1 (미세한 그림자)
- 완료된 항목: 텍스트에 취소선, 투명도 60%

### FAB
- 크기: 56dp
- 색상: Primary
- 아이콘: + (white)
- 위치: 우하단, 바텀 네비게이션 위

### 바텀 네비게이션
- 탭 3개: 오늘 (홈 아이콘) / 통계 (차트 아이콘) / 설정 (기어 아이콘)
- 활성: Primary 색상
- 비활성: Gray 400

### 프로그레스 링
- 크기: 80dp (홈 상단)
- 트랙: Surface Variant
- 프로그레스: Primary → Success (100%)
- 중앙: 퍼센트 텍스트 (headlineMedium)
