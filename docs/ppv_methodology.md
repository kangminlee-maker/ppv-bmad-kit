# PPV + BMad 통합 방법론

> **프로젝트**: 26-W06-Jiri
> **문서 유형**: 개발 방법론 설계
> **버전**: v2.2 (구현 도구 스택 확정)
> **작성일**: 2026-02-08
> **상태**: 구현 준비

---

## 1. 개요

### 1.1 통합 방법론이란?

BMad Method(요구 정의 프레임워크)와 PPV(실행 전략)를 결합한 AI 네이티브 개발 방법론이다.

- **BMad Method**: "무엇을 만들 것인가"를 정의한다. 8개 전문 에이전트가 분석 → 기획 → 설계 → 구현 준비를 순차적으로 수행한다.
- **PPV**: "어떻게 빠르고 안전하게 구현할 것인가"를 다룬다. 멀티에이전트 병렬 실행과 다차원 검증으로 구현 속도와 품질을 동시에 확보한다.

두 방법론은 서로 다른 레이어에서 작동하므로 충돌 없이 시너지를 낸다.

### 1.2 구현 도구 스택

PPV+BMad를 실행하기 위한 확정 도구 스택이다. 설치 가능한 패키지로 배포한다.

```
┌─────────────────────────────────────────────────────────┐
│                    ppv-bmad-kit                          │
│            (설치 가능한 방법론 패키지)                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  .claude/agents/     BMad 에이전트 → Claude Code 변환   │
│  .claude/commands/   PPV 워크플로우 슬래시 커맨드       │
│  CLAUDE.md           글루 레이어 (도구 체인 프로토콜)    │
│  _bmad/              BMad 워크플로우 (런타임 참조)       │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  외부 도구 연동 (MCP)                                   │
│                                                         │
│  Claude Code Native Teams  에이전트 조율 + 태스크 관리  │
│  GitHub MCP Server (27k★)  GitHub Issues/PR 관리        │
│  Vibe Kanban (14.7k★)      Kanban 보드 + Git Worktree   │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  글루 레이어: CLAUDE.md 워크플로우 프로토콜              │
│  (도구 간 연결 규칙, 이벤트별 행동 지침)                │
└─────────────────────────────────────────────────────────┘
```

**도구 선정 근거:**

| 도구 | 선정 이유 | 제외된 대안 | 제외 사유 |
|------|----------|------------|----------|
| **Native Teams** | 내장, 안정적, 태스크 의존성 추적 | Claude-Flow | 과도한 기능, 미검증 성능 주장 |
| **GitHub MCP Server** | GitHub 공식, 26.7k stars, 프로덕션급 | CCPM | 실험적, 2025.09 이후 업데이트 없음 |
| **Vibe Kanban** | Kanban+Worktree+Plan-Approve 통합, YC 투자 | Automaker | 초기 단계(2.8k), Vibe Kanban이 상위 호환 |
| **BMad (기존 유지)** | 이미 설치됨, 9개 에이전트, 39+ 워크플로우 | GitHub Spec-Kit | BMad와 기능 중복, 에이전트 시스템 없음 |
| **PPV PLAN 수동 소유권** | 글루 레이어로 충분, 복잡도 최소화 | parallel-cc | Vibe Kanban과 중복, 6 stars |

### 1.3 통합 워크플로우 전체도

