# PPV PARALLEL - Multi-Agent Parallel Execution

태스크를 병렬로 실행한다. Native Teams + Vibe Kanban + GitHub MCP를 활용한다.

## Prerequisites
- PPV PLAN 완료: `specs/{feature}/tasks.md` 존재
- 파일 소유권 배정 완료
- 인터페이스 계약 (공유 타입) 정의 완료

## Execution Steps

### Step 1: 인터페이스 계약 생성
공유 타입/인터페이스를 먼저 생성한다 (모든 Worker가 참조):
- tasks.md에서 인터페이스 계약 추출
- 공유 타입 파일 생성 (예: `src/types.ts`)
- 이 단계는 병렬화하지 않는다

### Step 2: GitHub Issues 생성
GitHub MCP Server를 통해 각 태스크를 Issue로 생성한다:
```
각 Task → GitHub Issue
- Title: Task 설명
- Body: 소유 파일, 인터페이스, 의존성, Entropy 레벨
- Labels: entropy-high / entropy-medium / entropy-low
```

### Step 3: Vibe Kanban 워크트리 설정
Vibe Kanban을 통해 태스크별 Git Worktree를 생성한다:
- 각 Worker에 독립된 worktree 할당
- 메인 브랜치에서 분기
- 파일 충돌 원천 차단

### Step 4: Native Teams 에이전트 생성
Claude Code Native Teams로 Worker 에이전트를 생성한다:
1. TeamCreate로 팀 생성
2. 각 Worker를 Task tool로 생성 (subagent_type: general-purpose)
3. 각 Worker에 ppv-worker 에이전트 역할 지시
4. TaskCreate로 태스크 생성 후 TaskUpdate로 할당

### Step 5: 병렬 실행 모니터링
- 각 Worker가 태스크를 실행한다
- Worker 완료 시 → SendMessage로 핸드오프
- sprint-status.yaml 업데이트
- GitHub Issue 상태 업데이트

### Step 6: Merge & Integration
모든 Worker 완료 후:
1. 각 worktree의 변경사항을 메인 브랜치에 merge
2. 통합 테스트 실행
3. 충돌 발생 시 해결
4. VALIDATE 단계로 진행

## Handoff Protocol
Worker 간 인수인계 시 다음 형식을 사용한다:
```markdown
## Handoff: Worker-N → Worker-M

### Goal
[달성한 목표]

### Changes
- [파일]: [변경 내용]

### Open Questions
- [미해결 이슈]

### Next Owner
Worker-M — [다음 작업 설명]
```
