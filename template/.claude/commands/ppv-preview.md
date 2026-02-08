# PPV PREVIEW - Visual Verification

스펙에서 프로토타입을 생성하고 사용자의 시각적 확인을 받는다.

## Prerequisites
- PPV PLAN 완료: `specs/{feature}/` 디렉토리 존재
- BMad UX Design 존재 시 검증 기준으로 사용

## Execution Steps

### Step 1: 프리뷰 대상 확인
1. `specs/{feature}/requirements.md`에서 UI 관련 수용 기준 추출
2. `planning-artifacts/ux-design.md` 존재 시 UX 검증 기준 추출
3. 프리뷰가 불필요한 경우 (백엔드 전용) 사용자에게 알리고 PARALLEL로 진행

### Step 2: 프로토타입 생성
- Vibe Coding으로 프로토타입을 빠르게 생성한다
- 코드 품질은 무시. Entropy Tolerance가 높은 프로세스
- v0, Bolt.new 등 프로토타이핑 도구 사용을 권장할 수 있다

### Step 3: 사용자 시각적 확인
사용자에게 프로토타입을 보여주고 확인을 받는다:
- BMad UX Design 대비 검증 (있는 경우)
- 화면 구성 요소 확인
- 사용자 플로우 확인
- 인터랙션 패턴 확인

### Step 4: 피드백 처리
- **OK**: PARALLEL 단계로 진행
- **수정 필요**: 스펙을 수정하고 프로토타입 재생성 (Step 2로 복귀)
- **중대한 변경**: BMad Phase 2~3 산출물 수정 필요 → 사용자와 협의

## Core Principles
1. **Disposable Preview**: 프리뷰 코드는 프로덕션과 완전 분리. 절대 프로덕션으로 이관하지 않는다
2. **빠른 반복**: 검증 최소화, 속도 최대화
3. **스펙 우선**: 프리뷰에서 발견한 문제는 코드가 아닌 스펙을 수정하여 해결
4. **UX 기준**: BMad UX Design이 있으면 검증 기준으로 사용