```
┌─────────────────────────────────────────────────────────────────────┐
│                    BMad Method (요구 정의)                           │
│                                                                     │
│  Phase 1: Analysis          Phase 2: Planning                       │
│  ┌──────────────────┐       ┌──────────────────────────┐            │
│  │ Mary (Analyst)   │──────▶│ John (PM) → PRD          │            │
│  │ 브레인스토밍     │       │ UX Designer → UX 설계    │            │
│  │ 리서치           │       └────────────┬─────────────┘            │
│  │ Product Brief    │                    │                          │
│  └──────────────────┘                    ▼                          │
│                             Phase 3: Solutioning                    │
│                             ┌──────────────────────────┐            │
│                             │ Winston (Architect)      │            │
│                             │ → Architecture + ADR     │            │
│                             │ John (PM)                │            │
│                             │ → Epics & Stories        │            │
│                             │ Implementation Readiness │            │
│                             └────────────┬─────────────┘            │
│                                          │ ✅ Ready                  │
└──────────────────────────────────────────┼──────────────────────────┘
                                           │
                    ╔══════════════════════╗│
                    ║   핸드오프 지점      ║◀┘
                    ║ BMad 산출물 → PPV    ║
                    ╚══════════╦═══════════╝
                               │
┌──────────────────────────────┼──────────────────────────────────────┐
│                    PPV (실행 전략)                                   │
│                              ▼                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │   PLAN   │─▶│ PREVIEW  │─▶│ PARALLEL │─▶│ VALIDATE │            │
│  │ 실행계획 │  │ 시각검증 │  │ 병렬구현 │  │ 다차원   │            │
│  │ 수립     │  │          │  │          │  │ 검증     │            │
│  └──────────┘  └──────────┘  └──────────┘  └────┬─────┘            │
│       ▲                                         │                   │
│       │              Circuit Breaker             │                   │
│       └──────────────────────────────────────────┘                  │
│                                                                     │
│  BMad Phase 4 에이전트 연동:                                        │
│  Bob (SM) → 스프린트 관리  |  Amelia (Dev) → Worker                │
│  Quinn (QA) → 테스트 생성  |  Barry (Quick Flow) → 경량 구현       │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.4 언제 무엇을 사용하는가

| 상황 | 접근 방식 | 설명 |
|------|----------|------|
| 신규 프로덕트, 복잡한 기능 | **BMad Full Path + PPV Full** | BMad Phase 1~3 전체 수행 후 PPV 4단계 실행 |
| 중규모 기능, 명확한 요구사항 | **BMad Quick Flow + PPV Lite** | `/quick-spec` → PPV PLAN(Lite) → PARALLEL → VALIDATE |
| 버그 픽스, 단순 수정 | **BMad Quick Flow Only** | `/quick-spec` → `/dev-story` → `/code-review` (PPV 불필요) |
| 기획만 필요 (구현 불필요) | **BMad Only** | Phase 1~3만 수행하여 산출물 생산 |

### 1.5 분석 대상 구현체

| 구현체 | 유형 | 핵심 강점 |
|--------|------|----------|
| **BMad Method v6.0** | 프레임워크 | 8개 전문 에이전트, 4단계 워크플로우, 슬래시 커맨드 |
| **Cascade Methodology** | 방법론 | Entropy Tolerance, Verification Gates, Why Down, MSP |
| **Cursor 2.0** | 상용 IDE | 재귀적 Planner 계층, Git Worktree, 127규칙 Judge |
| **Xebia ACE** | 상용 플랫폼 | 15+ 에이전트 팀, 멀티에이전트 감독, Traceable Flow |
| **Auto-Claude** | 오픈소스 | 50회 QA 루프, Chrome DevTools 통합, 복잡도 자동 평가 |
| **Automaker** | 오픈소스 | 4단계 플래닝 레벨, Ultrathink, Kanban 워크플로우 |
| **Claude-Flow** | 오픈소스 | Hive Mind, BFT, Stream-JSON 체이닝, Persistent Memory |
| **Kiro** | 상용 IDE | EARS 스펙, 스펙-코드 양방향 동기화, PBT |
| **Zenflow** | 상용 도구 | 교차 모델 검증, Git Worktree |
| **Tessl** | 상용 도구 | Spec-as-Source, Disposable Code, Tiles |

---

## 2. BMad 요구 정의 단계 (Phase 1~3)

PPV 실행에 앞서 BMad Method가 "무엇을 만들 것인가"를 정의한다. 이 단계는 BMad의 기존 워크플로우를 그대로 사용하되, PPV 실행에 필요한 산출물을 명시적으로 준비한다.

### 2.1 BMad 에이전트 역할 맵

| 에이전트 | 이름 | BMad 역할 | PPV 연동 |
|---------|------|----------|----------|
| Analyst | Mary | 브레인스토밍, 리서치, Product Brief | PLAN의 컨텍스트 입력 |
| PM | John | PRD, Epics & Stories | PLAN의 태스크 원본 |
| UX Designer | - | UX 설계 | PREVIEW의 검증 기준 |
| Architect | Winston | Architecture, ADR | PLAN의 기술 제약, VALIDATE의 아키텍처 준수 기준 |
| SM | Bob | 스프린트 계획, 스토리 준비 | PLAN의 스토리 우선순위, PPV 스프린트 조율 |
| Dev | Amelia | 스토리 구현 | PARALLEL의 Worker 에이전트 |
| QA | Quinn | 테스트 자동화 | VALIDATE의 테스트 생성 |
| Quick Flow | Barry | 경량 구현 | PLAN(Skip/Lite) + 단독 실행 |

### 2.2 BMad Phase 1: Analysis

BMad의 슬래시 커맨드로 수행한다.

```
수행 순서:
1. /load-agent analyst (Mary)
2. Mary: [BP] Brainstorm Project → 아이디어 탐색
3. Mary: [RS] Research → 시장/도메인/기술 리서치
4. Mary: [CB] Create Brief → Product Brief 작성
```

**산출물**: `{planning_artifacts}/product-brief.md`

### 2.3 BMad Phase 2: Planning

```
수행 순서:
1. /load-agent pm (John)
2. John: [CP] Create PRD → 요구사항 문서
3. John: [VP] Validate PRD → PRD 검증
4. /load-agent ux-designer
5. UX Designer: UX Design → 화면 설계
```

**산출물**: `{planning_artifacts}/prd.md`, `{planning_artifacts}/ux-design.md`

### 2.4 BMad Phase 3: Solutioning

```
수행 순서:
1. /load-agent architect (Winston)
2. Winston: [CA] Create Architecture → 기술 설계 + ADR
3. /load-agent pm (John)
4. John: [CE] Create Epics and Stories → 에픽/스토리 목록
5. PM or Architect: [IR] Implementation Readiness → 구현 준비도 확인
```

**산출물**: `{planning_artifacts}/architecture.md`, `{planning_artifacts}/epics-and-stories.md`

### 2.5 BMad → PPV 핸드오프

Implementation Readiness 검증을 통과하면, BMad 산출물이 PPV PLAN 단계의 입력이 된다.

```
BMad 산출물                    PPV 입력 매핑
──────────────────────────     ──────────────────────────
product-brief.md          →   프로젝트 컨텍스트
prd.md                    →   요구사항 + 수용 기준
ux-design.md              →   PREVIEW 검증 기준
architecture.md           →   기술 제약 + 패턴
epics-and-stories.md      →   태스크 분해 원본
ADR 기록                  →   아키텍처 의사결정 제약
```

핸드오프 체크리스트:

- [ ] PRD 검증 통과 (John의 [VP] Validate PRD)
- [ ] 아키텍처 문서 완성 (Winston의 [CA])
- [ ] 에픽/스토리 목록 생성 (John의 [CE])
- [ ] Implementation Readiness 통과 ([IR])
- [ ] 모든 산출물 간 정합성 확인

---

## 3. PLAN 단계

### 3.1 입력과 출력

```
입력 (BMad 산출물):              출력 (PPV 실행 계획):
──────────────────               ──────────────────
prd.md                      →   specs/{feature}/requirements.md
architecture.md             →   specs/{feature}/design.md
epics-and-stories.md        →   specs/{feature}/tasks.md
                                 + Entropy Tolerance 태깅
                                 + 파일 소유권 배정
                                 + 플래닝 레벨 결정
```

### 3.2 반영 메커니즘

| 메커니즘 | 출처 | 설명 |
|---------|------|------|
| **Entropy Tolerance** | Cascade | 태스크별 리스크 수준 수치화 → VALIDATE 검증 밀도 사전 결정 |
| **Why Down + MSP** | Cascade | 기능 요청을 근본 문제로 환원 → 최소 문제 해결 세트(MSP) 도출 |
| **복잡도 기반 플래닝 레벨** | Automaker | Skip / Lite / Spec / Full 중 태스크 복잡도에 맞는 깊이 선택 |
| **재귀적 플래너 계층** | Cursor 2.0 | Root Planner → Sub-planner → Worker. fractal 분할 |
| **구조화된 스펙 파일** | Kiro | `requirements.md` → `design.md` → `tasks.md` 3-file 패턴 |
| **모델 특화** | Cursor 2.0 | 플래닝에는 추론 강한 모델, 코딩에는 코딩 특화 모델 배정 |
| **복잡도 자동 평가** | Auto-Claude | DISCOVERY → REQUIREMENTS → COMPLEXITY ASSESSMENT 파이프라인 |

### 3.3 BMad 에픽 → PPV 태스크 변환

BMad의 에픽/스토리를 PPV의 병렬 실행 가능한 태스크로 변환한다.

```
BMad Epic 1: 미션 수행 환경
├── Story 1.1: 미션 수행 화면         ──→  PPV Task (Agent-1, High Entropy)
├── Story 1.2: AI 채팅 연동           ──→  PPV Task (Agent-2, Medium Entropy)
├── Story 1.3: 결과물 에디터          ──→  PPV Task (Agent-3, Medium Entropy)
└── Story 1.4: 제출 처리              ──→  PPV Task (Agent-4, Low Entropy)

