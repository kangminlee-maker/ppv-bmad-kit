#!/bin/bash
# ppv-bmad-kit installer
# Usage: curl -fsSL https://raw.githubusercontent.com/kangminlee-maker/ppv-bmad-kit/main/install.sh | bash
# Or:    ./install.sh [target-directory]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() { echo -e "${BLUE}[ppv-bmad-kit]${NC} $1"; }
print_ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_err()  { echo -e "${RED}[ERROR]${NC} $1"; }

# Target directory
TARGET_DIR="${1:-.}"
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

print_step "PPV+BMad Kit Installer"
print_step "Target: $TARGET_DIR"
echo ""

# -------------------------------------------------------------------
# Prerequisites check
# -------------------------------------------------------------------
print_step "Checking prerequisites..."

MISSING=0

if ! command -v claude &> /dev/null; then
    print_warn "Claude Code CLI not found. Install: npm install -g @anthropic-ai/claude-code"
    MISSING=1
else
    print_ok "Claude Code CLI"
fi

if ! command -v gh &> /dev/null; then
    print_warn "GitHub CLI not found. Install: brew install gh"
    MISSING=1
else
    print_ok "GitHub CLI"
fi

if ! command -v git &> /dev/null; then
    print_err "Git not found. Please install Git first."
    exit 1
else
    print_ok "Git"
fi

if ! command -v node &> /dev/null; then
    print_warn "Node.js not found. Some features may not work."
    MISSING=1
else
    print_ok "Node.js $(node --version)"
fi

if [ $MISSING -eq 1 ]; then
    echo ""
    print_warn "Some prerequisites are missing. The kit will install but some features may not work."
    echo ""
fi

# -------------------------------------------------------------------
# Determine source directory
# -------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If running from cloned repo
if [ -d "$SCRIPT_DIR/template" ]; then
    SOURCE_DIR="$SCRIPT_DIR/template"
# If running via curl (download template from GitHub)
else
    print_step "Downloading template from GitHub..."
    TMP_DIR=$(mktemp -d)
    git clone --depth 1 https://github.com/kangminlee-maker/ppv-bmad-kit.git "$TMP_DIR/ppv-bmad-kit" 2>/dev/null
    SOURCE_DIR="$TMP_DIR/ppv-bmad-kit/template"
    CLEANUP_TMP=1
fi

# -------------------------------------------------------------------
# Install files
# -------------------------------------------------------------------
print_step "Installing PPV+BMad Kit..."

# .claude/agents/
if [ -d "$TARGET_DIR/.claude/agents" ]; then
    print_warn ".claude/agents/ already exists. Backing up to .claude/agents.bak/"
    cp -r "$TARGET_DIR/.claude/agents" "$TARGET_DIR/.claude/agents.bak.$(date +%Y%m%d%H%M%S)"
fi
mkdir -p "$TARGET_DIR/.claude/agents"
cp "$SOURCE_DIR/.claude/agents/"*.md "$TARGET_DIR/.claude/agents/"
print_ok "Installed $(ls "$SOURCE_DIR/.claude/agents/"*.md | wc -l | tr -d ' ') agents to .claude/agents/"

# .claude/commands/
if [ -d "$TARGET_DIR/.claude/commands" ]; then
    print_warn ".claude/commands/ already exists. Backing up."
    cp -r "$TARGET_DIR/.claude/commands" "$TARGET_DIR/.claude/commands.bak.$(date +%Y%m%d%H%M%S)"
fi
mkdir -p "$TARGET_DIR/.claude/commands"
cp "$SOURCE_DIR/.claude/commands/"*.md "$TARGET_DIR/.claude/commands/"
print_ok "Installed $(ls "$SOURCE_DIR/.claude/commands/"*.md | wc -l | tr -d ' ') commands to .claude/commands/"

# CLAUDE.md
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    print_warn "CLAUDE.md already exists. Backing up to CLAUDE.md.bak"
    cp "$TARGET_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md.bak.$(date +%Y%m%d%H%M%S)"
fi
cp "$SOURCE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
print_ok "Installed CLAUDE.md (glue layer)"

# .mcp.json
if [ -f "$TARGET_DIR/.mcp.json" ]; then
    print_warn ".mcp.json already exists. Skipping (merge manually if needed)."
else
    cp "$SOURCE_DIR/.mcp.json" "$TARGET_DIR/.mcp.json"
    print_ok "Installed .mcp.json (MCP server config)"
fi

# -------------------------------------------------------------------
# Create directory structure
# -------------------------------------------------------------------
mkdir -p "$TARGET_DIR/planning-artifacts"
mkdir -p "$TARGET_DIR/implementation-artifacts"
mkdir -p "$TARGET_DIR/specs"
print_ok "Created project directories (planning-artifacts/, implementation-artifacts/, specs/)"

# -------------------------------------------------------------------
# Cleanup
# -------------------------------------------------------------------
if [ "${CLEANUP_TMP:-0}" = "1" ]; then
    rm -rf "$TMP_DIR"
fi

# -------------------------------------------------------------------
# Summary
# -------------------------------------------------------------------
echo ""
echo "======================================"
print_ok "PPV+BMad Kit installed successfully!"
echo "======================================"
echo ""
echo "Installed files:"
echo "  .claude/agents/     - $(ls "$TARGET_DIR/.claude/agents/"*.md 2>/dev/null | wc -l | tr -d ' ') agent definitions"
echo "  .claude/commands/   - $(ls "$TARGET_DIR/.claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ') PPV commands"
echo "  CLAUDE.md           - Workflow protocol (glue layer)"
echo "  .mcp.json           - MCP server configuration"
echo ""
echo "Next steps:"
echo "  1. Configure .mcp.json with your GitHub token"
echo "  2. Install BMad Method: See _bmad/ setup in docs"
echo "  3. Start Claude Code and try: @analyst or /ppv-plan"
echo ""
print_step "Documentation: https://github.com/kangminlee-maker/ppv-bmad-kit"
