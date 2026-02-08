# PPV PLAN - Execution Plan Generation

BMad 산출물을 PPV 병렬 실행 계획으로 변환한다.

## Prerequisites
- BMad Phase 3 산출물 존재 확인:
  - `**/planning-artifacts/prd.md` (또는 PRD 역할 문서)
  - `**/planning-artifacts/architecture.md` (또는 아키텍처 문서)
  - `**/planning-artifacts/epics*.md` (또는 에픽/스토리 문서)
- Implementation Readiness 통과 여부 확인

## Execution Steps

### Step 1: BMad 산출물 로드
1. planning-artifacts 디렉토리에서 PRD, Architecture, Epics 문서를 읽는다
2. 문서가 없으면 사용자에게 BMad Phase 1~3 실행을 안내한다

### Step 2: 스펙 파일 생성
`specs/{feature-name}/` 디렉토리에 3-file 패턴을 생성한다:

```markdown
specs/{feature-name}/
├── requirements.md    # PRD + Story에서 추출한 수용 기준
├── design.md          # Architecture에서 추출한 기술 설계
└── tasks.md           # Epic/Story → 병렬 태스크 변환
```

### Step 3: Entropy Tolerance 태깅
각 태스크에 리스크 수준을 태깅한다:
- **High (Porous)**: UI 스타일링, 애니메이션 → 자동 테스트만
- **Medium**: CRUD API, 비즈니스 로직 → 자동 + AI 리뷰
- **Low (Dense)**: 인증, 결제, 핵심 비즈니스 → 자동 + AI + 수동 리뷰

### Step 4: 파일 소유권 배정
각 태스크에 담당 파일을 배정한다. 동일 파일이 2개 이상의 태스크에 배정되면 안 된다:
```markdown
## Task N: [설명] (Worker-N, Entropy: Medium)
- 소유 파일: src/path/file1.ts, src/path/file2.ts
- 인터페이스: shared types at types.ts:L{start}-L{end}
- 의존성: [선행 태스크 ID]
```

### Step 5: 플래닝 레벨 결정
| 레벨 | 조건 | 적용 |
|------|------|------|
| Skip | 단순 수정 | PPV 불필요, BMad Quick Flow |
| Lite | 명확한 요구사항 | 간단한 태스크 리스트 |
| Spec | 여러 파일 수정 | requirements + design + tasks |
| Full | 아키텍처 변경 | 위 + 재귀적 플래너 |

### Step 6: 계획 출력
생성된 `tasks.md`를 사용자에게 보여주고 승인을 받는다.
승인 후 PREVIEW 또는 PARALLEL 단계로 진행한다.

## Output
- `specs/{feature-name}/requirements.md`
- `specs/{feature-name}/design.md`
- `specs/{feature-name}/tasks.md`