변환 시 추가되는 정보:
1. Entropy Tolerance 레벨
2. 담당 에이전트 + 파일 소유권
3. 의존 관계 (어떤 태스크가 먼저 완료되어야 하는가)
4. 인터페이스 계약 (공유 타입, API 스펙)
```

### 3.4 Entropy Tolerance 매트릭스

PLAN 단계에서 각 태스크에 Entropy Tolerance를 태깅한다. 이 값이 VALIDATE 단계의 검증 밀도를 결정한다.

```
┌──────────────────┬──────────────────┬──────────────────────────────┐
│ Entropy Tolerance│ 검증 밀도        │ 예시                         │
├──────────────────┼──────────────────┼──────────────────────────────┤
│ High (Porous)    │ 자동 테스트만    │ UI 애니메이션, 스타일링      │
│ Medium           │ 자동 + AI 리뷰   │ CRUD API, 일반 비즈니스 로직 │
│ Low (Dense)      │ 자동 + AI + 인간 │ 인증, 결제, 평가 채점 로직   │
└──────────────────┴──────────────────┴──────────────────────────────┘
```

### 3.5 재귀적 플래너 구조

대규모 에픽에서는 단일 Planner 대신 계층적 분할을 사용한다.

```
Root Planner (전체 아키텍처 — Winston의 architecture.md 기반)
├── Sub-planner: Frontend (참여자 앱)
│   ├── Worker: 미션 수행 화면
│   ├── Worker: 결과 화면
│   └── Worker: 프로파일
├── Sub-planner: Backend (서비스 레이어)
│   ├── Worker: 미션 엔진 API
│   ├── Worker: 평가 엔진 API
│   └── Worker: 인증 API
└── Sub-planner: Infrastructure
    ├── Worker: DB 마이그레이션
    └── Worker: CI/CD 파이프라인
```

### 3.6 구조화된 스펙 파일

Kiro의 3-file 패턴을 채택하되, BMad 산출물에서 자동 생성한다.

```
specs/
└── {feature-name}/
    ├── requirements.md      # ← BMad PRD + Story에서 추출
    ├── design.md            # ← BMad Architecture에서 추출
    └── tasks.md             # ← BMad Epic/Story를 병렬 태스크로 변환
```

**양방향 동기화**: 코드 변경 → 스펙 자동 업데이트, 스펙 변경 → 태스크 자동 재생성

### 3.7 플래닝 레벨 선택 기준

| 레벨 | 조건 | BMad 연동 | PPV 적용 |
|------|------|----------|----------|
| **Skip** | 단순 수정, 버그 픽스 | BMad Quick Flow만 | PPV 불필요 |
| **Lite** | 소규모 기능, 명확한 요구사항 | `/quick-spec` | 간단한 태스크 리스트 |
| **Spec** | 중규모 기능, 여러 파일 수정 | BMad Phase 2~3 축약 | requirements + design + tasks |
| **Full** | 대규모 기능, 아키텍처 변경 | BMad Phase 1~3 전체 | 위 + 재귀적 플래너 + Ultrathink |

---

## 4. PREVIEW 단계

### 4.1 반영 메커니즘

| 메커니즘 | 출처 | 설명 |
|---------|------|------|
| **SPEC → EXPERIMENT → SPEC 루프** | Cascade | 프로토타입으로 스펙 검증 후 스펙 재업데이트 |
| **Vibe Coding for Prototype** | Cascade | 프로토타입은 코드 품질 무시. Entropy Tolerance가 높은 프로세스 |
| **Spec-as-Source** | Tessl | 스펙에서 코드 생성. 코드는 일회용 |
| **Tiles** | Tessl | 컨텍스트 지식 패키지로 에이전트 추상화 준수도 35% 향상 |

### 4.2 BMad UX 설계 연동

BMad Phase 2에서 생성한 UX Design을 PREVIEW 검증 기준으로 사용한다.

```
BMad UX Design (ux-design.md)
        │
        ▼
┌──────────────────────────────────────┐
│ PREVIEW 검증 기준 자동 추출          │
│                                      │
│ - 화면 구성 요소 (컴포넌트 목록)     │
│ - 사용자 플로우 (페이지 전환)        │
│ - 인터랙션 패턴 (클릭, 입력, 제출)   │
│ - 반응형 요구사항                    │
└──────────────────┬───────────────────┘
                   ▼
          Vibe Coding 프로토타입
                   │
                   ▼
          UX 기준 대비 시각적 검증
```

### 4.3 PREVIEW 워크플로우

```
                    ┌──────────────────┐
                    │   SPEC (확정안)   │
                    │ + BMad UX Design │
                    └────────┬─────────┘
                             ▼
                    ┌──────────────────┐
                    │  Vibe Coding으로  │
                    │ 프로토타입 생성   │◄─────────────┐
                    │  (v0 / Bolt.new) │              │
                    └────────┬─────────┘              │
                             ▼                        │
                    ┌──────────────────┐              │
                    │ 사용자 시각적 확인│              │
                    │ (UX Design 대비) │              │
                    └────────┬─────────┘              │
                             ▼                        │
                    ┌──────────────────┐     NO       │
                    │   의도대로인가?   │──────────────┘
                    └────────┬─────────┘    (스펙 수정 후
                        YES  ▼               재생성)
                    ┌──────────────────┐
                    │ PARALLEL 단계로   │
                    │     진행         │
                    └──────────────────┘
```

### 4.4 핵심 원칙

1. **Disposable Preview**: 프리뷰 코드는 프로덕션과 완전 분리. 절대 프로덕션으로 이관하지 않는다
2. **빠른 반복**: Entropy Tolerance가 높은 프로세스이므로 검증 최소화, 속도 최대화
3. **스펙 우선**: 프리뷰에서 발견한 문제는 코드가 아닌 스펙을 수정하여 해결
4. **BMad UX 기준**: UX Design이 있으면 프로토타입의 검증 기준으로 사용

---

## 5. PARALLEL 단계

### 5.1 반영 메커니즘

| 메커니즘 | 출처 | 구현 도구 | 설명 |
|---------|------|----------|------|
| **Git Worktree 격리** | Cursor/Automaker | **Vibe Kanban** | 에이전트별 독립 워크트리로 충돌 원천 차단 |
| **태스크 관리** | Claude-Flow | **Native Teams** | TaskCreate/TaskUpdate로 태스크 할당 + 의존성 추적 |
| **파일 소유권 관리** | Claude-Flow | **CLAUDE.md 글루 레이어** | PLAN 단계에서 파일 소유권 배정, 에이전트에게 규칙 주입 |
| **Kanban 보드** | Automaker | **Vibe Kanban** | Plan-Approve-Execute 패턴, 시각적 진행 상태 관리 |
| **구조화된 핸드오프** | Cursor 2.0 | **SendMessage** | Goal → Changes → Open Questions → Next Owner 형식 |
| **GitHub Issues 연동** | - | **GitHub MCP Server** | 태스크↔Issue 양방향 동기화, PR 자동 생성 |
| **Ultrathink 모드** | Automaker | **모델 설정** | 복잡한 아키텍처 결정 시 추론 강한 모델 배정 |
| **교차 모델 검증** | Zenflow | **선택적** | Claude가 작성한 코드를 다른 LLM이 리뷰 |

### 5.2 BMad Dev Agent 연동

BMad의 Dev Agent(Amelia)를 PPV의 Worker 에이전트로 활용한다.

```
BMad 단독 실행 (기존):
  Amelia: Story 1 → Story 2 → Story 3 (순차)

