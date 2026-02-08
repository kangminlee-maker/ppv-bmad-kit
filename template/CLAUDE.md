# PPV + BMad Workflow Protocol

이 파일은 PPV+BMad 통합 방법론의 글루 레이어이다. 도구 간 연결 규칙과 이벤트별 행동 지침을 정의한다.

## 도구 스택

| 도구 | 역할 |
|------|------|
| **Claude Code Native Teams** | 에이전트 조율, 태스크 의존성 추적 |
| **GitHub MCP Server** | Issue/PR 관리, 코드 리뷰 자동화 |
| **Vibe Kanban** | Kanban 보드, Git Worktree 격리, Plan-Approve-Execute |
| **BMad Method** | 요구 정의 에이전트, 워크플로우 |
| **PPV** | 병렬 실행 전략, 다차원 검증 |

## 워크플로우 모드

### Full Path (신규 프로덕트, 복잡한 기능)
```
BMad Phase 1 (Analysis) → Phase 2 (Planning) → Phase 3 (Solutioning)
    → Handoff → PPV PLAN → PREVIEW → PARALLEL → VALIDATE
```

### Quick Flow (소규모 작업)
```
/quick-spec → /dev-story → /code-review
```

### PPV Only (요구사항 확정된 경우)
```
/ppv-plan → /ppv-preview → /ppv-parallel → /ppv-validate
```

## BMad 에이전트 사용법

BMad 에이전트를 사용하려면 `@agent-name`으로 호출한다:
- `@analyst` - Mary: 브레인스토밍, 리서치, Product Brief
- `@pm` - John: PRD, Epics & Stories
- `@architect` - Winston: Architecture, ADR
- `@dev` - Amelia: Story 구현
- `@qa` - Quinn: 테스트 자동화
- `@sm` - Bob: Sprint Planning, Story 준비
- `@ux-designer` - Sally: UX Design
- `@quick-flow` - Barry: Quick Spec → Dev → Review

## PPV 커맨드 사용법

- `/ppv-plan` - BMad 산출물 → PPV 스펙 변환, Entropy 태깅
- `/ppv-preview` - 프로토타입 생성 + 시각적 검증
- `/ppv-parallel` - 멀티에이전트 병렬 실행
- `/ppv-validate` - 4-Phase 검증 파이프라인
- `/ppv-circuit-breaker` - 방향 전환

## 핸드오프 규칙

### BMad → PPV (Phase 3 완료 시)
BMad Phase 3에서 Implementation Readiness를 통과하면:
1. planning-artifacts/ 산출물 확인 (PRD, Architecture, Epics)
2. `/ppv-plan` 실행하여 specs/ 생성
3. Entropy Tolerance 태깅 + 파일 소유권 배정

### PPV Worker 완료 시
Worker가 태스크를 완료하면:
1. TaskUpdate로 태스크를 completed 상태로 변경
2. sprint-status.yaml 업데이트 (BMad 연동)
3. GitHub Issue 상태 업데이트 (GitHub MCP)
4. 의존 태스크의 Worker에게 SendMessage로 알림

### Circuit Breaker 발동 시
- 동일 카테고리 3회 연속 VALIDATE 실패 → `/ppv-circuit-breaker` 자동 발동
- 경미 → PPV PLAN 복귀
- 중대 → BMad `/correct-course` 연동

## 파일 소유권 규칙

PARALLEL 단계에서 파일 충돌을 방지하기 위한 규칙:
1. `specs/{feature}/tasks.md`에 각 태스크의 소유 파일을 명시한다
2. Worker는 자신에게 배정된 파일만 수정할 수 있다
3. 공유 타입/인터페이스 파일은 PARALLEL 시작 전에 생성한다
4. 공유 파일 수정이 필요하면 팀 리더에게 SendMessage로 요청한다

## Sprint Status 동기화

BMad의 sprint-status.yaml과 PPV 태스크를 동기화한다:
```
Worker 완료 → sprint-status.yaml 업데이트
             → GitHub Issue 닫기
             → Vibe Kanban 보드 이동 (Done)
```

## 프로젝트 구조

```
{project-root}/
├── CLAUDE.md                    # 이 파일 (글루 레이어)
├── .mcp.json                    # MCP 서버 설정
├── .claude/
│   ├── agents/                  # BMad + PPV 에이전트
│   └── commands/                # PPV 슬래시 커맨드
├── _bmad/                       # BMad 워크플로우 (런타임 참조)
├── planning-artifacts/          # BMad 산출물 (Phase 1~3)
├── implementation-artifacts/    # BMad 구현 산출물
├── specs/                       # PPV 스펙 파일
│   └── {feature}/
│       ├── requirements.md
│       ├── design.md
│       └── tasks.md
└── src/                         # 소스 코드
```
