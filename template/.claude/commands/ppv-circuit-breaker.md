# PPV Circuit Breaker - Course Correction

VALIDATE 실패가 반복되거나 중대한 문제가 발견되었을 때 체계적으로 방향을 전환한다.

## Trigger Conditions

### 자동 발동
- 동일 카테고리 3회 연속 실패
- 인터페이스 계약 위반 3건 이상
- 아키텍처 레벨 설계 결함 발견

### 수동 발동
- 사용자 또는 에이전트가 `/ppv-circuit-breaker` 실행

## Execution Steps

### Step 1: 실패 컨텍스트 요약 (Context Compaction)
현재까지의 작업 상태를 요약한다:
```markdown
## Circuit Breaker Context

### 시도한 것
- [어떤 접근을 시도했는가]

### 실패 원인
- [왜 실패했는가]

### 부분 성공
- [어떤 부분이 성공적이었는가]

### 학습
- [이번 시도에서 배운 것]
```

### Step 2: 심각도 판단

**경미한 문제 (PPV 내부 해결):**
- 특정 태스크 구현 난항
- 인터페이스 계약 위반 1~2건
- 테스트 실패 반복

→ 스펙 수정 → PPV PLAN으로 복귀

**중대한 문제 (BMad 연동):**
- 아키텍처 레벨 설계 결함
- PRD 요구사항 자체의 모순
- 기술 스택 변경 필요
- 인터페이스 계약 위반 3건+

→ BMad `/correct-course` 실행

### Step 3: 코드 폐기 (Disposable Code)
```
보존:                        폐기:
─────                        ─────
BMad PRD                     모든 생성 코드
BMad Architecture + ADR      워크트리
BMad Epic/Story              빌드 산출물
PPV specs/ (수정 후)
실패 학습 컨텍스트
```

### Step 4: 복귀

**경미 → PPV PLAN 복귀:**
1. 실패 학습 컨텍스트를 PPV PLAN에 전달
2. 수정된 스펙으로 재계획
3. PLAN → PREVIEW → PARALLEL → VALIDATE 재실행

**중대 → BMad Course Correction:**
1. BMad SM (Bob)의 `/correct-course` 워크플로우 실행
2. 변경 범위 분석
3. PRD/Architecture 영향도 평가
4. BMad 산출물 업데이트 (PRD 수정, Architecture 수정, Epic/Story 재구성)
5. Implementation Readiness 재확인
6. PPV PLAN으로 복귀

## Spec-as-Source Principle
코드가 아닌 스펙이 자산이므로, Circuit Breaker 발동 시 실질적 손실이 최소화된다.
코드를 전량 폐기해도 스펙이 보존되므로 재구현 비용이 낮다.