PPV 통합 실행 (강화):
  Worker-1 (Amelia 역할): Story 1 ─┐
  Worker-2 (Amelia 역할): Story 2 ─┼→ 병렬 (Git Worktree 격리)
  Worker-3 (Amelia 역할): Story 3 ─┘
```

각 Worker는 BMad Dev Agent의 critical_actions를 준수한다:
- 스토리 파일 전체를 읽은 후 구현 시작
- tasks/subtasks를 순서대로 실행
- 구현 + 테스트 모두 완료 후에만 `[x]` 체크
- 테스트 실패 시 다음 단계 진행 금지

### 5.3 BMad Sprint Status 동기화

PPV PARALLEL에서 병렬 완료된 스토리를 BMad의 `sprint-status.yaml`에 반영한다.

```
PPV 실행 중 상태 동기화:

Worker-1 완료 → sprint-status.yaml 업데이트 (Story 1.1: Done)
Worker-2 완료 → sprint-status.yaml 업데이트 (Story 1.2: Done)
Worker-3 진행 중 → sprint-status.yaml 유지 (Story 1.3: In Progress)

→ Bob (SM)이 /sprint-status로 전체 진행 상황 확인 가능
```

### 5.4 병렬 실행 아키텍처

```
                  ┌──────────────────────────────────────┐
                  │      Vibe Kanban (Kanban Board)       │
                  │  Plan → Approve → Execute → Review   │
                  └──────────────────┬───────────────────┘
                                     │
                  ┌──────────────────┼───────────────────┐
                  │     Claude Code Native Teams          │
                  │  TeamCreate → TaskCreate/Assign       │
                  │  SendMessage → TaskUpdate(완료)       │
                  └──────────────────┬───────────────────┘
                                     │ 태스크 할당
                  ┌──────────────────┼──────────────┐
                  ▼                  ▼              ▼
          ┌──────────────┐   ┌──────────┐   ┌──────────┐
          │ Git Worktree │   │ Worktree │   │ Worktree │
          │      A       │   │    B     │   │    C     │
          │   Worker-1   │   │ Worker-2 │   │ Worker-3 │
          │  파일: a,b   │   │파일: c,d │   │파일: e,f │
          └──────┬───────┘   └────┬─────┘   └────┬─────┘
                 │                │              │
                 ▼                ▼              ▼
          ┌──────────────────────────────────────────┐
          │      GitHub MCP Server                    │
          │  PR 생성 → Issue 업데이트 → 코드 리뷰    │
          └──────────────────────────────────────────┘
                                │
                                ▼
                  ┌──────────────────────┐
                  │   Merge & Integration│
                  │  (Vibe Kanban 관리)  │
                  └──────────────────────┘
```

**도구 역할 요약:**
- **Vibe Kanban**: Worktree 생성/격리, 진행 상태 시각화, Plan-Approve-Execute 패턴 관리
- **Native Teams**: 에이전트 생성/할당, 태스크 의존성 추적, 에이전트 간 메시지 전달
- **GitHub MCP Server**: Issue 생성, PR 생성/리뷰, 코드 리뷰 코멘트 자동화
- **CLAUDE.md 글루 레이어**: 도구 간 연결 규칙, 이벤트별 행동 지침

### 5.5 파일 소유권 매핑

PLAN 단계에서 생성한 `tasks.md`에 파일 소유권을 명시한다.

```markdown
## Task 1: 미션 수행 화면 (Worker-1)
- BMad Story: Epic 1 / Story 1.1
- 소유 파일: src/pages/Mission.tsx, src/components/Editor.tsx
- 인터페이스: MissionAPI (types.ts:L12-L30)

## Task 2: 평가 엔진 API (Worker-2)
- BMad Story: Epic 2 / Story 2.1
- 소유 파일: src/api/evaluation.ts, src/services/scoring.ts
- 인터페이스: EvaluationAPI (types.ts:L31-L55)
```

### 5.6 핸드오프 프로토콜

에이전트 간 인수인계 시 다음 형식을 사용한다.

```markdown
## Handoff: Worker-1 → Worker-2

### Goal
미션 수행 화면의 AI 채팅 컴포넌트 구현 완료

### Changes
- src/components/Chat.tsx: 신규 생성. Claude API 호출 + 응답 스트리밍
- src/hooks/useChat.ts: 채팅 상태 관리 훅

### Open Questions
- 토큰 제한 초과 시 UX 처리 미정 (에러 모달 vs 자동 요약)
- 채팅 히스토리 저장 주기: 현재 메시지당 → 배치 저장 검토 필요

### Next Owner
Worker-2 (평가 엔진) — 채팅 로그를 평가 데이터로 변환하는 파이프라인 구현
```

---

## 6. VALIDATE 단계

### 6.1 반영 메커니즘

| 메커니즘 | 출처 | 설명 |
|---------|------|------|
| **Verification Gate (Porous/Dense)** | Cascade | Entropy Tolerance에 따라 검증 밀도 조절 |
| **127개 규칙 기반 Judge** | Cursor 2.0 | 측정 가능한 검증 기준 |
| **50회 반복 QA 루프** | Auto-Claude | QA Reviewer → QA Fixer → 재검증 자동 반복 |
| **멀티에이전트 감독** | Xebia ACE | 보안/성능/품질/비즈니스 로직 전문 에이전트 각각 검증 |
| **Chrome DevTools 통합** | Auto-Claude | 스크린샷, DOM 분석, UI 인터랙션 자동 테스트 |
| **메트릭 기반 최적화** | Cursor 2.0 | 검증 품질 자체를 측정하여 지속 개선 |
| **교차 모델 리뷰** | Zenflow | Claude ↔ OpenAI 상호 검증 |

### 6.2 BMad Code Review + QA 통합

BMad의 기존 검증 메커니즘을 PPV VALIDATE 파이프라인에 통합한다.

```
BMad 기존 검증                PPV 통합 검증
────────────────              ────────────────────────────────────

/code-review               →  VALIDATE Phase 2에 통합
(단일 적대적 리뷰어)           (BMad 체크리스트 + PPV 전문 Judge 팀)

Quinn (QA)                 →  VALIDATE Phase 1에 통합
(테스트 생성)                  (Quinn이 테스트 생성 → 자동 실행)

