# ppv-bmad-kit

AI-native development methodology kit combining **PPV** (Plan-Preview-Parallel-Validate) execution strategy with **BMad Method** agent-driven requirement definition.

## What is PPV+BMad?

- **BMad Method**: Defines *what to build* using 8 specialized AI agents (Analyst, PM, Architect, Dev, QA, SM, UX Designer, Quick Flow)
- **PPV**: Defines *how to build it fast and safely* using multi-agent parallel execution and multi-dimensional validation

Two methodologies operate on different layers and combine without conflict.

## Tool Stack

| Tool | Role |
|------|------|
| Claude Code Native Teams | Agent orchestration + task dependency tracking |
| GitHub MCP Server | Issue/PR management via MCP |
| Vibe Kanban | Kanban board + Git Worktree isolation |
| BMad Method | Requirement definition agents + workflows |

## Quick Install

```bash
# Clone and install
git clone https://github.com/kangminlee-maker/ppv-bmad-kit.git
cd ppv-bmad-kit
./install.sh /path/to/your/project

# Or via npx (after npm publish)
npx ppv-bmad-kit init /path/to/your/project
```

## What Gets Installed

```
your-project/
├── CLAUDE.md                      # Workflow protocol (glue layer)
├── .mcp.json                      # MCP server configuration
├── .claude/
│   ├── agents/                    # 13 agent definitions
│   │   ├── analyst.md             # Mary - Business Analyst
│   │   ├── pm.md                  # John - Product Manager
│   │   ├── architect.md           # Winston - System Architect
│   │   ├── dev.md                 # Amelia - Senior Developer
│   │   ├── qa.md                  # Quinn - QA Engineer
│   │   ├── sm.md                  # Bob - Scrum Master
│   │   ├── ux-designer.md         # Sally - UX Designer
│   │   ├── quick-flow.md          # Barry - Quick Flow Solo Dev
│   │   ├── ppv-planner.md         # PPV Root Planner
│   │   ├── ppv-worker.md          # PPV Worker Agent
│   │   ├── ppv-judge-quality.md   # Code Quality Judge
│   │   ├── ppv-judge-security.md  # Security Judge
│   │   └── ppv-judge-business.md  # Business Logic Judge
│   └── commands/                  # 5 PPV slash commands
│       ├── ppv-plan.md
│       ├── ppv-preview.md
│       ├── ppv-parallel.md
│       ├── ppv-validate.md
│       └── ppv-circuit-breaker.md
├── planning-artifacts/            # BMad outputs (Phase 1~3)
├── implementation-artifacts/      # BMad implementation outputs
└── specs/                         # PPV spec files
```

## Workflow Modes

### Full Path (New product, complex features)
```
BMad Phase 1 (Analysis) → Phase 2 (Planning) → Phase 3 (Solutioning)
  → Handoff → /ppv-plan → /ppv-preview → /ppv-parallel → /ppv-validate
```

### Quick Flow (Small tasks)
```
@quick-flow → QS (Quick Spec) → QD (Quick Dev) → CR (Code Review)
```

### PPV Only (Requirements already defined)
```
/ppv-plan → /ppv-preview → /ppv-parallel → /ppv-validate
```

## BMad Agents

| Agent | Name | Role |
|-------|------|------|
| `@analyst` | Mary | Brainstorming, research, product brief |
| `@pm` | John | PRD, epics & stories |
| `@architect` | Winston | Architecture, ADR |
| `@dev` | Amelia | Story implementation |
| `@qa` | Quinn | Test automation |
| `@sm` | Bob | Sprint planning, story prep |
| `@ux-designer` | Sally | UX design |
| `@quick-flow` | Barry | Quick spec → dev → review |

## PPV Commands

| Command | Description |
|---------|-------------|
| `/ppv-plan` | Convert BMad artifacts to parallel execution plan |
| `/ppv-preview` | Generate prototype + visual verification |
| `/ppv-parallel` | Multi-agent parallel execution |
| `/ppv-validate` | 4-phase verification pipeline |
| `/ppv-circuit-breaker` | Course correction on repeated failures |

## Prerequisites

- [Claude Code](https://claude.ai/claude-code) CLI
- [GitHub CLI](https://cli.github.com/) (`gh`)
- Git
- Node.js (recommended)

## Post-Install Setup

1. **Configure GitHub MCP**: Edit `.mcp.json` with your GitHub Personal Access Token
2. **Install BMad workflows**: Copy `_bmad/` from [BMad Method](https://github.com/bmad-code-org/BMAD-METHOD) to your project root
3. **Start Claude Code**: Run `claude` and try `@analyst` or `/ppv-plan`

## License

MIT
