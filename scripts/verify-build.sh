#!/bin/bash
# Pre-commit validation script for ideep.cc
# Verifies Eleventy build before git commit
# Usage: npm run verify-build

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔍 Pre-commit verification${NC}"
echo ""

# Check if we're in project root
if [ ! -f "eleventy.config.js" ]; then
  echo -e "${RED}❌ Not in project root${NC}"
  exit 1
fi

# Get staged files
STAGED=$(git diff --cached --name-only --diff-filter=ACM)

if echo "$STAGED" | grep -qE "\.eleventy\.js|collections\.js|src/.*\.md|src/.*\.njk|\.mcp\.json"; then
  echo "📝 Config/content changes detected"
  echo ""
  echo "🔨 Running build..."
  echo ""
  
  if npm run build > /tmp/build.log 2>&1; then
    echo -e "${GREEN}✅ Build successful!${NC}"
    echo ""
    echo "Ready to commit. Staged files:"
    echo "$STAGED" | sed 's/^/  /'
    exit 0
  else
    echo -e "${RED}❌ Build failed!${NC}"
    echo ""
    echo "Last 20 lines of build output:"
    tail -20 /tmp/build.log
    echo ""
    echo -e "${YELLOW}Fix the errors above and try again.${NC}"
    echo "Common issues:"
    echo "  • Invalid YAML frontmatter (check date: YYYY-MM-DD, tags: lowercase)"
    echo "  • Duplicate exports in .eleventy.js"
    echo "  • Missing required fields in frontmatter"
    exit 1
  fi
else
  echo -e "${GREEN}✅ No config changes${NC}"
  exit 0
fi