Bob (/sprint-status)       →  VALIDATE 완료 후 자동 반영
(스프린트 상태)                (스토리 상태 업데이트)
```

역할 분리:
- **Quinn (QA Agent)**: 테스트 코드 생성 (API, E2E)
- **PPV Code Quality Judge**: 코드 구조, 패턴, 중복 검증
- **PPV Security Judge**: OWASP Top 10, 취약점 검증
- **PPV Business Logic Judge**: 스펙 대비 구현 일치도 검증
- **BMad Adversarial Review**: 3~10개 문제 발견 (최종 게이트)

### 6.3 검증 파이프라인

```
┌─────────────────────────────────────────────────────────────────┐
│                    VALIDATE Pipeline                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Phase 1: 자동 검증 (모든 태스크) — Quinn(QA) 테스트 포함       │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ - Quinn 생성 테스트 실행 (API + E2E)                     │   │
│  │ - Dev Agent 단위 테스트 실행                              │   │
│  │ - 린터/타입 체크                                          │   │
│  │ - 빌드 성공 여부                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                          ▼                                      │
│  Phase 2: AI Judge 검증 (Medium + Low Entropy)                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ - Code Quality Judge: 구조, 패턴, 중복                    │   │
│  │ - Security Judge: OWASP Top 10, 인젝션, XSS              │   │
│  │ - Business Logic Judge: BMad PRD 수용 기준 대비 검증      │   │
│  │ - Architecture Judge: Winston의 ADR 준수 여부             │   │
│  │ - 교차 모델 리뷰: 다른 LLM으로 검증                       │   │
│  └──────────────────────────────────────────────────────────┘   │
│                          ▼                                      │
│  Phase 3: 시각적 검증 (UI 관련 태스크)                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ - BMad UX Design 대비 시각적 회귀 테스트                   │   │
│  │ - DOM 구조 검증                                           │   │
│  │ - UI 인터랙션 자동 테스트 (DevTools)                       │   │
│  └──────────────────────────────────────────────────────────┘   │
│                          ▼                                      │
│  Phase 4: BMad Adversarial Review (Low Entropy 태스크)          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ - BMad /code-review 실행 (최소 3개 문제 발견 목표)         │   │
│  │ - 핵심 비즈니스 로직 수동 리뷰                             │   │
│  │ - 최종 승인/반려                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  실패 시: QA Fixer → 수정 → Phase 1부터 재검증 (최대 50회)     │
└─────────────────────────────────────────────────────────────────┘
```

### 6.4 전문화된 Judge 에이전트 팀

| Judge | 검증 대상 | 기준 | BMad 연동 |
|-------|----------|------|----------|
| **Code Quality** | 코드 구조, 패턴 준수, 중복 | Clean Code, 프로젝트 컨벤션 | - |
| **Security** | 취약점, 인젝션, 인증 우회 | OWASP Top 10, CWE | - |
| **Performance** | N+1 쿼리, 메모리 누수, 렌더링 | 벤치마크 기준값 | - |
| **Business Logic** | 스펙 대비 구현 일치도 | requirements.md 수용 기준 | BMad PRD |
| **Architecture** | 아키텍처 패턴, 기술 결정 준수 | design.md 인터페이스 정의 | BMad Architecture + ADR |
| **BMad Adversarial** | 종합 리뷰 (최종 게이트) | BMad /code-review 체크리스트 | BMad Code Review |

### 6.5 메트릭 기반 개선

```
측정 항목:
- Resolution Rate: Judge가 발견한 이슈 중 실제 해결된 비율
- False Positive Rate: 오탐률 (낮을수록 좋음)
- Escape Rate: Judge를 통과했으나 이후 발견된 버그 비율
- BMad Review Alignment: PPV Judge가 놓쳤으나 BMad Review에서 발견된 이슈 비율
- 목표: Resolution Rate 70%+ 유지
```

---

## 7. Circuit Breaker

### 7.1 반영 메커니즘

| 메커니즘 | 출처 | 설명 |
|---------|------|------|
| **Disposable Code** | Tessl | 코드는 일회용, 스펙이 자산. 폐기 비용 최소화 |
| **Context Compaction** | Cursor 2.0 | 작업 상태를 요약하여 다음 사이클에 전달 |
| **Persistent Memory** | Claude-Flow | SQLite 기반 영구 메모리. 실패 패턴 학습 |
| **Self-Learning Neural** | Claude-Flow | 성공/실패 패턴을 벡터 메모리에 저장 |
| **ADR** | Xebia ACE | 아키텍처 결정 이력 기록. 추적 가능한 의사결정 |
| **Course Correction** | BMad | 구현 중 중대한 변경 필요 시 체계적 방향 전환 |

### 7.2 BMad Course Correction 연동

BMad의 `/correct-course` 워크플로우와 PPV Circuit Breaker를 연동한다.

```
PPV Circuit Breaker 발동
        │
        ├── 경미한 문제 → PPV 내부에서 해결 (스펙 수정 + 재실행)
        │
        └── 중대한 문제 → BMad Course Correction 연동
                │
                ▼
        ┌─────────────────────────────┐
        │ BMad /correct-course 실행   │
        │ - 변경 범위 분석            │
        │ - PRD/Architecture 영향도   │
        │ - 방향 전환 계획            │
        └────────────┬────────────────┘
                     ▼
        ┌─────────────────────────────┐
        │ BMad 산출물 업데이트         │
        │ - PRD 수정 (필요 시)        │
        │ - Architecture 수정         │
        │ - Epic/Story 재구성         │
        └────────────┬────────────────┘
                     ▼
        ┌─────────────────────────────┐
        │ PPV PLAN으로 복귀            │
        │ - 업데이트된 BMad 산출물 입력│
        │ - 실패 학습 메모리 참조      │
        └─────────────────────────────┘
```

### 7.3 Circuit Breaker 발동 조건

```
PPV 내부 처리 (경미):           BMad 연동 (중대):
──────────────────              ──────────────────
- 동일 카테고리 3회 연속 실패   - 아키텍처 레벨 설계 결함
- 인터페이스 계약 위반 1~2건    - 인터페이스 계약 위반 3건+
- 특정 태스크 구현 난항         - PRD 요구사항 자체의 모순
                                - 기술 스택 변경 필요
```

### 7.4 Circuit Breaker 발동 시 워크플로우

```
Circuit Breaker 발동
        │
        ▼
┌─────────────────────────────┐
│ 1. 실패 컨텍스트 요약 생성   │  ← Context Compaction
│    - 무엇을 시도했는가       │
│    - 왜 실패했는가           │
│    - 어떤 접근이 부분 성공   │
└────────────┬────────────────┘
             ▼
┌─────────────────────────────┐
│ 2. 실패 패턴 메모리 저장     │  ← Persistent Memory
│    - 실패 원인 분류          │
│    - ADR로 결정 이력 기록    │
└────────────┬────────────────┘
             ▼
┌─────────────────────────────┐
│ 3. 코드 전량 폐기            │  ← Disposable Code
│    - 스펙은 보존             │
│    - 워크트리 전부 삭제      │
└────────────┬────────────────┘
             ▼
