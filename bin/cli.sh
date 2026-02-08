#!/bin/bash
# ppv-bmad-kit CLI
# Usage: npx ppv-bmad-kit init [target-directory]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"

case "${1:-help}" in
    init)
        TARGET="${2:-.}"
        bash "$PACKAGE_DIR/install.sh" "$TARGET"
        ;;
    help|--help|-h)
        echo "ppv-bmad-kit - AI-native development methodology kit"
        echo ""
        echo "Usage:"
        echo "  ppv-bmad-kit init [directory]   Install PPV+BMad kit to target directory"
        echo "  ppv-bmad-kit help               Show this help message"
        echo ""
        echo "Examples:"
        echo "  npx ppv-bmad-kit init           Install to current directory"
        echo "  npx ppv-bmad-kit init ./my-app  Install to ./my-app"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'ppv-bmad-kit help' for usage."
        exit 1
        ;;
esac