┌─────────────────────────────┐
│ 4. 복귀 결정                 │
│    ├── 경미 → PPV PLAN 복귀  │
│    └── 중대 → BMad Phase 2~3│  ← /correct-course
│              산출물 재작성   │
└─────────────────────────────┘
```

### 7.5 Spec-as-Source 원칙

코드가 아닌 스펙이 자산이므로, Circuit Breaker 발동 시의 실질적 손실이 최소화된다.

```
보존되는 것:                 폐기되는 것:
─────────────                ─────────────
BMad PRD                     모든 생성 코드
BMad Architecture + ADR      워크트리
BMad Epic/Story              빌드 산출물
PPV specs/ (수정 후)
실패 학습 메모리
```

---

## 8. 횡단 메커니즘

PPV + BMad 전 단계에 걸쳐 적용되는 메커니즘들이다.

### 8.1 Traceable Flow

> 출처: Xebia ACE + BMad

BMad 산출물부터 코드까지의 전 단계를 추적 가능하게 한다.

```
BMad Product Brief ──▶ BMad PRD ──▶ BMad Architecture ──▶ BMad Epics
        │                │               │                    │
        ▼                ▼               ▼                    ▼
    PPV context     PPV requirements  PPV design          PPV tasks
                         │               │                    │
                         └───────────────┴────────────────────┘
                                         │
                                    코드 + 테스트
                               (모든 단계에서 역추적 가능)
```

### 8.2 Byzantine Fault Tolerance

> 출처: Claude-Flow

일부 에이전트가 실패하거나 잘못된 결과를 내더라도 전체 시스템이 안정적으로 동작한다.

- PBFT (Practical Byzantine Fault Tolerance) 합의 알고리즘
- 가중 다수결 투표
- 에이전트 실패 시 자동 재할당

### 8.3 Persistent Memory

> 출처: Claude-Flow

SQLite 기반 영구 메모리로 세션 간 학습을 보존한다.

```
저장 항목:
- 성공한 아키텍처 패턴
- 실패한 접근 방식과 원인
- 에이전트별 성능 메트릭
- 최적 모델-태스크 매핑
- BMad 워크플로우 소요 시간
```

### 8.4 MCP Protocol

> 출처: Kiro, Tessl | 구현: GitHub MCP Server + Vibe Kanban MCP

에이전트 간 표준화된 도구/컨텍스트 공유 프로토콜로 상호운용성을 보장한다.

**PPV에서 사용하는 MCP 서버:**
- **GitHub MCP Server** (github/github-mcp-server, 26.7k★): Issue/PR/Repository 관리
- **Vibe Kanban MCP** (내장): Kanban 보드 + Worktree 관리

```
MCP 연동 구조:
┌───────────────┐     MCP      ┌─────────────────┐
│ Claude Code   │◄────────────▶│ GitHub MCP      │
│ Native Teams  │              │ Server          │
│               │     MCP      ├─────────────────┤
│ .claude/agents│◄────────────▶│ Vibe Kanban     │
│               │              │ MCP Server      │
└───────────────┘              └─────────────────┘
```

**설정**: 프로젝트 `.mcp.json`에 MCP 서버 연결 정보를 정의한다.

---

## 9. Jiri 프로젝트 적용 예시

### 9.1 End-to-End: Sprint 1 - 미션 수행 환경 MVP

```
═══════════════════════════════════════════════════════════════
 BMad Phase 1: Analysis
═══════════════════════════════════════════════════════════════
/load-agent analyst (Mary)
  [RS] Research: AI 협업 평가 시장 리서치
  [CB] Create Brief: Jiri Product Brief 작성

산출물: planning-artifacts/product-brief.md

═══════════════════════════════════════════════════════════════
 BMad Phase 2: Planning
═══════════════════════════════════════════════════════════════
/load-agent pm (John)
  [CP] Create PRD: 미션 수행 환경 요구사항
  [VP] Validate PRD: 검증

/load-agent ux-designer
  UX Design: 미션 수행 화면 (2패널: 채팅 + 에디터)

산출물: planning-artifacts/prd.md, planning-artifacts/ux-design.md

═══════════════════════════════════════════════════════════════
 BMad Phase 3: Solutioning
═══════════════════════════════════════════════════════════════
/load-agent architect (Winston)
  [CA] Create Architecture: FastAPI + Next.js + PostgreSQL
  ADR-001: Python 선택 (AI 연동 참고자료 풍부)
  ADR-002: 모노레포 Turborepo (소규모 팀)

/load-agent pm (John)
  [CE] Create Epics and Stories:
    Epic 1: 미션 수행 환경 (Story 1.1~1.4)
    Epic 2: 평가 시스템 (Story 2.1~2.3)

  [IR] Implementation Readiness: ✅ PASS

산출물: planning-artifacts/architecture.md, planning-artifacts/epics.md

═══════════════════════════════════════════════════════════════
 핸드오프: BMad → PPV
═══════════════════════════════════════════════════════════════
BMad 산출물 → PPV specs/ 변환:
  specs/mission-environment/requirements.md  ← PRD Epic 1
  specs/mission-environment/design.md        ← Architecture
  specs/mission-environment/tasks.md         ← Stories → Tasks

═══════════════════════════════════════════════════════════════
 PPV PLAN
═══════════════════════════════════════════════════════════════
Entropy Tolerance 태깅:
├── High: 미션 수행 화면 레이아웃, 타이머 UI
├── Medium: AI 채팅 연동, 결과물 에디터, 자동 저장
└── Low: 제출 처리, 세션 관리

재귀적 분할 (Sub-planner):
├── Frontend Sub-planner
│   ├── Task: 미션 수행 레이아웃 (Worker-1, High)
│   ├── Task: AI 채팅 컴포넌트 (Worker-2, Medium)
│   ├── Task: 마크다운 에디터 (Worker-3, Medium)
│   └── Task: 타이머 + 자동저장 (Worker-4, High)
├── Backend Sub-planner
│   ├── Task: 세션 API (Worker-5, Low)
│   ├── Task: Claude API 프록시 (Worker-6, Medium)
│   └── Task: 결과물 저장 API (Worker-7, Medium)
└── Infrastructure Sub-planner
    └── Task: DB 마이그레이션 (Worker-8, Medium)

═══════════════════════════════════════════════════════════════
 PPV PREVIEW
═══════════════════════════════════════════════════════════════
v0로 미션 수행 화면 프로토타입 생성
→ BMad UX Design 대비 검증 (2패널 구조, 채팅 UI, 에디터)
→ 사용자 확인 → OK → PARALLEL 진행

═══════════════════════════════════════════════════════════════
 PPV PARALLEL (Vibe Kanban + Native Teams)
═══════════════════════════════════════════════════════════════
Vibe Kanban: 8개 Worktree 자동 생성 + Kanban 보드 관리
Native Teams: TeamCreate → Worker 에이전트 8개 생성/할당
파일 소유권: Worker-1은 Mission.tsx, Worker-2는 Chat.tsx ...
인터페이스 계약: types.ts 공유

GitHub MCP: 스토리별 Issue 생성 → Worker 완료 시 PR 자동 생성
완료 시 → sprint-status.yaml 자동 업데이트
Bob (SM): /sprint-status로 진행 상황 확인

═══════════════════════════════════════════════════════════════
 PPV VALIDATE
═══════════════════════════════════════════════════════════════
Phase 1: Quinn(QA) 테스트 + Dev Agent 단위 테스트 실행
Phase 2: AI Judge (보안: API 키 노출, 비즈니스: 제출 로직,
         Architecture: ADR 준수)
Phase 3: 시각적 검증 (미션 수행 화면 스크린샷 vs UX Design)
Phase 4: BMad /code-review (Low Entropy: 제출 처리, 세션 관리)

→ 모든 Phase 통과 → 스토리 완료 → 다음 스프린트
→ 실패 → QA Fixer 수정 → 재검증
→ 중대 실패 → Circuit Breaker → /correct-course
```

### 9.2 Quick Flow 예시: 버그 픽스

```
═══════════════════════════════════════════════════════════════
 BMad Quick Flow (PPV 불필요)
═══════════════════════════════════════════════════════════════
/load-agent quick-flow-solo-dev (Barry)
  [QS] Quick Spec: "채팅 메시지 순서 역전 버그" 분석 + 스펙
  [QD] Quick Dev: 구현 + 테스트
  [CR] Code Review: 적대적 리뷰 → 승인
```

---

## 10. 슬래시 커맨드 통합 가이드

BMad와 PPV를 실제로 사용할 때의 커맨드 흐름이다.

### 10.1 Full Path (신규 프로덕트)

```
# Phase 1: Analysis
/load-agent analyst
/product-brief

# Phase 2: Planning
/load-agent pm
/create-prd
/load-agent ux-designer

# Phase 3: Solutioning
/load-agent architect
/create-architecture
/load-agent pm
/create-epics-and-stories

# 핸드오프 검증
/implementation-readiness

# Phase 4: PPV 실행 (자동화)
# → PLAN: 에픽/스토리 → PPV 태스크 변환
# → PREVIEW: 프로토타입 생성 + 검증
# → PARALLEL: 멀티에이전트 병렬 구현
# → VALIDATE: Quinn 테스트 + Judge + /code-review

# 스프린트 관리
/load-agent sm
/sprint-planning
/sprint-status
```

### 10.2 Quick Flow (소규모 작업)

```
/load-agent quick-flow-solo-dev
/quick-spec
/dev-story
/code-review
```

### 10.3 Course Correction (방향 전환)

```
# Circuit Breaker 발동 시
/load-agent sm
/correct-course
# → BMad 산출물 재작성 후 PPV PLAN 복귀
```

---

## 11. 구현 작업 리스트

PPV+BMad 방법론을 설치 가능한 패키지(`ppv-bmad-kit`)로 구현하기 위한 작업 목록이다.

### 11.1 Phase 1: 저장소 초기화 + 패키지 구조

| # | 작업 | 설명 | 산출물 |
|---|------|------|--------|
| 1.1 | GitHub 저장소 생성 | `ppv-bmad-kit` 레포 생성, MIT 라이선스, README | repo |
| 1.2 | 패키지 구조 설계 | 디렉토리 레이아웃 확정 | 아래 참조 |
| 1.3 | 설치 스크립트 작성 | `npx ppv-bmad-kit init` 또는 `sh install.sh` | install.sh |

**패키지 디렉토리 구조:**
```
ppv-bmad-kit/
├── README.md                          # 설치/사용 가이드
├── install.sh                         # 설치 스크립트
├── package.json                       # npm 패키지 메타데이터
│
├── template/                          # 프로젝트에 복사될 파일들
│   ├── CLAUDE.md                      # 글루 레이어 (워크플로우 프로토콜)
│   ├── .mcp.json                      # MCP 서버 연결 설정
│   │
│   ├── .claude/
│   │   ├── agents/                    # Claude Code 커스텀 에이전트
│   │   │   ├── analyst.md             # Mary - Strategic Business Analyst
│   │   │   ├── pm.md                  # John - Product Manager
│   │   │   ├── architect.md           # Winston - System Architect
│   │   │   ├── dev.md                 # Amelia - Senior Developer
│   │   │   ├── qa.md                  # Quinn - QA Engineer
│   │   │   ├── sm.md                  # Bob - Scrum Master
│   │   │   ├── ux-designer.md         # UX Designer
│   │   │   ├── quick-flow.md          # Barry - Quick Flow Solo Dev
│   │   │   ├── ppv-planner.md         # PPV Root Planner
│   │   │   ├── ppv-worker.md          # PPV Worker Agent
│   │   │   ├── ppv-judge-quality.md   # Code Quality Judge
│   │   │   ├── ppv-judge-security.md  # Security Judge
│   │   │   └── ppv-judge-business.md  # Business Logic Judge
│   │   │
│   │   └── commands/                  # 슬래시 커맨드
│   │       ├── ppv-plan.md            # /ppv-plan: PLAN 단계 실행
│   │       ├── ppv-preview.md         # /ppv-preview: PREVIEW 단계
│   │       ├── ppv-parallel.md        # /ppv-parallel: PARALLEL 실행
│   │       ├── ppv-validate.md        # /ppv-validate: VALIDATE 파이프라인
│   │       └── ppv-circuit-breaker.md # /ppv-circuit-breaker: 방향 전환
│   │
│   └── _bmad/                         # BMad 워크플로우 (런타임 참조)
│       └── (BMad Method에서 복사)
│
├── docs/                              # 문서
│   └── ppv_methodology.md             # PPV+BMad 통합 방법론 문서
│
└── examples/                          # 적용 예시
    └── jiri/                          # Jiri 프로젝트 적용 예시
```

### 11.2 Phase 2: BMad 에이전트 → Claude Code 변환

| # | 작업 | 설명 | 산출물 |
|---|------|------|--------|
| 2.1 | 변환 규칙 정의 | YAML persona → MD frontmatter, critical_actions → rules | 변환 가이드 |
| 2.2 | BMad 8개 에이전트 변환 | analyst, pm, architect, dev, qa, sm, ux-designer, quick-flow | .claude/agents/*.md |
| 2.3 | PPV 전용 에이전트 생성 | planner, worker, judge-quality, judge-security, judge-business | .claude/agents/*.md |
| 2.4 | 에이전트 테스트 | 각 에이전트 로드 + 기본 동작 확인 | 테스트 결과 |

**변환 규칙 (BMad YAML → Claude Code MD):**
```
BMad YAML                          Claude Code MD
──────────                          ──────────────
name + role                    →    frontmatter: name, description
persona                        →    markdown body: 역할 + 성격
critical_actions               →    ## Rules 섹션
menu (DS, CR 등)               →    워크플로우 파일 읽기 지침
workflow references            →    _bmad/ 파일 경로 참조
```

### 11.3 Phase 3: PPV 슬래시 커맨드 구현

| # | 작업 | 설명 | 산출물 |
|---|------|------|--------|
| 3.1 | /ppv-plan 커맨드 | BMad 산출물 → specs/ 변환, Entropy 태깅, 파일 소유권 배정 | ppv-plan.md |
| 3.2 | /ppv-preview 커맨드 | 프로토타입 생성 지시, UX Design 대비 검증 | ppv-preview.md |
| 3.3 | /ppv-parallel 커맨드 | Native Teams 생성, Vibe Kanban 연동, Worker 할당 | ppv-parallel.md |
| 3.4 | /ppv-validate 커맨드 | 4-Phase 검증 파이프라인 실행 | ppv-validate.md |
| 3.5 | /ppv-circuit-breaker 커맨드 | 실패 분석, 코드 폐기, PLAN 복귀 또는 BMad 연동 | ppv-circuit-breaker.md |

### 11.4 Phase 4: 글루 레이어 (CLAUDE.md) 구현

| # | 작업 | 설명 | 산출물 |
|---|------|------|--------|
| 4.1 | 워크플로우 프로토콜 정의 | 도구 간 연결 규칙, 이벤트별 행동 지침 | CLAUDE.md |
| 4.2 | MCP 설정 파일 작성 | GitHub MCP Server + Vibe Kanban 연결 설정 | .mcp.json |
| 4.3 | BMad → PPV 핸드오프 자동화 | BMad Phase 3 완료 → PPV PLAN 자동 트리거 규칙 | CLAUDE.md 섹션 |
| 4.4 | sprint-status 동기화 규칙 | Worker 완료 → sprint-status.yaml + GitHub Issue 업데이트 | CLAUDE.md 섹션 |

### 11.5 Phase 5: 설치 스크립트 + 배포

| # | 작업 | 설명 | 산출물 |
|---|------|------|--------|
| 5.1 | install.sh 구현 | template/ → 프로젝트 루트 복사, 기존 파일 백업, 의존성 체크 | install.sh |
| 5.2 | npm 패키지화 | package.json 작성, bin 스크립트, `npx ppv-bmad-kit init` | package.json |
| 5.3 | 사전 요구사항 체크 | Claude Code, GitHub CLI, Node.js 설치 여부 확인 | install.sh 내 |
| 5.4 | README 작성 | 설치, 설정, 사용법, FAQ | README.md |

### 11.6 Phase 6: Jiri 프로젝트 적용 테스트

| # | 작업 | 설명 | 산출물 |
|---|------|------|--------|
| 6.1 | Jiri에 ppv-bmad-kit 설치 | install.sh 실행, 파일 구조 확인 | Jiri 프로젝트 설정 |
| 6.2 | BMad Full Path 테스트 | Phase 1~3 에이전트 실행, 산출물 생성 확인 | BMad 산출물 |
| 6.3 | PPV 커맨드 테스트 | /ppv-plan → /ppv-preview → /ppv-parallel → /ppv-validate | PPV 실행 결과 |
| 6.4 | 통합 E2E 테스트 | BMad Full → PPV Full 전체 파이프라인 실행 | 통합 결과 리포트 |
| 6.5 | 피드백 반영 + 수정 | 테스트 과정에서 발견한 문제 수정 | 패치 커밋 |

### 11.7 작업 의존성 요약

```
Phase 1 (저장소 초기화)
    │
    ├──▶ Phase 2 (에이전트 변환)
    │        │
    │        └──▶ Phase 3 (슬래시 커맨드)
    │                │
    └──▶ Phase 4 (글루 레이어) ◀──┘
             │
             └──▶ Phase 5 (설치 + 배포)
                      │
                      └──▶ Phase 6 (Jiri 테스트)
```

**예상 산출물 수:**
- `.claude/agents/` 에이전트: 13개 (BMad 8 + PPV 5)
- `.claude/commands/` 커맨드: 5개
- 설정 파일: CLAUDE.md, .mcp.json, install.sh, package.json
- 문서: README.md, ppv_methodology.md

---

## 12. 참고 자료

### 방법론

| 자료 | URL |
|------|-----|
| BMad Method v6.0 | https://github.com/bmad-code-org/BMAD-METHOD |
| BMad Method Docs | http://docs.bmad-method.org/ |
| Cascade Methodology | https://tonyalicea.dev/blog/cascade-methodology/ |
| Entropy Tolerance | https://tonyalicea.dev/blog/entropy-tolerance-ai/ |
| Why Down | https://tonyalicea.dev/blog/on-the-why-down/ |

### 상용 도구

| 도구 | URL |
|------|-----|
| Cursor 2.0 Scaling Agents | https://cursor.com/blog/scaling-agents |
| Cursor Background Agents | https://docs.cursor.com/en/background-agent |
| Cursor BugBot | https://cursor.com/blog/building-bugbot |
| Xebia ACE | https://xebia.com/digital-products-platforms/ai-native-software-engineering/ |
| Kiro Specs | https://kiro.dev/docs/specs/ |
| Zenflow | https://zencoder.ai/zenflow |
| Tessl | https://tessl.io/ |
| Tessl SDD (Martin Fowler) | https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html |

### 오픈소스

| 프로젝트 | URL |
|----------|-----|
| Auto-Claude | https://github.com/AndyMik90/Auto-Claude |
| Automaker | https://github.com/AutoMaker-Org/automaker |
| Claude-Flow | https://github.com/ruvnet/claude-flow |

### 구현 도구 스택

| 도구 | URL |
|------|-----|
| Claude Code Agent Teams | https://docs.anthropic.com/en/docs/claude-code |
| GitHub MCP Server | https://github.com/github/github-mcp-server |
| Vibe Kanban | https://github.com/vibe-kanban/vibe-kanban |

### 검증 사례

| 자료 | 설명 |
|------|------|
| Anthropic C 컴파일러 실험 | 16 에이전트, $20K, Rust 10만줄, GCC 테스트 99% 통과 |
| Cursor 브라우저 프로젝트 | 수백 GPT-5.2 에이전트, 1M줄, 1,000파일, 1주일 |
| Tessl 추상화 준수도 | Tiles 사용 시 35% 향상 |
| Cursor BugBot | 해결률 52% → 70%, 월 200만 PR 리뷰 |

---

## 13. 관련 문서

| 문서 | 설명 |
|------|------|
| [서비스설계문서](./jiri_service_design_document.md) | 전체 서비스 스펙 |
| [서비스레이어 MVP](./design_service_layer_mvp.md) | 서비스 레이어 MVP 설계 |
| [데이터레이어 MVP](./design_data_layer_mvp.md) | 데이터 레이어 MVP 설계 |
| [인프라레이어 MVP](./design_infrastructure_layer_mvp.md) | 인프라 레이어 MVP 설계 |
| [참여자앱 MVP](./design_user_layer_participant_app_mvp.md) | 참여자 앱/웹 MVP 설계 |
| [운영자도구 MVP](./design_user_layer_operator_tools_mvp.md) | 운영자 도구 MVP 설계 |
| [기업대시보드 MVP](./design_user_layer_enterprise_dashboard_mvp.md) | 기업 대시보드 MVP 설계 |
| [Tech Spec WIP](./docs/implementation-artifacts/tech-spec-wip.md) | MVP 프로덕션 기술 스펙 |

---

**문서 끝**
